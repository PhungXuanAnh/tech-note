#!/bin/bash
# monitor-fix-resync.sh
#
# Regenerates the monitor-fix layout config from the CURRENT (known-good) xrandr
# layout + nvidia MetaMode, so the unlock fix always targets your current layout.
#
# Triggered automatically by monitor-fix-resync.path whenever ~/.config/monitors.xml
# changes (i.e. you rearrange displays in Settings -> Displays). Can also be run by
# hand: monitor-fix-resync.sh
#
# Output: ~/.local/share/monitor-fix/layout.env  (sourced by fix-monitors-auto.sh)
set -uo pipefail

LOG_FILE="$HOME/.local/share/monitor-fix.log"
CONFIG_DIR="$HOME/.local/share/monitor-fix"
CONFIG_FILE="$CONFIG_DIR/layout.env"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S'): [resync] $1" >> "$LOG_FILE"; }

mkdir -p "$CONFIG_DIR"

# GNOME applies the new layout to xrandr right after writing monitors.xml; give it
# a moment to settle so we capture the final state.
sleep 2

XR=$(xrandr --query 2>/dev/null)
CONNECTED=$(echo "$XR" | grep -E "^\S+ connected")
if [ -z "$CONNECTED" ]; then
    log "no connected outputs, aborting"
    exit 0
fi

# Sanity guard: only capture when every connected output has an active mode.
# If any output is mode-less the layout is mid-transition/broken — don't persist it.
while IFS= read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    if ! echo "$line" | grep -qoP '\d+x\d+\+\d+\+\d+'; then
        log "output $name has no active mode; layout not stable, skipping resync"
        exit 0
    fi
done <<< "$CONNECTED"

PRIMARY=$(echo "$XR" | grep -E "^\S+ connected primary" | awk '{print $1}')

# Doc refresh rate DANG CHAY cua mot output tu ket qua xrandr --query.
# Dong mode dang duoc dung co dau '*', vi du:
#     DP-4 connected primary 2560x1600+651+1080 (...) 340mm x 220mm
#        2560x1600     60.00 + 240.00*
# -> tra ve "240.00". Dau '+' (preferred) va '*' deu bi cat bo.
current_rate() {
    local out="$1"
    echo "$XR" | awk -v o="$out" '
        $1 == o && $2 == "connected" { inblock = 1; next }
        /^[^ \t]/                    { inblock = 0 }
        inblock {
            for (i = 1; i <= NF; i++)
                if ($i ~ /\*/) { gsub(/[*+]/, "", $i); print $i; exit }
        }'
}

# Build layout lines + DP-* cycle list from the current xrandr geometry
LAYOUT_LINES=""
RATE_LINES=""
DP_CYCLE=""
NAMES=""
while IFS= read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    geom=$(echo "$line" | grep -oP '\d+x\d+\+\d+\+\d+' | head -1)
    [ -n "$geom" ] || continue
    LAYOUT_LINES="${LAYOUT_LINES}LAYOUT=${name} ${geom}\n"
    # Luu ca refresh rate. Neu khong luu, fix-monitors-auto.sh se goi
    # 'xrandr --mode WxH' khong kem --rate, va xrandr chon rate uu tien theo
    # EDID -> man 240Hz bi am tham keo ve 60Hz sau moi lan mo khoa.
    rate=$(current_rate "$name")
    [ -n "$rate" ] && RATE_LINES="${RATE_LINES}RATE=${name} ${rate}\n"
    NAMES="$NAMES $name"
    # Cycle only external DP-* monitors (USB-C hub). Skip the primary output,
    # which is the laptop's own panel (DP-4 here) and must never be turned off.
    if [[ "$name" == DP-* ]] && [ "$name" != "$PRIMARY" ]; then
        DP_CYCLE="${DP_CYCLE}${name} "
    fi
done <<< "$CONNECTED"
DP_CYCLE=$(echo "$DP_CYCLE" | sed 's/ *$//')

# Detect nvidia MetaMode (USB-C hub signal fix). METAMODE_FULL is the current
# known-good mode; METAMODE_REDUCED is the same with the cycled DP entries removed.
METAMODE_FULL=""
METAMODE_REDUCED=""
if command -v nvidia-settings >/dev/null 2>&1 && [ -n "$DP_CYCLE" ]; then
    METAMODE_FULL=$(nvidia-settings -t -q CurrentMetaMode 2>/dev/null | head -1 | sed 's/^.*:: //')
    if [ -n "$METAMODE_FULL" ]; then
        # Collect the DPY-N ids to strip (one per cycled DP output)
        remove_ids=""
        for mon in $DP_CYCLE; do
            dpy_id=$(nvidia-settings -q dpys 2>/dev/null | grep -B1 "($mon)" | grep -oP 'dpy:\d+' | head -1)
            [ -n "$dpy_id" ] && remove_ids="${remove_ids}${dpy_id#dpy:} "
        done
        # Split MetaMode into per-DPY blocks (a block is 'DPY-N: ... {..., ...}').
        # Blocks are separated by ', DPY-' at top level, but each block contains
        # commas inside its {ViewPortIn=..., ViewPortOut=...} braces, so a naive
        # comma split corrupts it. Split on the block boundary instead, then
        # keep only the blocks whose DPY id is not being cycled.
        blocks=$(echo "$METAMODE_FULL" | sed 's/, DPY-/\n DPY-/g')
        kept=""
        while IFS= read -r blk; do
            blk="${blk# }"
            [ -n "$blk" ] || continue
            skip=false
            for id in $remove_ids; do
                if [[ "$blk" == DPY-${id}:* ]]; then skip=true; break; fi
            done
            $skip && continue
            if [ -z "$kept" ]; then kept="$blk"; else kept="$kept, $blk"; fi
        done <<< "$blocks"
        METAMODE_REDUCED="$kept"
        # If nothing was removed there is no DP monitor to cycle
        if [ "$METAMODE_REDUCED" = "$METAMODE_FULL" ]; then
            METAMODE_FULL=""
            METAMODE_REDUCED=""
        fi
    fi
fi

# Write the config atomically
tmp=$(mktemp)
{
    echo "# Auto-generated by monitor-fix-resync.sh on $(date '+%Y-%m-%d %H:%M:%S')"
    echo "# Regenerated automatically when Display Settings change. Do not edit by hand."
    [ -n "$PRIMARY" ] && echo "PRIMARY=$PRIMARY"
    echo "DP_CYCLE=$DP_CYCLE"
    echo -en "$LAYOUT_LINES"
    echo -en "$RATE_LINES"
    [ -n "$METAMODE_FULL" ] && echo "METAMODE_FULL=$METAMODE_FULL"
    [ -n "$METAMODE_REDUCED" ] && echo "METAMODE_REDUCED=$METAMODE_REDUCED"
} > "$tmp"
mv -f "$tmp" "$CONFIG_FILE"

log "layout config regenerated: primary=${PRIMARY:-none} dp_cycle='${DP_CYCLE}' monitors=[${NAMES# }]"
