#!/bin/bash
set -e

# Find scriptets egen placering, så det virker uanset hvor repoet er klonet ned
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/configs"

# --------------------------------------------------------------------------
# Hjælpefunktioner til addons
# --------------------------------------------------------------------------

# choose_addon "<mappe>" "<spørgsmål>"
# Spørger om en addon-kategori og skriver den valgte fil (eller ingenting) til stdout.
# Er der flere addons i mappen, vælges der fra en nummereret liste.
choose_addon() {
    local addon_dir="$1"
    local prompt_text="$2"
    local addons=()

    if [ -d "$addon_dir" ]; then
        mapfile -t addons < <(find "$addon_dir" -maxdepth 1 -type f -name "*.sh" | sort)
    fi
    [ "${#addons[@]}" -eq 0 ] && return

    read -rp "$prompt_text [y/N] " ANSWER
    [[ ! "$ANSWER" =~ ^[Yy]$ ]] && return

    if [ "${#addons[@]}" -eq 1 ]; then
        echo "${addons[0]}"
        return
    fi

    echo "   Flere muligheder i $(basename "$addon_dir"):" >&2
    local i=1
    for f in "${addons[@]}"; do
        echo "     $i) $(basename "$f" .sh)" >&2
        i=$((i+1))
    done
    read -rp "   Vælg nummer (tom = spring over): " CHOICE
    if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#addons[@]}" ]; then
        echo "${addons[$((CHOICE-1))]}"
    fi
}

# run_addon "<fil>" – kører en valgt addon (gør ingenting, hvis tom)
run_addon() {
    if [ -n "$1" ]; then
        echo "== Addon: $(basename "$1" .sh) =="
        bash "$1"
    fi
}

# --------------------------------------------------------------------------
# Spørgsmål – alt spørges her i starten, så resten kan køre uden opsyn
# --------------------------------------------------------------------------

echo "======================================================"
echo " CachyOS setup"
echo " Besvar spørgsmålene herunder – derefter kører resten"
echo " af installationen af sig selv."
echo "======================================================"
echo ""

echo "-- Addons --"
ADDON_AUDIO=$(choose_addon "$SCRIPT_DIR/addons/audio" "Lyd: sæt højtalere/headset-skift op (addons/audio)?")
ADDON_PRINTERS=$(choose_addon "$SCRIPT_DIR/addons/printers" "Printer: installer printer-driver (addons/printers)?")
ADDON_PERIPHERALS=$(choose_addon "$SCRIPT_DIR/addons/peripherals" "Perifere enheder: tastatur/mus (addons/peripherals)?")
echo ""

echo "-- Git (til commits) --"
GIT_NAME=$(git config --global user.name 2>/dev/null || true)
GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)
[ -z "$GIT_NAME" ]  && read -rp "Dit navn: " GIT_NAME
[ -z "$GIT_EMAIL" ] && read -rp "Din e-mail: " GIT_EMAIL
echo ""

addon_name() { if [ -n "$1" ]; then basename "$1" .sh; else echo "(ingen)"; fi; }
echo "-- Oversigt --"
echo "   Lyd-addon:      $(addon_name "$ADDON_AUDIO")"
echo "   Printer-addon:  $(addon_name "$ADDON_PRINTERS")"
echo "   Perifere:       $(addon_name "$ADDON_PERIPHERALS")"
echo "   Git:            $GIT_NAME <$GIT_EMAIL>"
echo ""
read -rp "Start installationen? [Y/n] " GO
if [[ "$GO" =~ ^[Nn]$ ]]; then
    echo "Afbrudt – intet er installeret."
    exit 0
fi

# Spørg om sudo-adgangskode én gang, og hold den aktiv mens scriptet kører
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

# --------------------------------------------------------------------------
# Installation
# --------------------------------------------------------------------------

echo "== Opdaterer system =="
sudo pacman -Syu --noconfirm

echo "== Sikrer at multilib er aktiveret (nødvendigt for Steam/32-bit programmer) =="
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i "/^#\[multilib\]/,/^#Include/s/^#//" /etc/pacman.conf
    sudo pacman -Sy
fi

echo "== Basisværktøjer til AUR/GitHub-installationer =="
sudo pacman -S --needed --noconfirm git curl wget base-devel gnupg

echo "== Terminalværktøjer (htop, Midnight Commander) =="
sudo pacman -S --needed --noconfirm htop mc

echo "== Installerer paru hvis den mangler =="
if ! command -v paru &> /dev/null; then
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
    cd -
fi

echo "== Git og GitHub CLI =="
sudo pacman -S --needed --noconfirm github-cli
[ -n "$GIT_NAME" ]  && git config --global user.name "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main

