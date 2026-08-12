#!/bin/bash

# Monitor Fix Script for Multi-Monitor Setup
# Listens for screen unlock events and restores the correct monitor layout
# HDMI-0: 1920x1080 at position 43,0 (top-left monitor)
# DP-1: 1920x1080 at position 1963,0 (top-right monitor)
# DP-4: 2560x1600 at position 0,1080 (primary, bottom)
#
# Also fixes USB-C hub signal drops where xrandr shows correct layout but
# the monitor shows "HDMI no signal" because the hub's DP-to-HDMI converter
# didn't re-initialize after DPMS wake. Fixed by cycling nvidia-settings MetaMode.

LOG_FILE="$HOME/.local/share/monitor-fix.log"
LAST_RESTORE_FILE="/tmp/monitor-fix-last-$(id -u)"
COOLDOWN_SECONDS=30

# Expected layout: output_name:widthxheight+x+y
# These are DEFAULTS; they are overridden at runtime by the resync config
# (~/.local/share/monitor-fix/layout.env), which is regenerated automatically
# whenever you change Display Settings. See monitor-fix-resync.sh.
LAYOUT_CONFIG="$HOME/.local/share/monitor-fix/layout.env"

declare -A EXPECTED_LAYOUT
EXPECTED_LAYOUT[HDMI-0]="1920x1080+43+0"
EXPECTED_LAYOUT[DP-1]="1920x1080+1963+0"
EXPECTED_LAYOUT[DP-4]="2560x1600+0+1080"
PRIMARY_OUTPUT="DP-4"

# DP-* outputs to cycle via nvidia-settings MetaMode (USB-C hub signal fix)
DP_CYCLE_OUTPUTS="DP-1"

# MetaMode strings for nvidia-settings (DPY-1 = DP-1, DPY-4 = HDMI-0, DPY-5 = DP-4)
METAMODE_REDUCED='DPY-5: nvidia-auto-select @2560x1600 +0+1080 {ViewPortIn=2560x1600, ViewPortOut=2560x1600+0+0}, DPY-4: nvidia-auto-select @1920x1080 +43+0 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0}'
METAMODE_FULL='DPY-5: nvidia-auto-select @2560x1600 +0+1080 {ViewPortIn=2560x1600, ViewPortOut=2560x1600+0+0}, DPY-1: nvidia-auto-select @1920x1080 +1963+0 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0}, DPY-4: nvidia-auto-select @1920x1080 +43+0 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0}'

# Load layout data from the resync-generated config, overriding the defaults above.
# File format (one key=value per line, split on the first '='):
#   PRIMARY=<output>
#   DP_CYCLE=<space-separated DP-* outputs>
#   METAMODE_FULL=<nvidia metamode string>
#   METAMODE_REDUCED=<nvidia metamode string without the DP-* entries>
#   LAYOUT=<output> <WxH+X+Y>   (repeated per monitor)
load_layout_config() {
    [ -f "$LAYOUT_CONFIG" ] || return 1
    local -A _new_layout=()
    local _primary="" _dpcycle="" _mfull="" _mreduced="" key val
    while IFS='=' read -r key val; do
        case "$key" in
            PRIMARY)          _primary="$val" ;;
            DP_CYCLE)         _dpcycle="$val" ;;
            METAMODE_FULL)    _mfull="$val" ;;
            METAMODE_REDUCED) _mreduced="$val" ;;
            LAYOUT)           _new_layout["${val%% *}"]="${val#* }" ;;
        esac
    done < "$LAYOUT_CONFIG"
    # Only override if we parsed at least one monitor
    [ "${#_new_layout[@]}" -gt 0 ] || return 1
    unset EXPECTED_LAYOUT
    declare -gA EXPECTED_LAYOUT
    local k
    for k in "${!_new_layout[@]}"; do EXPECTED_LAYOUT["$k"]="${_new_layout[$k]}"; done
    [ -n "$_primary" ]  && PRIMARY_OUTPUT="$_primary"
    DP_CYCLE_OUTPUTS="$_dpcycle"
    [ -n "$_mfull" ]    && METAMODE_FULL="$_mfull"
    [ -n "$_mreduced" ] && METAMODE_REDUCED="$_mreduced"
    return 0
}
load_layout_config

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

