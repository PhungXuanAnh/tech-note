#!/bin/bash
# Manual monitor fix — run this if the auto service didn't fix the layout
# Usage: fix-monitors-manual
#
# Handles two distinct issues:
# 1. Layout issue: monitors connected but wrong resolution/position (xrandr fix)
# 2. Signal issue: USB-C hub drops DP signal after DPMS (nvidia-settings MetaMode fix)
set -euo pipefail

# MetaMode strings for nvidia-settings (DPY-1 = DP-1, DPY-4 = HDMI-0, DPY-5 = DP-4)
METAMODE_WITHOUT_DP1='DPY-5: nvidia-auto-select @2560x1600 +741+1080 {ViewPortIn=2560x1600, ViewPortOut=2560x1600+0+0}, DPY-4: nvidia-auto-select @1920x1080 +0+0 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0}'
METAMODE_WITH_DP1='DPY-5: nvidia-auto-select @2560x1600 +741+1080 {ViewPortIn=2560x1600, ViewPortOut=2560x1600+0+0}, DPY-1: nvidia-auto-select @1920x1080 +1920+0 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0}, DPY-4: nvidia-auto-select @1920x1080 +0+0 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0}'

echo "=== Current layout ==="
xrandr --query | grep -E "^\S+ connected"

echo ""
echo "Forcing DPMS on..."
xset dpms force on
sleep 1

# Wait for modes to become available (monitors may take time after DPMS wake)
wait_for_modes() {
    local max_wait=10
    for i in $(seq 1 $max_wait); do
        local modes_ok=true
        for output in HDMI-0 DP-1 DP-4; do
            if ! xrandr --query 2>/dev/null | grep -A20 "^${output} connected" | grep -q "1920x1080\|2560x1600"; then
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

wait_for_modes

# Step 1: Force DP-1 signal re-negotiation via nvidia-settings MetaMode cycling.
# This fixes USB-C hub signal drops where xrandr shows correct layout but monitor
# shows "HDMI no signal" because the hub's DP-to-HDMI converter didn't re-initialize.
echo ""
echo "Cycling DP-1 via nvidia-settings MetaMode (fixes USB-C hub signal drops)..."
echo "  Removing DPY-1 from MetaMode..."
nvidia-settings --assign "CurrentMetaMode=${METAMODE_WITHOUT_DP1}" 2>&1 | grep -v "^$" || true
echo "  Turning off DP-1 via xrandr..."
xrandr --output DP-1 --off 2>/dev/null || true
echo "  Waiting 15 seconds for USB-C hub to fully tear down..."
sleep 15
echo "  Re-adding DPY-1 to MetaMode..."
nvidia-settings --assign "CurrentMetaMode=${METAMODE_WITH_DP1}" 2>&1 | grep -v "^$" || true
sleep 2

# Step 2: Apply exact xrandr layout to ensure correct positions
MAX_RETRIES=5
for retry in $(seq 1 $MAX_RETRIES); do
    echo ""
    echo "Applying xrandr layout (attempt $retry/$MAX_RETRIES)..."

    output=$(xrandr \
        --output HDMI-0 --mode 1920x1080 --pos 0x0 \
        --output DP-1 --mode 1920x1080 --pos 1920x0 \
        --output DP-4 --primary --mode 2560x1600 --pos 741x1080 2>&1) && rc=0 || rc=$?

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
        xrandr --output HDMI-0 --auto --output DP-1 --auto --output DP-4 --auto 2>/dev/null || true
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
