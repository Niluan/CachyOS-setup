# CachyOS Setup

Personligt install-script til at genopsætte min CachyOS-arbejds-PC (KDE Plasma) fra bunden efter en formatering. Kør scriptet, og systemet er klar til brug uden at skulle huske pakkenavne eller søge information andre steder.

## Brug

```bash
git clone https://github.com/Niluan/cachyos-setup.git
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
│   │   ├── 50-virtual-sinks.conf     # De 4 virtuelle lydkanaler
│   │   └── 60-optisk-hojtalere.conf  # "Højtalere" på den optiske udgang (addons/audio)
│   ├── wireplumber/
│   │   └── 51-lyd-setup.conf         # Profil, navne, prioriteter, Bluetooth-mic (addons/audio)
│   ├── scripts/
│   │   ├── skift-lyd.sh              # Stream Deck-knap: skift højtalere/headset
│   │   └── lydstyrke.sh              # Stream Deck-knapper: op/ned pr. kanal (0–100 %)
│   ├── opendeck/
│   │   ├── README.md                 # Sådan gemmes/gendannes OpenDeck-profilen
│   │   ├── profiles/                 # OpenDeck-profil (gemmes manuelt før formatering)
│   │   └── images/                   # Billeder tilhørende profilen
│   ├── streamdeck/
│   │   └── *.png                     # Ikoner: headset/højtalere + pile i grøn/rød
│   └── udev/
│       └── 99-keychron.rules         # Bruges af addons/peripherals/keychron.sh
├── addons/
│   ├── audio/
│   │   └── lyd-hojtalere-headset.sh  # Lyd: EDIFIER M90 (optisk) + Arctis Pro Wireless
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
| Stream Deck | OpenDeck (styres med **PipeWire Audio Control**-pluginnet + `skift-lyd.sh`) |
| Musik | Spotify (spotify-launcher) |
| Udvikling | Visual Studio Code |
| Sikkerhed | Bitwarden |
| Fallback | Flatpak + Flathub |

## Manuelle trin efter kørsel

Disse kan ikke automatiseres sikkert (afhænger af hardware-model, GUI-interaktion eller personligt login) og skal gøres én gang selv:

- [ ] **Log ud/ind** (eller genstart), så `input`-gruppen (Stream Deck) og evt. udev-ændringer træder i kraft.
- [ ] **Steam**: tilføj dine øvrige diske som ekstra bibliotek under *Settings → Storage*.
- [ ] **Spotify**: kør `spotify-launcher` i terminalen første gang for at hente selve klienten.
- [ ] **OpenDeck – plugins**: installer via *Plugins*-fanen: **PipeWire Audio Control** (lydkanalerne), **System Information** (CPU/RAM), **Essentials for Spotify** og **Home Assistant**. Plugins følger ikke med profilen.
- [ ] **OpenDeck – profil**: gendannes automatisk af `setup.sh`, hvis den er gemt i `configs/opendeck/` (se `configs/opendeck/README.md`). Start OpenDeck, vælg profilen (fx **Claude**) i dropdown'en under enhedsnavnet, og tjek at knapperne og ikonerne er der. Er profilen ikke gemt, så opsæt knapperne manuelt:
    - **Lydkanaler**: PipeWire Audio Control-knapper til `OSSink`, `MusicSink`, `GameSink`, `CommsSink` og mikrofon.
    - **Skift højtalere/headset** (kræver `addons/audio`): en **Toggle Action** med to **Run Command**-handlinger: `/home/<brugernavn>/.local/bin/skift-lyd.sh headset` (state 1, billede `hojtalere-tekst.png`) og `/home/<brugernavn>/.local/bin/skift-lyd.sh hojtalere` (state 2, billede `headset-tekst.png`).
    - **Op/ned-pile**: **Run Command** med `/home/<brugernavn>/.local/bin/lydstyrke.sh <Kanal> op` / `ned` (Kanal = OSSink, MusicSink, GameSink, CommsSink, master eller mic) og chevron-ikonerne. Audio-pluginnets egne knapper tegner selv deres billede og kan ikke få egne ikoner.
    - Ikonerne ligger i `~/.config/opendeck/ikoner/` (venstreklik på billedet under *Edit*; vis skjulte mapper med Ctrl+H). De skal ligge inde i `~/.config/opendeck/`, da OpenDeck kun må vise billeder derfra.
- [ ] **EDIFIER M90**: optisk kabel i **SPDIF OUT** bagpå PC'en, og vælg **optisk** som input (tryk på VOLUME/SOURCE-knappen, fjernbetjeningen eller ConneX-appen). USB-C-kablet skal ikke sidde i.
- [ ] **Arctis Pro Wireless**: aux-kablet i det **grønne** stik (LINE OUT). Vælg aux/line som input på basestationen, og par headsettet via Bluetooth i KDE (bruges til mikrofonen).
- [ ] **Print & scan**: tilføj din printer via `print-manager` i systembakken.
- [ ] **Keychron K17 Max & M6 8K**: tilslut med **kabel** og åbn [launcher.keychron.com](https://launcher.keychron.com) i Chromium for at konfigurere taster/DPI/polling rate. Firefox understøttes ikke (mangler WebHID).
- [ ] **Bitwarden**: log ind og synkroniser dit hvælv.

## Noter og forbehold

- **FerrumPix** hentes direkte fra GitHub som AppImage, da den ikke findes i officielle repos eller AUR. Linket peger på "latest", så det altid henter nyeste version, når scriptet køres igen.
- **Multilib-tjekket** retter automatisk, hvis `[multilib]`-sektionen i `/etc/pacman.conf` ved et uheld er blevet deaktiveret (kan ske ved forkert håndtering af `.pacnew`-filer).
- **xdg-desktop-portal-kde** er inkluderet for skærmdeling i Discord m.fl., relevant hvis/når man kører Wayland-session.
- Scriptet er personligt tilpasset og forudsætter **KDE Plasma**. Kør det ikke blindt på et andet skrivebordsmiljø uden at tjekke indholdet igennem først.
- AUR-pakker er community-vedligeholdte og ikke officielt reviewet af Arch — det er god praksis at kigge scriptet igennem en gang imellem for at sikre det stadig gør, hvad man forventer.

## Før formatering

1. Luk OpenDeck helt, og gem profilen i repo'et: `cp -r ~/.config/opendeck/profiles ~/.config/opendeck/images configs/opendeck/`
2. Commit og push repo'et.

## Lydkanaler (PipeWire)

`configs/pipewire/50-virtual-sinks.conf` opretter 4 virtuelle sinks: System (`OSSink`), Musik (`MusicSink`), Spil (`GameSink`) og Kommunikation (`CommsSink`) via `libpipewire-module-loopback`, som automatisk ruter til standard-outputenheden. De styres direkte fra Stream Deck via **PipeWire Audio Control**-pluginnet i OpenDeck, eller manuelt via KDE's indbyggede lyd-widget i systembakken (Playback-fanen). Kanalerne har lav prioritet (`priority.session = 100`), så de aldrig selv bliver valgt som standard-output.

### Højtalere/headset-skift (`addons/audio/lyd-hojtalere-headset.sh`)

Hardware-specifik opsætning til Asus ROG Strix X570-E + EDIFIER M90 + SteelSeries Arctis Pro Wireless:

```
App → System/Musik/Spil/Kommunikation → standard-output
                                          ├── Højtalere: optisk udgang (SPDIF) → EDIFIER M90
                                          └── Headset:   grønt stik → aux → Arctis basestation