echo "== Browser =="
sudo pacman -S --needed --noconfirm chromium
paru -S --needed --noconfirm helium-browser-bin

echo "== Office & PDF =="
sudo pacman -S --needed --noconfirm libreoffice-fresh

echo "== Microsoft-skrifttyper (korrekt layout i Word/PowerPoint-filer) =="
paru -S --needed --noconfirm ttf-ms-fonts
# Carlito/Caladea: gratis erstatninger med samme mål som Calibri/Cambria
sudo pacman -S --needed --noconfirm ttf-carlito ttf-caladea

echo "== Pakkeprogrammer (7z, RAR m.fl. – bruges også af KDE's Ark) =="
sudo pacman -S --needed --noconfirm 7zip unrar

echo "== Noter =="
sudo pacman -S --needed --noconfirm obsidian

echo "== E-mail =="
sudo pacman -S --needed --noconfirm thunderbird

echo "== Print & scan =="
sudo pacman -S --needed --noconfirm cups print-manager system-config-printer sane simple-scan
sudo systemctl enable --now cups.socket

echo "== Printer-drivere (addons) =="
run_addon "$ADDON_PRINTERS"

echo "== Grafik & billedredigering =="
sudo pacman -S --needed --noconfirm krita
sudo pacman -S --needed --noconfirm mpv libraw
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

echo "== Videoredigering =="
sudo pacman -S --needed --noconfirm kdenlive

echo "== Opretter virtuelle lydkanaler (System, Musik, Spil, Kommunikation) =="
install -Dm644 "$CONFIG_DIR/pipewire/50-virtual-sinks.conf" \
    ~/.config/pipewire/pipewire.conf.d/50-virtual-sinks.conf

echo "== Lydstyrke-script til Stream Deck (~/.local/bin/lydstyrke.sh) =="
install -Dm755 "$CONFIG_DIR/scripts/lydstyrke.sh" ~/.local/bin/lydstyrke.sh

echo "== Stream Deck-ikoner (~/.config/opendeck/ikoner) =="
mkdir -p ~/.config/opendeck/ikoner
cp "$CONFIG_DIR/streamdeck/"*.png ~/.config/opendeck/ikoner/

echo "== Lyd-hardware (addons) =="
run_addon "$ADDON_AUDIO"

echo "== Skærmdeling/portals (Discord m.fl. under Wayland) =="
sudo pacman -S --needed --noconfirm xdg-desktop-portal-kde

echo "== Stream Deck (OpenDeck) =="
paru -S --needed --noconfirm opendeck-bin
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -aG input "$USER"

if [ -d "$CONFIG_DIR/opendeck/profiles" ]; then
    echo "== Gendanner OpenDeck-profil (configs/opendeck) =="
    mkdir -p ~/.config/opendeck
    cp -rn "$CONFIG_DIR/opendeck/profiles" ~/.config/opendeck/
    if [ -d "$CONFIG_DIR/opendeck/images" ]; then
        cp -rn "$CONFIG_DIR/opendeck/images" ~/.config/opendeck/
    fi
else
    echo "   (Ingen gemt OpenDeck-profil i configs/opendeck – knapperne sættes op manuelt)"
fi

if [ -f "$CONFIG_DIR/opendeck/plugins.tar.gz" ]; then
    echo "== Installerer OpenDeck-plugins (configs/opendeck/plugins.tar.gz) =="
    mkdir -p ~/.config/opendeck/plugins
    tar -xzf "$CONFIG_DIR/opendeck/plugins.tar.gz" -C ~/.config/opendeck/plugins
else
    echo "   (Ingen plugins.tar.gz i configs/opendeck – installer plugins via OpenDecks Plugins-fane)"
fi

echo "== Perifere enheder (addons) =="
run_addon "$ADDON_PERIPHERALS"

echo "== Musik, udvikling & sikkerhed =="
sudo pacman -S --needed --noconfirm spotify-launcher
paru -S --needed --noconfirm visual-studio-code-bin bitwarden

echo "== Docker =="
sudo pacman -S --needed --noconfirm docker docker-compose docker-buildx
sudo systemctl enable --now docker.service
sudo usermod -aG docker "$USER"

echo "== Portainer (Docker-GUI på https://localhost:9443) =="
# Bundet til 127.0.0.1, så den kun kan nås fra denne PC (Docker går uden om UFW)
if ! sudo docker ps -a --format '{{.Names}}' | grep -qx portainer; then
    sudo docker volume create portainer_data > /dev/null
    sudo docker run -d \
        --name portainer \
        --restart=always \
        -p 127.0.0.1:9443:9443 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:lts
