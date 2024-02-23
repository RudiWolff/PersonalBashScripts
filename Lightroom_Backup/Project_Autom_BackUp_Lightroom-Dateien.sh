#!/bin/bash

# Deklaration der Variablen:
### Für Test-Zwecke
source="/home/rwolff/testing/sou rce/"
destination_orange="/home/rwolff/testing/destination orange/"
destination_silver="/home/rwolff/testing/destination silver/"
destination_WD3TB="/home/rwolff/testing/destination WD3TB/"

#source="/mnt/Programme/LIGHTROOM_DATEN/LIGHTROOM_Katalog/"
#destination_orange="/media/rwolff/Seagate FOTOGRAFIE Backup 022019/FOTOGRAFIE BackUp/LIGHTROOM_Katalog/"
#destination_silver="/media/rwolff/Seagate BACKUP Drive/FOTOGRAFIE BackUp/LIGHTROOM_Katalog/"
#destination_WD3TB="/media/rwolff/WD SONSTIGE DATEN 092014/FOTOGRAFIE_BackUp/LIGHTROOM_Katalog/"
ExcireBackUpDatei="Lightroom Classic Catalog-v10 Excire.excat"
ExcireBakDatei="$ExcireBackUpDatei".bak
lrcat=".lrcat"
LRBackUpName="Lightroom Classic Catalog-v10"
LRBackUpDatei="$LRBackUpName"$lrcat
LREinstellungen="Ajustes de Lightroom"
aktuellerMonat=$(date +%Y-%m)

### --- Funktionen --- ###
#========================#

# Funktion zur Überprüfung das Kopiervorgang richtig verlaufen ist.
# Braucht als Argumente die Quelle, das Ziel und den Namen der Datei
chksum() {
    chksum_source=$(b3sum "$1$3" | cut -d' ' -f1)
    chksum_dstorg=$(b3sum "$2$3" | cut -d' ' -f1)
    [ $chksum_source = $chksum_dstorg ] || return 1
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
    rsync -ah --info=progress2 "$1$3" "$2"
    [ $? -eq 0 ] || fensterbox error "Error: Sync-Vorgang fehlgeschlagen."
#    chown rwolff:rwolff "$3"
    rsync -ah --info=progress2 "$1$3.bak" "$2"
    [ $? -eq 0 ] || fensterbox error "Error: Sync-Vorgang fehlgeschlagen."
#    chown rwolff:rwolff "$3.bak"
    fensterbox info "Excire-Daten-Backup auf\n${2}\nabgeschlossen." &
}

# Lightroom-Katalog-Backup
Lightroom-Katalog-Backup () {
    mv "$2$3" "$2$3".old
    rsync -ah --info=progress2 "$1$3" "$2"
    if [ $? -eq 0 ];then
        fensterbox info "Lightroom-Katalog-Backup auf ${destination} abgeschlossen.\n$(date +%d.%m.%Y' '%R)" &
    else
        fensterbox error "Sync-Vorgang auf ${destination} fehlgeschlagen.\n$(date +%d.%m.%Y' '%R)"
    fi
#    chown rwolff:rwolff "$LRBackUpDatei"
}

# Monats-Sicherung
Monats-Sicherung () {
    # Finde, ob eine Monatssicherung erstellt wurde. 
    bkp=$(find "$1" -type f -name "*$2*")
    [ -z "$bkp" ] && cp "$1$3.lrcat" "$1$3-$2.lrcat"

}

# Sicherung der Lightroom-Einstellungen
Ajustes-Sicherung () {
    rsync -ah --info=progress2 "$1$3/" "$2$3"
}

### --- Haupt-Programm --- ###
#============================#

# For-Schleife geht durch die 3 HDDs und führt die BackUps durch
for destination in "$destination_orange" "$destination_silver" "$destination_WD3TB"; do

# Prüfung, ob die jeweilige HDD bereits gemountet ist.
[ -d "$destination" ] || fensterbox question "Backup-Medium\n${destination}\neinstecken bitte\!\nSobald das Sicherungsmedium gemountet wurde,\nbitte mit 'Ja' bestätigen."
if [ $? -ne 0 ];then
    fensterbox question "Soll das Backup-Vorhaben für "$destination" abgebrochen werden?"
    [ $? -eq 0 ] && exit
else
    # Prüfung, ob überhaupt eine Sicherung notwendig ist:
    # wenn source = destination, dann wird Backup abgebrochen,
    # keine weiteren Aktionen notwendig.
    chksum "$source" "$destination" "$LRBackUpDatei"
    if [ $? -eq 0 ]; then
        fensterbox info "${LRBackUpDatei} auf ${source} ist bereits auf ${destination} gesichert." &
    else
        # Wechsel auf das Ziel-Verzeichnis
        cd "$destination"
        
        Excire-Daten-Backup "$source" "$destination" "$ExcireBackUpDatei"
        
        Lightroom-Katalog-Backup "$source" "$destination" "$LRBackUpDatei"
        
        Monats-Sicherung "$destination" $aktuellerMonat "$LRBackUpName"
        
        Ajustes-Sicherung "$source" "$destination" "$LREinstellungen"
        
    fi
fi
done
