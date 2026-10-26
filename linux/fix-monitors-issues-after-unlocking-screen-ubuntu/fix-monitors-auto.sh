#!/bin/bash

# Monitor Fix Script for Multi-Monitor Setup
# Listens for screen unlock events and restores the correct monitor layout
# HDMI-0: 1920x1080 at position 43,0 (top-left monitor)
# DP-1: 1920x1080 at position 1963,0 (top-right monitor)
# DP-4: 2560x1600 at position 0,1080 (primary, bottom)
#
# Does NOT reset the USB-C hub on unlock: the hub already drops and re-asserts
# DP-1 by itself when the screens wake, and a second forced reset blacked out
# all monitors for ~20s on every unlock. If DP-1 really stays on "no signal",
# run fix-monitors-manual (bound to a keyboard shortcut) to reset the hub.

LOG_FILE="$HOME/.local/share/monitor-fix.log"
LAST_RESTORE_FILE="/tmp/monitor-fix-last-$(id -u)"
COOLDOWN_SECONDS=30

# Expected layout: output_name:widthxheight+x+y
# These are DEFAULTS; they are overridden at runtime by the resync config
# (~/.local/share/monitor-fix/layout.env), which is regenerated automatically
# whenever you change Display Settings. See monitor-fix-resync.sh.
LAYOUT_CONFIG="$HOME/.local/share/monitor-fix/layout.env"

declare -A EXPECTED_LAYOUT
# Refresh rate mong doi cho tung output. Rong = khong ep rate (giu hanh vi cu).
declare -A EXPECTED_RATE
EXPECTED_LAYOUT[HDMI-0]="1920x1080+43+0"
EXPECTED_LAYOUT[DP-1]="1920x1080+1963+0"
EXPECTED_LAYOUT[DP-4]="2560x1600+0+1080"
PRIMARY_OUTPUT="DP-4"
# nvidia MetaMode of the known-good layout; applying it is a single modeset
METAMODE_FULL=""

# Load layout data from the resync-generated config, overriding the defaults above.
# File format (one key=value per line, split on the first '='; the DP_CYCLE and
# METAMODE_REDUCED keys are only used by fix-monitors-manual.sh):
#   PRIMARY=<output>
#   METAMODE_FULL=<nvidia metamode string>
#   LAYOUT=<output> <WxH+X+Y>   (repeated per monitor)
#   RATE=<output> <refresh>     (repeated per monitor; optional, older configs
#                                have none and then no rate is forced)
load_layout_config() {
    [ -f "$LAYOUT_CONFIG" ] || return 1
    local -A _new_layout=()
    local -A _new_rate=()
    local _primary="" _mfull="" key val
    while IFS='=' read -r key val; do
        case "$key" in
            PRIMARY)       _primary="$val" ;;
            METAMODE_FULL) _mfull="$val" ;;
            LAYOUT)        _new_layout["${val%% *}"]="${val#* }" ;;
            RATE)          _new_rate["${val%% *}"]="${val#* }" ;;
        esac
    done < "$LAYOUT_CONFIG"
    # Only override if we parsed at least one monitor
    [ "${#_new_layout[@]}" -gt 0 ] || return 1
    unset EXPECTED_LAYOUT
    declare -gA EXPECTED_LAYOUT
    local k
    for k in "${!_new_layout[@]}"; do EXPECTED_LAYOUT["$k"]="${_new_layout[$k]}"; done
    unset EXPECTED_RATE
    declare -gA EXPECTED_RATE
    for k in "${!_new_rate[@]}"; do EXPECTED_RATE["$k"]="${_new_rate[$k]}"; done
    [ -n "$_primary" ] && PRIMARY_OUTPUT="$_primary"
    METAMODE_FULL="$_mfull"
    return 0
}
load_layout_config

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Doc refresh rate DANG CHAY cua mot output.
#   $1 = ket qua 'xrandr --query', $2 = ten output
# Dong mode dang dung co dau '*', vi du "   2560x1600     60.00 + 240.00*"
current_rate_of() {
    echo "$1" | awk -v o="$2" '
        $1 == o && $2 == "connected" { inblock = 1; next }
        /^[^ \t]/                    { inblock = 0 }
        inblock {
            for (i = 1; i <= NF; i++)
                if ($i ~ /\*/) { gsub(/[*+]/, "", $i); print $i; exit }
        }'
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

        # Kiem tra ca refresh rate. Can thiet vi buoc cycle MetaMode o tren dung
        # 'nvidia-auto-select', luon chon rate uu tien theo EDID (60Hz) va do do
        # am tham keo man 240Hz xuong 60Hz. Chi so sanh khi layout.env co RATE,
        # nen file cu van chay y nhu truoc.
        local expected_rate="${EXPECTED_RATE[$output]:-}"
        if [ -n "$expected_rate" ]; then
            local current_rate
            current_rate=$(current_rate_of "$xrandr_output" "$output")
            if [ "$current_rate" != "$expected_rate" ]; then
                echo "wrong_rate:${output}:current=${current_rate:-none}:expected=${expected_rate}"
                return 1
            fi
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
        [ -n "${EXPECTED_RATE[$output]:-}" ] && cmd+=(--rate "${EXPECTED_RATE[$output]}")
        [ "$output" = "$PRIMARY_OUTPUT" ] && cmd+=(--primary)
        cmd+=(--pos "$pos")
    done
    "${cmd[@]}" 2>&1
}