Mikrofon ← Arctis-headset via Bluetooth (HFP)
```

Bundkortets analoge og optiske udgang er to separate enheder på samme lydkort. WirePlumber kører kortet i analog stereo (headset), mens den optiske udgang åbnes direkte som en selvstændig sink (højtalere), så begge kan bruges samtidig.

| Fil | Installeres til | Gør |
|---|---|---|
| `configs/pipewire/60-optisk-hojtalere.conf` | `~/.config/pipewire/pipewire.conf.d/` | Opretter **Højtalere** på `iec958:CARD=Generic,DEV=0`. Højeste prioritet, så den er standard ved opstart. Holdes åben, så M90 ikke går i standby eller klipper starten af lyde. |
| `configs/wireplumber/51-lyd-setup.conf` | `~/.config/wireplumber/wireplumber.conf.d/` | Låser bundkortet i analog stereo og kalder den **Headset**, låser Arctis i HFP (mikrofon), gør Bluetooth-mic til standard-input og forhindrer at Bluetooth-udgangen bliver standard. |
| `configs/scripts/skift-lyd.sh` | `~/.local/bin/` | Skifter standard-output mellem Højtalere og Headset. Kaldes fra en Toggle Action i OpenDeck. |

Addon'et slår også ALSA-kontrollen `IEC958` til og gemmer den med `alsactl store`.

**Fejlfinding:**
- Tjek opsætningen med `wpctl status` – der skal være stjerne ved **Højtalere** (Sinks) og Arctis-mikrofonen (Sources).
- Ingen lyd i højtalerne: tjek at M90 står på optisk input (tryk på VOLUME/SOURCE-knappen for at skifte input, og at USB-C-kablet ikke sidder i), og at `amixer -c Generic sget IEC958` viser `[on]`. Test direkte med `speaker-test -D iec958:CARD=Generic -c 2 -t wav` (stop PipeWire-sinken først, hvis den melder "busy": `systemctl --user stop pipewire pipewire.socket`).
- Knas/skratten på alle udgange: kør `pw-top` og tjek, at der kun findes ét sæt `OSSink`/`MusicSink`/`GameSink`/`CommsSink` og ingen ekstra `loopback-…`-noder. Dubletter kommer typisk fra gamle `pactl load-module`-scripts i `~/.config/autostart/` (fx `setup-sinks.desktop`).
- Gule udråbstegn på knapper i OpenDeck: billedfilen findes ikke, eller den ligger uden for `~/.config/opendeck/` (OpenDeck viser kun billeder derfra).
- Opfører profiler/standardvalg sig mærkeligt, kan WirePlumbers gemte valg nulstilles: `rm -rf ~/.local/state/wireplumber && systemctl --user restart wireplumber` (nulstiller også gemte lydstyrker).
- Står headsettet ikke i HFP efter genstart, så vælg profilen *Headset Head Unit (HFP)* én gang i KDE's lydindstillinger – WirePlumber husker den.
- Sæt lydstyrken på **Headset** højt (90–100 %) og styr lydstyrken på basestationen – det giver mindst baggrundssus på aux-forbindelsen.
- USB-C til M90 blev forsøgt, men højtalerne koblede gentagne gange fra (`USB disconnect`, `error -71`) på flere porte. Kan evt. prøves igen efter BIOS- eller højtaler-firmwareopdatering.

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
| `addons/audio/` | Lydhardware og routing (fx `lyd-hojtalere-headset.sh`) |
| `addons/printers/` | Printer-/scannerdrivere (fx `brother-mfc-j625dw.sh`) |
| `addons/peripherals/` | Tastatur/mus/andre HID-enheder (fx `keychron.sh`) |

**Sådan tilføjer du en ny addon:**
1. Kopiér en eksisterende fil i den relevante mappe som skabelon (eller opret en ny mappe under `addons/`, hvis det er en helt ny kategori — husk i så fald at tilføje et `run_addon_menu`-kald for den i `setup.sh`).
2. Giv den nye fil et beskrivende navn — navnet uden `.sh` er det, der vises i menuen.
3. Tilpas indholdet (pakkenavne, IP-adresser, udev-regler osv.) til den nye enhed.

**Sådan fjerner du en addon:** slet blot filen fra mappen.

**Sådan kører du en enkelt addon isoleret** (uden hele `setup.sh`):
```bash
bash addons/audio/lyd-hojtalere-headset.sh
bash addons/printers/brother-mfc-j625dw.sh
bash addons/peripherals/keychron.sh
```

## Keychron-enheder

Konfigureres via **addons/peripherals/keychron.sh**, som installerer `configs/udev/99-keychron.rules` — en udev-regel, der giver browseren adgang til at læse/skrive til Keychron-enheder via WebHID (vendor ID `3434`), som ellers er blokeret som standard på Linux. Dækker både K17 Max (tastatur) og M6 8K (mus), tilsluttet enten via kabel eller 2.4GHz-dongle. Selve konfigurationen (taster, DPI, polling rate) sker via [launcher.keychron.com](https://launcher.keychron.com) i Chromium.
