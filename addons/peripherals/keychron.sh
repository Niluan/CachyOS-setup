#!/bin/bash
# Addon: Keychron K17 Max (tastatur) + M6 8K (mus)
# Giver Keychron Launcher (launcher.keychron.com) adgang via WebHID til at
# konfigurere taster, makroer, DPI og polling rate.
# Denne fil er selvstændig og kaldes af setup.sh, men kan også køres alene:
#   bash addons/peripherals/keychron.sh
set -e

ADDON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$ADDON_DIR/../.." && pwd)"

echo ""
echo ">> Tilføjer udev-regel til Keychron Launcher (K17 Max + M6 8K)..."
sudo cp "$REPO_ROOT/configs/udev/99-keychron.rules" /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

echo ""
echo ">> Færdig. Husk:"
echo "   - Tilslut enheden med KABEL (ikke Bluetooth/dongle) for at konfigurere den"
echo "   - Åbn https://launcher.keychron.com i Chromium (kræver WebHID, virker ikke i Firefox)"