check_layout() {
    # Returns 0 if layout is correct, 1 if there's an issue
    local xrandr_output
    xrandr_output=$(xrandr --query 2>/dev/null)

    for output in "${!EXPECTED_LAYOUT[@]}"; do
        local expected="${EXPECTED_LAYOUT[$output]}"
        local expected_res="${expected%%+*}"
        local expected_pos="+${expected#*+}"

        # Check if output is connected and has correct resolution+position
        local line
        line=$(echo "$xrandr_output" | grep "^${output} connected")
        if [ -z "$line" ]; then
            echo "not_connected:${output}"
            return 1
        fi

        # Extract current geometry from "connected [primary] WxH+X+Y"
        local current_geom
        current_geom=$(echo "$line" | grep -oP '\d+x\d+\+\d+\+\d+')
        if [ -z "$current_geom" ]; then
            echo "no_active_mode:${output}"
            return 1
        fi

        if [ "$current_geom" != "$expected" ]; then
            echo "wrong_layout:${output}:current=${current_geom}:expected=${expected}"
            return 1
        fi
    done

    echo "ok"
    return 0
}

apply_exact_layout() {
    local -a cmd=(/usr/bin/xrandr)
    local output geom res pos
    for output in "${!EXPECTED_LAYOUT[@]}"; do
        geom="${EXPECTED_LAYOUT[$output]}"
        res="${geom%%+*}"          # WxH
        pos="${geom#*+}"           # X+Y
        pos="${pos/+/x}"           # X+Y -> XxY
        cmd+=(--output "$output" --mode "$res")
        [ "$output" = "$PRIMARY_OUTPUT" ] && cmd+=(--primary)
        cmd+=(--pos "$pos")
    done
    "${cmd[@]}" 2>&1
}

wait_for_modes() {
    # Wait for all monitors to report their modes (they may take time after DPMS wake)
    local max_wait=10
    for i in $(seq 1 $max_wait); do
        local modes_ok=true
        for output in "${!EXPECTED_LAYOUT[@]}"; do
            local expected_res="${EXPECTED_LAYOUT[$output]}"
            expected_res="${expected_res%%+*}"  # extract WxH
            if ! xrandr --query 2>/dev/null | grep -A30 "^${output} connected" | grep -q "${expected_res}"; then
                modes_ok=false
                break
            fi
        done
        if $modes_ok; then
            log_msg "All monitor modes available after ${i}s"
            return 0
        fi
        sleep 1
    done
    log_msg "WARNING: Some modes still not available after ${max_wait}s, trying anyway"
    return 1
}

