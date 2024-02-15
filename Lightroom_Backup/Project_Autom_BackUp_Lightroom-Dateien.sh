#!/bin/bash
# set -x
# Deklaration der Variablen:
source="/mnt/Programme/LIGHTROOM_DATEN/LIGHTROOM_Katalog/"
destination_orange="/media/rwolff/Seagate FOTOGRAFIE Backup 022019/FOTOGRAFIE BackUp/LIGHTROOM_Katalog/"
destination_silver=""
destination_WD3TB=""
ExcireBackUpDatei="Lightroom Classic Catalog-v10 Excire.excat"
ExcireBakDatei="$ExcireBackUpDatei".bak
lrcat=".lrcat"
LRBackUpName="Lightroom Classic Catalog-v10"
LRBackUpDatei="Lightroom Classic Catalog-v10"$lrcat

# Funktion zur Überprüfung das Kopiervorgang richtig verlaufen ist.
chksum() {
b2sum_source=$(b2sum "$source$LRBackUpDatei" | cut -d' ' -f1)
b2sum_dstorg=$(b2sum "$destination_orange$LRBackUpDatei" | cut -d' ' -f1)
[ $b2sum_source = $b2sum_dstorg ] || return 1
}

# Prüfung, ob überhaupt eine Sicherung notwendig ist:
# wenn source = destination, dann exit (?)
chksum
[ $? -eq 0 ] && ??? || ???

# Excire-Daten
cd "$destination_orange"
cp "$ExcireBackUpDatei".old "$ExcireBackUpDatei".old.tmp
cp "$ExcireBakDatei".old "$ExcireBakDatei".old.tmp
rm "$ExcireBackUpDatei"*.old
mv "$ExcireBackUpDatei" "$ExcireBackUpDatei".old
[ $? -eq 0 ] && rm "$ExcireBackUpDatei".old.tmp
mv "$ExcireBakDatei" "$ExcireBakDatei".old
[ $? -eq 0 ] && rm "$ExcireBakDatei".old.tmp
sudo rsync -v "$source$ExcireBackUpDatei" "$destination_orange"
sudo chown rwolff:rwolff "$ExcireBackUpDatei"
sudo rsync -v "$source$ExcireBackUpDatei.bak" "$destination_orange"
sudo chown rwolff:rwolff "$ExcireBackUpDatei.bak"

# Lightroom-Katalog-Backup
# cd "$destination_orange"
cp $source$LRBackUpDatei .


# Finde, ob eine Monatssicherung erstellt wurde. 
aktuellerMonat=$(date +%m-%Y)
bkp=$(find $destination_orange -type f -name "*${aktuellerMonat}*")
[ -z $bkp ] && cp $destination_orange$LRBackUpDatei $destination_orange$LRBackUpName-$(date +%m-%Y)$lrcat

# test mithilfe date +%m und Dateinamen

# Wenn ja, dann benenne aktuelle Backup-Datei um (Endung .tmp) <= muss dann danach gelöscht werden.
#mv "$LRBackUpDatei"$lrcat "$LRBackUpDatei".tmp
#mv "$LRBackUpDatei"$lrcat "$LRBackUpDatei"-$(date +%Y-%m)$lrcat

 
# Wenn nicht benenne aktuelle Backup-Datei um
#mv "$LRBackUpDatei" "$LRBackUpDatei".old