# One modeset instead of xrandr's one per output (~1.5s instead of ~4s).
# Prints the check_layout status afterwards.
apply_metamode() {
    [ -n "$METAMODE_FULL" ] || { echo "no_metamode"; return 1; }
    nvidia-settings --assign "CurrentMetaMode=${METAMODE_FULL}" >/dev/null 2>&1
    check_layout
}

all_outputs_active() {
    local xrandr_output output
    xrandr_output=$(xrandr --query 2>/dev/null)
    for output in "${!EXPECTED_LAYOUT[@]}"; do
        echo "$xrandr_output" | grep "^${output} connected" | grep -qP '\d+x\d+\+\d+\+\d+' || return 1
    done
    return 0
}

# After a DPMS wake the USB-C hub drops DP-1 and re-adds it up to ~15s later.
# Driving DP-1 with xrandr before Mutter has re-enabled it makes the hub reset again.
wait_for_active_outputs() {
    local max_wait=20 i
    for i in $(seq 1 $max_wait); do
        if all_outputs_active; then
            log_msg "All outputs active after ${i}s"
            return 0
        fi
        sleep 1
    done
    log_msg "WARNING: not all outputs active after ${max_wait}s, trying anyway"
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
        log_msg "Loaded layout config: primary=${PRIMARY_OUTPUT}"
    fi

    # Step 1: Force DPMS on to wake all monitors
    xset dpms force on 2>/dev/null
    log_msg "DPMS forced on"
    sleep 0.5

    # Step 1.5: Wait until Mutter has re-enabled every output. If we had to wait,
    # Mutter is still mid-change, so give it a few seconds to finish (Step 2).
    local poll_count=1
    if ! all_outputs_active; then
        wait_for_active_outputs
        poll_count=3
    fi

    # Step 2: Check layout
    local status
    for i in $(seq 1 $poll_count); do
        status=$(check_layout)
        if [ "$status" = "ok" ]; then
            log_msg "Layout correct (poll $i/$poll_count)"
            date +%s > "$LAST_RESTORE_FILE"
            return
        fi
        sleep 1
    done

    log_msg "Layout issue: $status — applying MetaMode..."
    status=$(apply_metamode)
    if [ "$status" = "ok" ]; then
        log_msg "Layout restored via MetaMode"
        date +%s > "$LAST_RESTORE_FILE"
        return
    fi
    log_msg "MetaMode did not fix layout ($status) — applying xrandr fix..."

    # Step 3: Try applying exact layout directly (fast path)
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

# While the screen is locked and the monitors sleep, the USB-C hub drops and
# re-adds DP-1, and Mutter sometimes leaves DP-4 at +0+0 after re-adding it.
# Fixing it on the lock screen (on display change or when the monitors wake)
# means nothing is left to redo after unlock.
fix_layout_while_locked() {
    xset q 2>/dev/null | grep -q "Monitor is On" || return
    if ! all_outputs_active; then
        log_msg "Locked: waiting, not all outputs active (USB-C hub still resetting?)"
        return
    fi
    local status
    status=$(check_layout)
    case "$status" in
        wrong_layout:*|wrong_rate:*) ;;
        *)
            log_msg "Locked: layout $status"
            return
            ;;
    esac
    log_msg "Locked: layout issue: $status — applying MetaMode..."
    status=$(apply_metamode)
    if [ "$status" = "ok" ]; then
        log_msg "Locked: layout restored via MetaMode"
        return
    fi
    local output
    output=$(apply_exact_layout)
    log_msg "Locked: MetaMode gave $status, xrandr fix done (rc=$?) ${output} -> $(check_layout)"
}

# Seconds without MonitorsChanged (or since the monitors woke) before the layout
# counts as settled
SETTLE_SECONDS=2

active_changed=false
locked=false
monitor_on=true
monitors_changed_at=""

dbus-monitor --session \
    "type='signal',interface='org.gnome.ScreenSaver',member='ActiveChanged'" \
    "type='signal',interface='org.gnome.Mutter.DisplayConfig',member='MonitorsChanged'" | \
while true; do
    read -r -t 1 line
    rc=$?
    # read returns >128 on timeout; anything else non-zero means dbus-monitor exited
    if [ $rc -ne 0 ] && [ $rc -le 128 ]; then
        break
    fi

    if [ $rc -eq 0 ]; then
        case "$line" in
            *member=ActiveChanged*)
                active_changed=true
                ;;
            *member=MonitorsChanged*)
                if [ "$locked" = "true" ]; then
                    [ -z "$monitors_changed_at" ] && log_msg "Locked: monitors changed"
                    monitors_changed_at=$(date +%s)
                fi
                ;;
            *"boolean true"*)
                if [ "$active_changed" = "true" ] && [ "$locked" = "false" ]; then
                    locked=true
                    log_msg "Screen locked"
                fi
                active_changed=false
                ;;
            *"boolean false"*)
                if [ "$active_changed" = "true" ]; then
                    locked=false
                    monitors_changed_at=""
                    restore_monitors
                fi
                active_changed=false
                ;;
        esac
    fi

    if [ "$locked" = "true" ]; then
        if xset q 2>/dev/null | grep -q "Monitor is On"; then
            if [ "$monitor_on" = "false" ]; then
                log_msg "Locked: monitors woke up"
                monitors_changed_at=$(date +%s)
            fi
            monitor_on=true
        else
            [ "$monitor_on" = "true" ] && log_msg "Locked: monitors went to sleep"
            monitor_on=false
        fi
    fi

    if [ -n "$monitors_changed_at" ] && [ $(( $(date +%s) - monitors_changed_at )) -ge $SETTLE_SECONDS ]; then
        monitors_changed_at=""
        fix_layout_while_locked
    fi
done
