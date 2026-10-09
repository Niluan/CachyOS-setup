#!/bin/bash
# Addon: Lyd på Asus ROG Strix X570-E
#
#   Højtalere -> optisk udgang (SPDIF OUT) -> EDIFIER M90 (optisk input)
#   Headset   -> grønt stik (LINE OUT) -> aux -> Arctis Pro Wireless basestation
#   Mikrofon  <- Arctis headset via Bluetooth (HFP)
#
# Installerer:
#   configs/pipewire/60-optisk-hojtalere.conf -> "Højtalere" på den optiske udgang
#   configs/wireplumber/51-lyd-setup.conf     -> profil, navne, prioriteter, Bluetooth
#   configs/scripts/skift-lyd.sh              -> ~/.local/bin (Stream Deck-knap)
#
# Kan også køres alene:
#   bash addons/audio/lyd-hojtalere-headset.sh
set -e

ADDON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$ADDON_DIR/../.." && pwd)"
CONFIG_DIR="$REPO_ROOT/configs"

echo ""
echo ">> Installerer pakker (pactl, alsa-værktøjer, Bluetooth, notifikationer)..."
sudo pacman -S --needed --noconfirm libpulse alsa-utils bluez bluez-utils libnotify
sudo systemctl enable --now bluetooth.service

echo ">> Fjerner tidligere lydopsætninger (hvis de findes)..."
rm -f "$HOME/.config/pipewire/pipewire.conf.d/60-output-split.conf"
sudo rm -f /etc/udev/rules.d/50-edifier-m90.rules
# Gammelt autostart-script, der oprettede dublerede kanaler med 1 ms latency (gav knas)
rm -f "$HOME/.config/autostart/setup-sinks.desktop" "$HOME/.local/bin/setup-sinks.sh"

echo ">> Tænder for den optiske udgang (IEC958) og gemmer indstillingen..."
amixer -q -c Generic sset IEC958 on
sudo alsactl store

echo ">> Installerer PipeWire- og WirePlumber-konfiguration..."
install -Dm644 "$CONFIG_DIR/pipewire/60-optisk-hojtalere.conf" \
    "$HOME/.config/pipewire/pipewire.conf.d/60-optisk-hojtalere.conf"
install -Dm644 "$CONFIG_DIR/wireplumber/51-lyd-setup.conf" \
    "$HOME/.config/wireplumber/wireplumber.conf.d/51-lyd-setup.conf"

echo ">> Installerer skift-lyd.sh til ~/.local/bin..."
install -Dm755 "$CONFIG_DIR/scripts/skift-lyd.sh" "$HOME/.local/bin/skift-lyd.sh"

echo ">> Genstarter PipeWire/WirePlumber (hvis de kører)..."
systemctl --user restart pipewire wireplumber 2>/dev/null || \
    echo "   (Kører ikke endnu - træder i kraft ved næste login)"

echo ""
echo ">> Færdig. Husk:"
echo "   - EDIFIER M90: optisk kabel i SPDIF OUT bagpå, vælg optisk som input"
echo "   - Arctis basestation: aux-kabel i GRØN (LINE OUT), vælg aux/line som input"
echo "   - Par Arctis-headsettet via Bluetooth i KDE (bruges til mikrofonen)"
echo "   - OpenDeck: Toggle Action med Run Commands"
echo "       $HOME/.local/bin/skift-lyd.sh headset"
echo "       $HOME/.local/bin/skift-lyd.sh hojtalere"
