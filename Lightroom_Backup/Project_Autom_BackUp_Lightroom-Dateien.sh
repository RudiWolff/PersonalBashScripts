#!/bin/bash

# Deklaration der Variablen:
source="/mnt/Programme/LIGHTROOM_DATEN/LIGHTROOM_Katalog/"
destination_orange="/media/rwolff/Seagate FOTOGRAFIE Backup 022019/FOTOGRAFIE BackUp/LIGHTROOM_Katalog/"
destination_silver="/media/rwolff/Seagate BACKUP Drive/FOTOGRAFIE BackUp/LIGHTROOM_Katalog/"
destination_WD3TB=""
ExcireBackUpDatei="Lightroom Classic Catalog-v13 Excire.excat"
ExcireBakDatei="$ExcireBackUpDatei".bak
lrcat=".lrcat"
LRBackUpName="Lightroom Classic Catalog-v13"
LRBackUpDatei="Lightroom Classic Catalog-v13"$lrcat
aktuellerMonat=$(date +%Y-%m)

### --- Funktionen --- ###
==========================

# Funktion zur Überprüfung das Kopiervorgang richtig verlaufen ist.
# Braucht als Argumente die Quelle, das Ziel und den Namen der Datei
chksum() {
    b2sum_source=$(b2sum "$1$3" | cut -d' ' -f1)
    b2sum_dstorg=$(b2sum "$2$3" | cut -d' ' -f1)
    [ $b2sum_source = $b2sum_dstorg ] || return 1
}

# Funktion öffnet Fenster-Box mit Warning/Error/Info/Frage
fensterbox () {
    zenity --$1  --title="Lightroom Daten Backup" --text="$2"
}

# Excire-Daten-Backup
Excire-Daten-Backup () {
    rm "$3"*.old
    mv "$3" "$3".old
    [ $? -eq 0 ] || fensterbox error "Error: Kopiervorgang fehlgeschlagen."
    mv "$3.bak" "$3.bak".old
    [ $? -eq 0 ] || fensterbox error "Error: Kopiervorgang fehlgeschlagen."
    rsync -v "$1$3" "$2"
    [ $? -eq 0 ] || fensterbox error "Error: Sync-Vorgang fehlgeschlagen."
    chown rwolff:rwolff "$3"
    rsync -v "$1$3.bak" "$2"
    [ $? -eq 0 ] || fensterbox error "Error: Sync-Vorgang fehlgeschlagen."
    chown rwolff:rwolff "$3.bak"
    fensterbox info "Excire-Daten-Backup auf\n${2}\nabgeschlossen." &
}

# Lightroom-Katalog-Backup
Lightroom-Katalog-Backup () {
    rsync -v "$1$3" "$2"
    if [ $? -eq 0 ];then
        fensterbox info "Lightroom-Katalog-Backup auf ${destination} abgeschlossen.\n$(date +%d.%m.%Y' '%R)" &
    else
        fensterbox error "Sync-Vorgang auf ${destination} fehlgeschlagen.\n$(date +%d.%m.%Y' '%R)"
    fi
    chown rwolff:rwolff "$LRBackUpDatei"
}

# Monats-Sicherung
Monats-Sicherung () {
    bkp=$(find $1 -type f -name "*$2*")
    [ -z $bkp ] && cp "$1$3.lrcat" "$1$3-$(date +%Y-%m).lrcat"

}

### --- Haupt-Programm --- ###
==============================

# For-Schleife geht durch die 3 HDDs und führt die BackUps durch
for destination in "$destination_orange" "$destination_silver" "$destination_WD3TB"; do

# Prüfung, ob die jeweilige HDD bereits gemountet ist.
[ -d "$destination" ] || fensterbox question "Backup-Medium\n${destination}\neinstecken bitte\!\nSobald das Sicherungsmedium gemountet wurde,\nbitte mit 'Ja' bestätigen."
if [ $? -ne 0 ];then
    fensterbox question "Soll das Backup-Vorhaben abgebrochen werden?"
    [ $? -eq 0 ] && exit
else
    # Prüfung, ob überhaupt eine Sicherung notwendig ist:
    # wenn source = destination, dann wird Backup abgebrochen,
    # keine weiteren Aktionen notwendig.
    chksum "$source" "$destination" "$LRBackUpDatei"
    if [ $? -eq 0 ]; then
        fensterbox info "${LRBackUpDatei} auf ${source} ist bereits auf ${destination_orange} gesichert." &
    else
        # Wechsel auf das Ziel-Verzeichnis
        cd "$destination"
        
        Excire-Daten-Backup $source $destination $ExcireBackUpDatei
        
        Lightroom-Katalog-Backup $source $destination $LRBackUpDatei
        
        # Finde, ob eine Monatssicherung erstellt wurde. 
        Monats-Sicherung $destination $aktuellerMonat $LRBackUpName
#        bkp=$(find $destination -type f -name "*${aktuellerMonat}*")
#        [ -z $bkp ] && cp "$destination$LRBackUpDatei" "$destination$LRBackUpName-$(date +%Y-%m)$lrcat"
    fi
fi
done
