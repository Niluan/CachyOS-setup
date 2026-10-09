#!/usr/bin/env bash
# skift-lyd.sh — vælg standard-output:
#   Højtalere = bundkortets optiske udgang -> EDIFIER M90
#   Headset   = bundkortets Line out -> Arctis basestation
# De virtuelle kanaler (System/Musik/Spil/Kommunikation) følger automatisk med.
#
#   skift-lyd.sh            skift til den anden udgang
#   skift-lyd.sh headset    skift altid til headset
#   skift-lyd.sh hojtalere  skift altid til højtalere
#
# Til OpenDeck: Toggle Action med to Run Commands (headset / hojtalere).

# Find enhederne ud fra navnemønster, så scriptet virker uanset ID/serienummer
SPEAKERS=$(pactl list short sinks | awk '$2 == "hojtalere_optisk" {print $2; exit}')
HEADSET=$(pactl list short sinks | awk '$2 ~ /^alsa_output\.pci-0000_0d_00\.4\./ {print $2; exit}')

current=$(pactl get-default-sink)

case "$1" in
    headset)   target="headset" ;;
    hojtalere) target="hojtalere" ;;
    "")        [[ "$current" == "$HEADSET" ]] && target="hojtalere" || target="headset" ;;
    *)         echo "Brug: $0 [headset|hojtalere]" >&2; exit 1 ;;
esac

if [[ "$target" == "headset" ]]; then
    next="$HEADSET";  label="Headset";   icon="audio-headphones"
else
    next="$SPEAKERS"; label="Højtalere"; icon="audio-speakers"
fi

if [[ -z "$next" ]]; then
    notify-send -a "Lyd" -i dialog-error -t 3000 "Lydudgang" "$label blev ikke fundet (er den tilsluttet og tændt?)"
    exit 1
fi

[[ "$current" == "$next" ]] && exit 0

old_idx=$(pactl list short sinks | awk -v n="$current" '$2==n {print $1}')

pactl set-default-sink "$next"

# Flyt kun streams der lå direkte på den gamle udgang (fx loopbacks fra
# de virtuelle kanaler) — IKKE apps inde i Spil/Musik/System/Kommunikation.
if [[ -n "$old_idx" ]]; then
    pactl list short sink-inputs | awk -v s="$old_idx" '$2==s {print $1}' |
    while read -r id; do
        pactl move-sink-input "$id" "$next"
    done
fi

notify-send -a "Lyd" -i "$icon" -t 1500 "Lydudgang" "$label"
