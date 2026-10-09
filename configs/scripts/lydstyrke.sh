#!/usr/bin/env bash
# lydstyrke.sh — skru op/ned for en lydkanal, begrænset til 0–100 %.
# Bruges fra OpenDeck Run Command-knapper, så de kan have egne ikoner.
#
#   lydstyrke.sh <kanal> op|ned [trin]
#
# Kanal: OSSink (System), MusicSink (Musik), GameSink (Spil),
#        CommsSink (Kommunikation), master (standard-output)
#        eller mic (standard-input). Trin er i procent (standard 5).

kanal="$1"; retning="$2"; trin="${3:-5}"

case "$kanal" in
    master) type="sink";   navn="@DEFAULT_SINK@" ;;
    mic)    type="source"; navn="@DEFAULT_SOURCE@" ;;
    *)      type="sink";   navn="$kanal" ;;
esac

nu=$(pactl "get-$type-volume" "$navn" 2>/dev/null | grep -oP '\d+(?=%)' | head -1)
[[ -z "$nu" ]] && { echo "Kanal ikke fundet: $kanal" >&2; exit 1; }

case "$retning" in
    op)  ny=$(( nu + trin )); (( ny > 100 )) && ny=100 ;;
    ned) ny=$(( nu - trin )); (( ny < 0 ))   && ny=0 ;;
    *)   echo "Brug: $0 <kanal> op|ned [trin]" >&2; exit 1 ;;
esac

pactl "set-$type-volume" "$navn" "${ny}%"
