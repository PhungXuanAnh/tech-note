#!/bin/bash
# Manual monitor fix — run this if the auto service didn't fix the layout
# Usage: fix-monitors-manual
#
# Handles two distinct issues:
# 1. Layout issue: monitors connected but wrong resolution/position (xrandr fix)
# 2. Signal issue: USB-C hub drops DP signal after DPMS (nvidia-settings MetaMode fix)
set -uo pipefail

# Desired layout is read from the resync-generated config, which is auto-updated
# whenever you change Display Settings. Built-in defaults are used if it's missing,
# so this script always runs correctly with no arguments.
LAYOUT_CONFIG="$HOME/.local/share/monitor-fix/layout.env"

declare -A EXPECTED_LAYOUT=(
    [HDMI-0]="1920x1080+43+0"
    [DP-1]="1920x1080+1963+0"
    [DP-4]="2560x1600+0+1080"
)
PRIMARY_OUTPUT="DP-4"
DP_CYCLE_OUTPUTS="DP-1"
# MetaMode strings for nvidia-settings (DPY-1 = DP-1, DPY-4 = HDMI-0, DPY-5 = DP-4)
METAMODE_REDUCED='DPY-5: nvidia-auto-select @2560x1600 +0+1080 {ViewPortIn=2560x1600, ViewPortOut=2560x1600+0+0}, DPY-4: nvidia-auto-select @1920x1080 +43+0 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0}'
METAMODE_FULL='DPY-5: nvidia-auto-select @2560x1600 +0+1080 {ViewPortIn=2560x1600, ViewPortOut=2560x1600+0+0}, DPY-1: nvidia-auto-select @1920x1080 +1963+0 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0}, DPY-4: nvidia-auto-select @1920x1080 +43+0 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0}'

load_layout_config() {
    [ -f "$LAYOUT_CONFIG" ] || return 1
    local -A _new=()
    local _primary="" _dpcycle="" _full="" _reduced="" key val
    while IFS='=' read -r key val; do
        case "$key" in
            PRIMARY)          _primary="$val" ;;
            DP_CYCLE)         _dpcycle="$val" ;;
            METAMODE_FULL)    _full="$val" ;;
            METAMODE_REDUCED) _reduced="$val" ;;
            LAYOUT)           _new["${val%% *}"]="${val#* }" ;;
        esac
    done < "$LAYOUT_CONFIG"
    [ "${#_new[@]}" -gt 0 ] || return 1
    unset EXPECTED_LAYOUT
    declare -gA EXPECTED_LAYOUT
    local k
    for k in "${!_new[@]}"; do EXPECTED_LAYOUT["$k"]="${_new[$k]}"; done
    [ -n "$_primary" ]  && PRIMARY_OUTPUT="$_primary"
    DP_CYCLE_OUTPUTS="$_dpcycle"
    [ -n "$_full" ]     && METAMODE_FULL="$_full"
    [ -n "$_reduced" ]  && METAMODE_REDUCED="$_reduced"
    return 0
}
if load_layout_config; then
    echo "Loaded layout config (primary=$PRIMARY_OUTPUT, dp_cycle='$DP_CYCLE_OUTPUTS')"
else
    echo "No layout config found; using built-in defaults"
fi

echo "=== Current layout ==="
xrandr --query | grep -E "^\S+ connected"

echo ""
echo "Forcing DPMS on..."
xset dpms force on
sleep 1

# Wait for modes to become available (monitors may take time after DPMS wake)
wait_for_modes() {
    local max_wait=10 i output res
    for i in $(seq 1 $max_wait); do
        local modes_ok=true
        for output in "${!EXPECTED_LAYOUT[@]}"; do
            res="${EXPECTED_LAYOUT[$output]%%+*}"   # WxH from "WxH+X+Y"
            if ! xrandr --query 2>/dev/null | grep -A20 "^${output} connected" | grep -q "$res"; then
                modes_ok=false
                break
            fi
        done
        if $modes_ok; then
            echo "Modes available after ${i}s"
            return 0
        fi
        echo "Waiting for monitor modes... (${i}/${max_wait})"
        sleep 1
    done
    echo "WARNING: Some modes still not available after ${max_wait}s, trying anyway"
    return 1
}

wait_for_modes || true

# Step 1: Force DP signal re-negotiation via nvidia-settings MetaMode cycling.
# This fixes USB-C hub signal drops where xrandr shows correct layout but monitor
# shows "HDMI no signal" because the hub's DP-to-HDMI converter didn't re-initialize.
if [ -n "$METAMODE_FULL" ] && [ -n "$METAMODE_REDUCED" ] && [ -n "$DP_CYCLE_OUTPUTS" ]; then
    echo ""
    echo "Cycling DP outputs (${DP_CYCLE_OUTPUTS}) via nvidia-settings MetaMode (fixes USB-C hub signal drops)..."
    echo "  Removing cycled DP outputs from MetaMode..."
    nvidia-settings --assign "CurrentMetaMode=${METAMODE_REDUCED}" 2>&1 | grep -v "^$" || true
    for dp in $DP_CYCLE_OUTPUTS; do
        echo "  Turning off $dp via xrandr..."
        xrandr --output "$dp" --off 2>/dev/null || true
    done
    echo "  Waiting 15 seconds for USB-C hub to fully tear down..."
    sleep 15
    echo "  Re-adding DP outputs to MetaMode..."
    nvidia-settings --assign "CurrentMetaMode=${METAMODE_FULL}" 2>&1 | grep -v "^$" || true
    sleep 2
fi

# Step 2: Apply exact xrandr layout to ensure correct positions
apply_layout() {
    local -a cmd=(xrandr)
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

MAX_RETRIES=5
for retry in $(seq 1 $MAX_RETRIES); do
    echo ""
    echo "Applying xrandr layout (attempt $retry/$MAX_RETRIES)..."

    output=$(apply_layout) && rc=0 || rc=$?

    if [ $rc -eq 0 ] && [ -z "$output" ]; then
        sleep 0.5
        echo "=== Verified ==="
        xrandr --query | grep -E "^\S+ connected"
        echo ""
        echo "Layout restored successfully."
        exit 0
    fi

    echo "Failed: $output"

    # On first failure, initialize CRTCs with --auto
    if [ $retry -eq 1 ]; then
        echo "Initializing outputs with --auto..."
        for output in "${!EXPECTED_LAYOUT[@]}"; do
            xrandr --output "$output" --auto 2>/dev/null || true
        done
        sleep 1
    else
        sleep $retry
    fi
done

echo ""
echo "ERROR: All $MAX_RETRIES attempts failed."
echo "Final state:"
xrandr --query | grep -E "^\S+ connected"
exit 1