else
    echo "   (Portainer findes allerede – springer over)"
fi

echo "== Firewall (UFW) =="
sudo pacman -S --needed --noconfirm ufw
if [ -f "$CONFIG_DIR/ufw/user.rules" ] && [ -f "$CONFIG_DIR/ufw/user6.rules" ]; then
    echo "   Gendanner gemte regler fra configs/ufw"
    sudo install -m 640 "$CONFIG_DIR/ufw/user.rules"  /etc/ufw/user.rules
    sudo install -m 640 "$CONFIG_DIR/ufw/user6.rules" /etc/ufw/user6.rules
else
    echo "   (Ingen gemte regler – bruger standard: blokér indgående, tillad udgående)"
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
fi
sudo systemctl enable --now ufw.service
sudo ufw --force enable
sudo ufw reload

echo "== Ekstra diske (configs/fstab/fstab-ekstra) =="
if [ -f "$CONFIG_DIR/fstab/fstab-ekstra" ]; then
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        mnt=$(echo "$line" | awk '{print $2}')
        sudo mkdir -p "$mnt"
        if ! grep -qsF "$line" /etc/fstab; then
            echo "$line" | sudo tee -a /etc/fstab > /dev/null
            echo "   Tilføjet til fstab: $mnt"
        fi
    done < "$CONFIG_DIR/fstab/fstab-ekstra"
    sudo systemctl daemon-reload
    sudo mount -a || echo "   ADVARSEL: en eller flere diske kunne ikke monteres – tjek /etc/fstab"
else
    echo "   (Ingen fstab-ekstra – ekstra diske skal monteres manuelt)"
fi

echo "== Flatpak (fallback til programmer uden for pacman/AUR) =="
sudo pacman -S --needed --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --------------------------------------------------------------------------
# Tjekliste over manuelle trin (vises og gemmes i ~/SETUP-TJEKLISTE.md)
# --------------------------------------------------------------------------

CHECKLIST="$HOME/SETUP-TJEKLISTE.md"
{
    echo "# Manuelle trin efter setup ($(date +%Y-%m-%d))"
    echo ""
    echo "- [ ] Log ud og ind igen (eller genstart), så grupperne docker og input virker"
    echo "- [ ] GitHub-login: gh auth login (GitHub.com → HTTPS → login via browser)"
    echo "- [ ] Portainer: åbn https://localhost:9443 og opret admin-bruger"
    echo "      (låst efter 5 min? kør: docker restart portainer)"
    echo "- [ ] Helium som standardbrowser: Systemindstillinger → Standardprogrammer → Webbrowser"
    echo "- [ ] Spotify: kør spotify-launcher én gang for at hente klienten"
    echo "- [ ] Steam: tilføj ekstra spilbiblioteker under Settings → Storage"
    echo "- [ ] Bitwarden: log ind og synkroniser"
    echo "- [ ] Obsidian: åbn din vault igen"
    echo "- [ ] OpenDeck: start den, tjek at profilen Cachy er valgt og knapperne virker"
    if [ ! -f "$CONFIG_DIR/opendeck/plugins.tar.gz" ]; then
        echo "- [ ] OpenDeck: installer PipeWire Audio Control og System Information via Plugins-fanen"
    fi
    if [ -n "$ADDON_AUDIO" ]; then
        echo "- [ ] EDIFIER M90: optisk kabel i SPDIF OUT, vælg optisk input (VOLUME/SOURCE-knappen)"
        echo "- [ ] Arctis: aux i grønt stik, aux-input på basestationen, par headsettet via Bluetooth"
        echo "- [ ] Lyd: kør ~/.local/bin/skift-lyd.sh hojtalere og tjek med wpctl status / pw-top"
    fi
    if [ -n "$ADDON_PRINTERS" ]; then
        echo "- [ ] Printer: tilføj den via print-manager i systembakken"
    fi
    if [ -n "$ADDON_PERIPHERALS" ]; then
        echo "- [ ] Keychron: tilslut med kabel og åbn launcher.keychron.com i Chromium"
    fi
    if [ ! -f "$CONFIG_DIR/fstab/fstab-ekstra" ]; then
        echo "- [ ] Ekstra diske (fx /mnt/Filer) er ikke monteret – tilføj dem i /etc/fstab"
    fi
} > "$CHECKLIST"

echo ""
echo "======================================================"
echo " Færdig! Manuelle trin der mangler:"
echo "======================================================"
cat "$CHECKLIST" | tail -n +3
echo ""
echo "Tjeklisten er gemt i $CHECKLIST"
