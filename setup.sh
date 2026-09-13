#!/bin/bash
set -e

# Find scriptets egen placering, så det virker uanset hvor repoet er klonet ned
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/configs"

echo "== Opdaterer system =="
sudo pacman -Syu --noconfirm

echo "== Sikrer at multilib er aktiveret (nødvendigt for Steam/32-bit programmer) =="
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i "/^#\[multilib\]/,/^#Include/s/^#//" /etc/pacman.conf
    sudo pacman -Sy
fi

echo "== Basisværktøjer til AUR/GitHub-installationer =="
sudo pacman -S --needed --noconfirm git curl wget base-devel gnupg

echo "== Installerer paru hvis den mangler =="
if ! command -v paru &> /dev/null; then
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
    cd -
fi

echo "== Browser =="
sudo pacman -S --needed --noconfirm chromium

echo "== Office & PDF =="
sudo pacman -S --needed --noconfirm libreoffice-fresh

echo "== E-mail =="
sudo pacman -S --needed --noconfirm thunderbird

echo "== Print & scan =="
sudo pacman -S --needed --noconfirm cups print-manager system-config-printer sane simple-scan
sudo systemctl enable --now cups.socket

echo "== Printer-drivere (addons) =="
PRINTER_ADDON_DIR="$SCRIPT_DIR/addons/printers"
if [ -d "$PRINTER_ADDON_DIR" ]; then
    mapfile -t PRINTER_ADDONS < <(find "$PRINTER_ADDON_DIR" -maxdepth 1 -type f -name "*.sh" | sort)
else
    PRINTER_ADDONS=()
fi

if [ "${#PRINTER_ADDONS[@]}" -gt 0 ]; then
    read -rp "Vil du installere en printer-driver fra addons/printers/? [y/N] " INSTALL_PRINTER
    if [[ "$INSTALL_PRINTER" =~ ^[Yy]$ ]]; then
        if [ "${#PRINTER_ADDONS[@]}" -eq 1 ]; then
            echo "Installerer: $(basename "${PRINTER_ADDONS[0]}" .sh)"
            bash "${PRINTER_ADDONS[0]}"
        else
            echo "Flere printer-addons fundet i addons/printers/:"
            PRINTER_ADDON_NAMES=()
            for f in "${PRINTER_ADDONS[@]}"; do
                PRINTER_ADDON_NAMES+=("$(basename "$f" .sh)")
            done
            PS3="Vælg en printer (nummer): "
            select CHOSEN in "${PRINTER_ADDON_NAMES[@]}" "Spring over"; do
                if [ -n "$REPLY" ] && [ "$REPLY" -ge 1 ] 2>/dev/null && [ "$REPLY" -le "${#PRINTER_ADDONS[@]}" ] 2>/dev/null; then
                    bash "${PRINTER_ADDONS[$((REPLY-1))]}"
                    break
                else
                    echo "Springer printer-installation over."
                    break
                fi
            done
        fi
    fi
else
    echo "Ingen printer-addons fundet i addons/printers/ – springer over."
fi

echo "== Grafik & billedredigering =="
sudo pacman -S --needed --noconfirm krita
sudo pacman -S --needed --noconfirm libmpv libraw
mkdir -p ~/Apps/FerrumPix
curl -L -o ~/Apps/FerrumPix/FerrumPix.AppImage \
  "https://github.com/Bitpainter75/FerrumPix/releases/latest/download/FerrumPix.AppImage"
chmod +x ~/Apps/FerrumPix/FerrumPix.AppImage

echo "== Gaming =="
sudo pacman -S --needed --noconfirm steam
paru -S --needed --noconfirm discord

echo "== 3D print & CAD =="
paru -S --needed --noconfirm orca-slicer-bin
sudo pacman -S --needed --noconfirm freecad

echo "== Lyd & video =="
sudo pacman -S --needed --noconfirm pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber vlc \
    libdvdread libdvdnav libbluray a52dec faac faad2 x264 x265
paru -S --needed --noconfirm libdvdcss

echo "== Opretter virtuelle lydkanaler (System, Musik, Spil, Kommunikation) =="
mkdir -p ~/.config/pipewire/pipewire.conf.d
cp "$CONFIG_DIR/pipewire/50-virtual-sinks.conf" ~/.config/pipewire/pipewire.conf.d/

echo "== Skærmdeling/portals (Discord m.fl. under Wayland) =="
sudo pacman -S --needed --noconfirm xdg-desktop-portal-kde

echo "== Stream Deck (OpenDeck) =="
paru -S --needed --noconfirm opendeck-bin
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -aG input "$USER"

echo "== Keychron-tastatur/mus (udev-regel til Keychron Launcher) =="
sudo cp "$CONFIG_DIR/udev/99-keychron.rules" /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "== Musik, udvikling & sikkerhed =="
sudo pacman -S --needed --noconfirm spotify-launcher
paru -S --needed --noconfirm visual-studio-code-bin bitwarden

echo "== Flatpak (fallback til programmer uden for pacman/AUR) =="
sudo pacman -S --needed --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo ""
echo "======================================================"
echo " Færdig! Se README.md for de manuelle trin der mangler."
echo "======================================================"
