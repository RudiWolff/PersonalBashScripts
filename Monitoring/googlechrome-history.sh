#! /bin/bash

# Dieses Skript dient dazu, die Google Chrome History Datei zu kopieren, 
# so dass sie auch eingesehen werden kann, sollte der User seine History
# im Browser gelöscht haben.

# Überprüfung, ob root am Start ist:
if [ $EUID -ne 0 ];then
    echo >&2 "ERROR: Skript muss als root ausgeführt werden."
    exit 1
fi

# Überprüfung, ob b3sum installiert ist:
which b3sum >& /dev/null
[ $? -ne 0 ] && apt-get install -y b3sum

# Variablen:
# Google Chrome History Path:
gchp="/home/Daniel/.var/app/com.google.Chrome/config/google-chrome/Profile 1/History"
# Letzte kopierte History-Datei:
oldHistFile="/home/rwolff/Documentos/log/History/History"

# Vergleich der älteren History-Datei mit der aktuellen im History Path $gchp
# und evtl. Sicherung der älteren Datei
if [ -f $oldHistFile ]; then
    checksumOldHist=$(b3sum "${oldHistFile}" | cut -d' ' -f1)
    checksum_gchp=$(b3sum "${gchp}" | cut -d' ' -f1)
    if [ "$checksumOldHist" != "$checksum_gchp" ]; then
        cp $oldHistFile $(date +%F'_'%T)_$oldHistFile
    fi
fi

# Kopie der aktuellen History-Datei in das log-History-Verzeichnis
cp "$gchp" "$oldHistFile"
chown rwolff:rwolff /home/rwolff/Documentos/log/History/History
