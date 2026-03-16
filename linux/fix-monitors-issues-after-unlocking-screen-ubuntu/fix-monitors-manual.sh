#!/bin/bash
# Manual monitor fix — run this if the auto service didn't fix the layout
# Usage: fix-monitors-manual
set -euo pipefail

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

# Try applying exact layout with retries
MAX_RETRIES=5
for retry in $(seq 1 $MAX_RETRIES); do
    echo ""
    echo "Applying layout (attempt $retry/$MAX_RETRIES)..."

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
