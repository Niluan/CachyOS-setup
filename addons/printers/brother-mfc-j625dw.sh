#!/bin/bash
# Addon: Brother MFC-J625DW (print + scan)
# Denne fil er selvstændig og kaldes af setup.sh, men kan også køres alene:
#   bash addons/printers/brother-mfc-j625dw.sh
set -e

echo ""
echo ">> Installerer Brother MFC-J625DW print- og scannerdrivere..."

paru -S --needed --noconfirm brother-mfc-j625dw brscan4

read -rp "Indtast printerens IP-adresse (fx 192.168.1.50), eller tryk Enter for at springe over: " PRINTER_IP

if [ -n "$PRINTER_IP" ]; then
    echo ">> Tilføjer scanner med IP $PRINTER_IP..."
    brsaneconfig4 -a name=MFC-J625DW model=MFC-J625DW ip="$PRINTER_IP" || \
        echo "!! Kunne ikke tilføje scanneren automatisk. Kør evt. kommandoen manuelt senere."

    echo ""
    echo ">> Driveren er installeret. Tilføj selve printeren i 'print-manager' med en af disse adresser:"
    echo "   ipp://$PRINTER_IP/ipp/print"
    echo "   socket://$PRINTER_IP:9100   (fallback, hvis IPP ikke virker)"
else
    echo ">> Sprunget over IP-opsætning. Husk selv at tilføje printer/scanner senere med:"
    echo "   brsaneconfig4 -a name=MFC-J625DW model=MFC-J625DW ip=<PRINTER-IP>"
fi