restore_monitors() {
    # Cooldown check
    local now
    now=$(date +%s)
    if [ -f "$LAST_RESTORE_FILE" ]; then
        local last_time
        last_time=$(cat "$LAST_RESTORE_FILE" 2>/dev/null)
        if [ -n "$last_time" ] && [ $((now - last_time)) -lt $COOLDOWN_SECONDS ]; then
            log_msg "Skipping (cooldown: last restore was $((now - last_time))s ago)"
            return
        fi
    fi
    echo "$now" > "$LAST_RESTORE_FILE"

    log_msg "Screen unlocked, starting monitor restore..."

    # Reload layout data (regenerated by monitor-fix-resync when Display Settings change)
    if load_layout_config; then
        log_msg "Loaded layout config: primary=${PRIMARY_OUTPUT} dp_cycle='${DP_CYCLE_OUTPUTS}'"
    fi

    # Step 1: Force DPMS on to wake all monitors
    xset dpms force on 2>/dev/null
    log_msg "DPMS forced on"
    sleep 0.5

    # Step 1.5: Wait for monitor modes to become available
    wait_for_modes

    # Step 2: Cycle DP outputs via nvidia-settings MetaMode to fix USB-C hub
    # signal drops. The hub's DP-to-HDMI converter may not re-initialize after
    # DPMS wake, causing "HDMI no signal" even though xrandr shows correct layout.
    # This forces NVIDIA to fully tear down and recreate the DP pipeline.
    if [ -n "$METAMODE_FULL" ] && [ -n "$METAMODE_REDUCED" ] && [ -n "$DP_CYCLE_OUTPUTS" ]; then
        log_msg "Cycling DP outputs (${DP_CYCLE_OUTPUTS}) via nvidia-settings MetaMode (USB-C hub fix)..."
        nvidia-settings --assign "CurrentMetaMode=${METAMODE_REDUCED}" 2>/dev/null || true
        for _dp in $DP_CYCLE_OUTPUTS; do
            xrandr --output "$_dp" --off 2>/dev/null || true
        done
        sleep 15
        nvidia-settings --assign "CurrentMetaMode=${METAMODE_FULL}" 2>/dev/null || true
        sleep 2
        log_msg "MetaMode cycle complete"
    fi

    # Step 3: Poll layout to check if xrandr fix is also needed
    local status
    local poll_interval=1
    local poll_count=3
    local issue_found=false
    local last_status=""

    for i in $(seq 1 $poll_count); do
        sleep $poll_interval
        status=$(check_layout)
        if [ "$status" != "ok" ]; then
            issue_found=true
            last_status="$status"
            log_msg "Poll $i/$poll_count: layout issue detected: $status"
            break
        fi
    done

    if [ "$issue_found" = "false" ]; then
        log_msg "Layout correct after MetaMode cycle + ${poll_count}s polling"
        date +%s > "$LAST_RESTORE_FILE"
        return
    fi

    status="$last_status"
    log_msg "Layout issue: $status — applying xrandr fix..."

    # Step 4: Try applying exact layout directly (fast path)
    local max_retries=5
    local retry=1
    while [ $retry -le $max_retries ]; do
        log_msg "Applying exact layout (attempt $retry)..."
        local output
        output=$(apply_exact_layout)
        local rc=$?

        if [ $rc -eq 0 ] && [ -z "$output" ]; then
            sleep 0.5
            status=$(check_layout)
            if [ "$status" = "ok" ]; then
                log_msg "Layout restored and verified on attempt $retry"
                date +%s > "$LAST_RESTORE_FILE"
                return
            else
                log_msg "xrandr succeeded but verification failed: $status"
            fi
        else
            log_msg "Attempt $retry failed (rc=$rc): $output"
        fi

        # On first failure, initialize CRTCs with --auto before next retry
        if [ $retry -eq 1 ]; then
            log_msg "Initializing outputs with --auto..."
            xrandr --output HDMI-0 --auto --output DP-1 --auto --output DP-4 --auto 2>/dev/null
            sleep 1
        else
            sleep $((retry * 1))
        fi
        retry=$((retry + 1))
    done

    log_msg "WARNING: All $max_retries attempts failed. Final state:"
    xrandr --query 2>/dev/null | grep -E "^\S+ connected" >> "$LOG_FILE"
    date +%s > "$LAST_RESTORE_FILE"
}

unlock_detected=false

dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver'" | \
while read -r line; do
    if echo "$line" | grep -q "member=ActiveChanged"; then
        unlock_detected=true
    fi

    if [[ "$unlock_detected" == "true" ]] && echo "$line" | grep -q "boolean false"; then
        restore_monitors
        unlock_detected=false
    fi

    if echo "$line" | grep -q "member=" && ! echo "$line" | grep -q "member=ActiveChanged"; then
        unlock_detected=false
    fi
done
