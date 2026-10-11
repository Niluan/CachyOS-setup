# OpenDeck-profil

Her gemmes OpenDeck-profilen (knapper, kommandoer, ikonvalg), så `setup.sh`
kan lægge den tilbage efter en geninstallation.

## Gem profilen (før formatering)

Luk OpenDeck helt, og kør fra repo-mappen:

    cp -r ~/.config/opendeck/profiles ~/.config/opendeck/images configs/opendeck/

Gem også de plugins, profilen bruger (PipeWire Audio Control og System Information),
som én samlet fil:

    tar -czf configs/opendeck/plugins.tar.gz -C ~/.config/opendeck/plugins \
        com.sfgrimes.pipewire-audio.sdPlugin me.amankhanna.oasystem.sdPlugin

Commit og push bagefter.

## Gendannelse

`setup.sh` kopierer `profiles/` og `images/` til `~/.config/opendeck/` og pakker
`plugins.tar.gz` ud i `~/.config/opendeck/plugins/`, lige efter OpenDeck er installeret
(overskriver ikke eksisterende profiler).

Bemærk:
- Profilerne ligger i en mappe opkaldt efter Stream Deck'ens serienummer
  (fx `sd-CL15K1A01137`), så de passer kun til samme Stream Deck.
- Run Command-knapperne peger på `/home/<brugernavn>/.local/bin/...`, og ikonerne
  på `ikoner/...` (relativt til `~/.config/opendeck/`). Brug samme brugernavn
  ved geninstallation, ellers skal stierne rettes i profilen.
- Mangler `plugins.tar.gz`, skal plugins installeres via *Plugins*-fanen i OpenDeck.
  Plugins i arkivet opdateres ikke automatisk – tjek *Plugins*-fanen for opdateringer.
