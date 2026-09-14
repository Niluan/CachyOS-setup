# CachyOS Setup

Personligt install-script til at genopsætte min CachyOS-arbejds-PC (KDE Plasma) fra bunden efter en formatering. Kør scriptet, og systemet er klar til brug uden at skulle huske pakkenavne eller søge information andre steder.

## Brug

```bash
git clone https://github.com/DIT-BRUGERNAVN/cachyos-setup.git
cd cachyos-setup
chmod +x setup.sh
./setup.sh
```

Scriptet beder om `sudo`-adgangskode undervejs. Kør det fra en frisk CachyOS KDE Plasma-installation.

## Mappestruktur

```
cachyos-setup/
├── setup.sh                          # Hoved-installationsscript
├── configs/
│   ├── pipewire/
│   │   └── 50-virtual-sinks.conf     # De 4 virtuelle lydkanaler
│   └── udev/
│       └── 99-keychron.rules         # Bruges af addons/peripherals/keychron.sh
├── addons/
│   ├── printers/
│   │   └── brother-mfc-j625dw.sh     # Printer-driver, selvstændigt script
│   └── peripherals/
│       └── keychron.sh               # Keychron K17 Max + M6 8K
└── README.md
```

## Hvad installeres

| Kategori | Programmer |
|---|---|
| System | multilib aktiveret, git, curl, wget, base-devel, gnupg, paru |
| Browser | Chromium (native pacman, ikke Flatpak — nødvendigt for Keychron Launcher) |
| Office & PDF | LibreOffice (Writer/Calc/Impress/**Draw** til PDF-redigering) |
| E-mail | Thunderbird |
| Print & scan | CUPS, print-manager, system-config-printer, SANE, Simple Scan |
| Grafik | Krita, FerrumPix (RAW-editor, hentes som AppImage fra GitHub) |
| Gaming | Steam, Discord |
| 3D print & CAD | OrcaSlicer, FreeCAD |
| Lyd & video | PipeWire (+pulse/alsa/jack), WirePlumber, VLC, DVD/codec-pakker |
| Stream Deck | OpenDeck (styres med **PipeWire Audio Control**-pluginnet) |
| Musik | Spotify (spotify-launcher) |
| Udvikling | Visual Studio Code |
| Sikkerhed | Bitwarden |
| Fallback | Flatpak + Flathub |

## Manuelle trin efter kørsel

Disse kan ikke automatiseres sikkert (afhænger af hardware-model, GUI-interaktion eller personligt login) og skal gøres én gang selv:

- [ ] **Log ud/ind** (eller genstart), så `input`-gruppen (Stream Deck) og evt. udev-ændringer træder i kraft.
- [ ] **Steam**: tilføj dine øvrige diske som ekstra bibliotek under *Settings → Storage*.
- [ ] **Spotify**: kør `spotify-launcher` i terminalen første gang for at hente selve klienten.
- [ ] **OpenDeck**: installer **PipeWire Audio Control**-pluginnet via *Plugins*-fanen, og opsæt knapperne til System/Musik/Spil/Kommunikation manuelt (se skærmbillede-reference i dit eget setup).
- [ ] **Print & scan**: tilføj din printer via `print-manager` i systembakken.
- [ ] **Keychron K17 Max & M6 8K**: tilslut med **kabel** og åbn [launcher.keychron.com](https://launcher.keychron.com) i Chromium for at konfigurere taster/DPI/polling rate. Firefox understøttes ikke (mangler WebHID).
- [ ] **Bitwarden**: log ind og synkroniser dit hvælv.
- [ ] **LibreOffice Draw**: bruges til PDF-redigering — ingen separat installation nødvendig.

## Noter og forbehold

- **FerrumPix** hentes direkte fra GitHub som AppImage, da den ikke findes i officielle repos eller AUR. Linket peger på "latest", så det altid henter nyeste version, når scriptet køres igen.
- **Multilib-tjekket** retter automatisk, hvis `[multilib]`-sektionen i `/etc/pacman.conf` ved et uheld er blevet deaktiveret (kan ske ved forkert håndtering af `.pacnew`-filer).
- **xdg-desktop-portal-kde** er inkluderet for skærmdeling i Discord m.fl., relevant hvis/når man kører Wayland-session.
- Scriptet er personligt tilpasset og forudsætter **KDE Plasma**. Kør det ikke blindt på et andet skrivebordsmiljø uden at tjekke indholdet igennem først.
- AUR-pakker er community-vedligeholdte og ikke officielt reviewet af Arch — det er god praksis at kigge scriptet igennem en gang imellem for at sikre det stadig gør, hvad man forventer.

## Lydkanaler (PipeWire)

`configs/pipewire/50-virtual-sinks.conf` opretter 4 virtuelle sinks (System, Musik, Spil, Kommunikation) via `libpipewire-module-loopback`, som automatisk ruter til standard-outputenheden. De styres direkte fra Stream Deck via **PipeWire Audio Control**-pluginnet i OpenDeck, eller manuelt via KDE's indbyggede lyd-widget i systembakken (Playback-fanen).

## Addon-systemet (`addons/`)

Alt der er **hardware-specifikt eller personligt** (printere, tastatur/mus m.m.) ligger **uden for** `setup.sh` som selvstændige scripts i undermapper til `addons/`. Det gør det nemt at tilføje, redigere eller fjerne enkeltdele uden at røre hovedscriptet.

**Sådan fungerer det:**
- `setup.sh` bruger én genbrugelig funktion (`run_addon_menu`) til at scanne en addon-mappe for `.sh`-filer.
- Er der **ingen filer**, springes trinnet automatisk over.
- Er der **én fil**, spørges du kun om du vil installere den.
- Er der **flere filer**, får du en nummereret liste at vælge fra.

**Nuværende addon-kategorier:**

| Mappe | Indhold |
|---|---|
| `addons/printers/` | Printer-/scannerdrivere (fx `brother-mfc-j625dw.sh`) |
| `addons/peripherals/` | Tastatur/mus/andre HID-enheder (fx `keychron.sh`) |

**Sådan tilføjer du en ny addon:**
1. Kopiér en eksisterende fil i den relevante mappe som skabelon (eller opret en ny mappe under `addons/`, hvis det er en helt ny kategori — husk i så fald at tilføje et `run_addon_menu`-kald for den i `setup.sh`).
2. Giv den nye fil et beskrivende navn — navnet uden `.sh` er det, der vises i menuen.
3. Tilpas indholdet (pakkenavne, IP-adresser, udev-regler osv.) til den nye enhed.

**Sådan fjerner du en addon:** slet blot filen fra mappen.

**Sådan kører du en enkelt addon isoleret** (uden hele `setup.sh`):
```bash
bash addons/printers/brother-mfc-j625dw.sh
bash addons/peripherals/keychron.sh
```

## Keychron-enheder

Konfigureres via **addons/peripherals/keychron.sh**, som installerer `configs/udev/99-keychron.rules` — en udev-regel, der giver browseren adgang til at læse/skrive til Keychron-enheder via WebHID (vendor ID `3434`), som ellers er blokeret som standard på Linux. Dækker både K17 Max (tastatur) og M6 8K (mus), tilsluttet enten via kabel eller 2.4GHz-dongle. Selve konfigurationen (taster, DPI, polling rate) sker via [launcher.keychron.com](https://launcher.keychron.com) i Chromium.
