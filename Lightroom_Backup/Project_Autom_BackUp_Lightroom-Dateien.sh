#!/bin/bash
# Some logging. See end of script. 
# ==> ~/Documentos/log/LR_Backup.log
logDatei="/home/rwolff/Documentos/log/LR_Backup.log"

(
# Trennungslinie zwischen den einzelnen Backup-Events in der Log-Datei
echo
for ((i=0;i<70;i++));do 
    echo -n "*";
done
echo
echo -e "Beginn des Backups am $(date +%F' um '%R)"
for ((i=0;i<70;i++));do
    echo -n "*";
done
echo
) >> $logDatei

(

# Deklaration der Variablen:
LR_version="v13"

source="/mnt/Programme/LIGHTROOM_DATEN/LIGHTROOM_Katalog/"

# Array mit den Zielordnern
Destinations=(
		# Orangene Seagate 5TB
		#"/media/rwolff/Seagate FOTOGRAFIE Backup 022019/FOTOGRAFIE BackUp/LIGHTROOM_Katalog/"
		# Orangene Seagate 5 TB on fedora
		"/run/media/rwolff/Seagate FOTOGRAFIE Backup 022019/FOTOGRAFIE BackUp/LIGHTROOM_Katalog"
		# Grüne WesternDigital 3TB
		# "/media/rwolff/WD SONSTIGE DATEN 092014/FOTOGRAFIE_BackUp/LIGHTROOM_Katalog/"
		# CPD HDD0 12TB
		"/mnt/BackUp_HDD0_072024/FOTOGRAFIE_BackUp/LIGHTROOM_Katalog/"
		# CPD HDD1 12TB
		"/mnt/BackUp_HDD1_072024/FOTOGRAFIE_BackUp/LIGHTROOM_Katalog/"
		)

ExcireBackUpDatei="Lightroom Classic Catalog-${LR_version} Excire.excat"
ExcireBakDatei="$ExcireBackUpDatei".bak
lrcat=".lrcat"
LRBackUpName="Lightroom Classic Catalog-${LR_version}"
LRBackUpDatei="$LRBackUpName"$lrcat
LREinstellungen="Ajustes de Lightroom"
aktuellerMonat=$(date +%Y-%m)

### --- Funktionen --- ###
#========================#

# Funktion, die b3sum auf dem System installiert, falls nicht vorhanden.
installer() {
    fensterbox question "Soll $1 auf dem System installiert werden?"
    [ $? -eq 0 ] && sudo apt install -y $1 || (echo "Backup wird abgebrochen."; exit 2)
}

# Funktion zur Überprüfung das Kopiervorgang richtig verlaufen ist.
# Braucht als Argumente die Quelle, das Ziel und den Namen der Datei
chksum() {
    echo "Überprüfung auf neuere Datei. $(date +%F' '%R)"
    chksum_source=$(b3sum "$1$3" | cut -d' ' -f1 &)
    [ -f "$2$3" ] && chksum_dstorg=$(b3sum "$2$3" | cut -d' ' -f1) || chk2=0
    [ $chksum_source = $chksum_dstorg ] || return 1
}

# Funktion öffnet Fenster-Box mit Warning/Error/Info/Frage
fensterbox () {
    zenity --$1  --title="Lightroom Daten Backup" --text="$2"
}

# Excire-Daten-Backup
Excire-Daten-Backup () {
    echo "Excire-Daten werden gesichert... $(date +%F' '%R)"
    [ -f "$3*.old" ] && rm "$3"*.old
    if [ -f "$3" ]; then
        mv "$3" "$3".old
        [ $? -eq 0 ] || fensterbox error "Error: Kopiervorgang fehlgeschlagen."
    fi
    if [ -f "$3.bak" ];then
        mv "$3.bak" "$3.bak".old
        [ $? -eq 0 ] || fensterbox error "Error: Kopiervorgang fehlgeschlagen."
    fi
    rsync -ah --info=progress2 "$1$3" "$2"
    [ $? -eq 0 ] || fensterbox error "Error: Sync-Vorgang fehlgeschlagen."
#    chown rwolff:rwolff "$3"
    rsync -ah --info=progress2 "$1$3.bak" "$2"
    [ $? -eq 0 ] || fensterbox error "Error: Sync-Vorgang fehlgeschlagen."
#    chown rwolff:rwolff "$3.bak"
}

# Lightroom-Katalog-Backup
Lightroom-Katalog-Backup () {
    echo "Lightroom-Daten werden gesichert... $(date +%F' '%R)"
    [ -f "$2$3" ] && mv "$2$3" "$2$3".old
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
    if [ -z "$bkp" ];then
        echo "Monats-Sicherung wird angelegt... $(date +%F' '%R)"    
        rsync -ah --info=progress2  "$1$3.lrcat" "$1$3-$2.lrcat"
    fi
}

# Sicherung der Lightroom-Einstellungen
Ajustes-Sicherung () {
    echo "Lightroom Programm-Einstellungen werden gesichert... $(date +%F' '%R)"
    rsync -ah --info=progress2 "$1$3/" "$2$3"
}

### --- Haupt-Programm --- ###
#============================#

# Zunächst wird geprüft, ob notwendige Software vorhanden ist
which b3sum >& /dev/null
[ $? -ne 0 ] && installer b3sum
which rsync >& /dev/null
[ $? -ne 0 ] && installer rsync

# For-Schleife geht durch die im Array definierten HDDs und führt die BackUps durch
for destination in "${Destinations[@]}"; do

    # Prüfung, ob die jeweilige HDD bereits gemountet ist.
    [ -d "$destination" ] || fensterbox question "Backup-Medium\n${destination}\neinstecken bitte\!\nSobald das Sicherungsmedium gemountet wurde,\nbitte mit 'Ja' bestätigen."
    if [ $? -ne 0 ];then
        fensterbox question "Soll das gesamte Backup-Vorhaben abgebrochen werden?"
        if [ $? -eq 0 ];then
            echo -e "Abbruch durch User $(date +%F' '%R)."
            echo
            exit 1
        fi
    else
        echo -e "Backup auf ${destination}\nBeginn um $(date +%F' '%R)"
        # Prüfung, ob überhaupt eine Sicherung notwendig ist:
        # wenn source = destination, dann wird Backup abgebrochen,
        # keine weiteren Aktionen notwendig.
        chksum "$source" "$destination" "$LRBackUpDatei"
        if [ $? -eq 0 ]; then
            fensterbox info "${LRBackUpDatei} auf ${source} ist bereits auf ${destination} gesichert." &
	    echo -e "Kein Backup notwendig. ${LRBackUpName}-Dateien sind gleich (checksum)."
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

Ende="Backup aller Lightroom-Daten abgeschlossen. $(date +%F' '%R)"
fensterbox info "$Ende"
echo $Ende

) | tee -a $logDatei 
