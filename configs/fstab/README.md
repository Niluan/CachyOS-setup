# Ekstra diske (fstab)

`fstab-ekstra` indeholder fstab-linjer til diske ud over systemdisken (fx `/mnt/Filer`).
`setup.sh` tilføjer linjerne til `/etc/fstab` (hvis de ikke allerede findes), opretter
monteringspunkterne og monterer diskene.

## Gem linjerne (før formatering)

Fra repo-mappen:

    grep "/mnt/Filer" /etc/fstab > configs/fstab/fstab-ekstra

Linjen bruger diskens UUID, så den peger på samme disk efter geninstallation.
Kun systemdisken formateres – data på `/mnt/Filer` bevares.
