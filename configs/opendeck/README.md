# OpenDeck-profil

Her gemmes OpenDeck-profilen (knapper, kommandoer, ikonvalg), så `setup.sh`
kan lægge den tilbage efter en geninstallation.

## Gem profilen (før formatering)

Luk OpenDeck helt, og kør fra repo-mappen:

    cp -r ~/.config/opendeck/profiles ~/.config/opendeck/images configs/opendeck/

Commit og push bagefter.

## Gendannelse

`setup.sh` kopierer `profiles/` og `images/` til `~/.config/opendeck/`, lige efter
OpenDeck er installeret (overskriver ikke eksisterende filer).

Bemærk:
- Profilerne ligger i en mappe opkaldt efter Stream Deck'ens serienummer
  (fx `sd-CL15K1A01137`), så de passer kun til samme Stream Deck.
- Run Command-knapperne peger på `/home/<brugernavn>/.local/bin/...`, og ikonerne
  på `ikoner/...` (relativt til `~/.config/opendeck/`). Brug samme brugernavn
  ved geninstallation, ellers skal stierne rettes i profilen.
- Plugins følger IKKE med og skal installeres via *Plugins*-fanen i OpenDeck
  (se README i roden).
