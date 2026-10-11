# Firewall (UFW)

`user.rules` og `user6.rules` er UFW's egne regelfiler (IPv4/IPv6). `setup.sh` lægger dem
i `/etc/ufw/` og slår firewallen til. Findes de ikke, slås UFW til med standardregler
(alt indgående blokeres, alt udgående tilladt).

## Gem reglerne (før formatering)

Fra repo-mappen:

    sudo cp /etc/ufw/user.rules /etc/ufw/user6.rules configs/ufw/
    sudo chown "$USER": configs/ufw/user.rules configs/ufw/user6.rules
