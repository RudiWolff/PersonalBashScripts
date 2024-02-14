#!/bin/bash
zenity --question --window-icon=warning --title="Backup" --text="Backup-Medium einstecken bitte!\
	\nHier noch eine Beschreibung."
[ $? -eq 0 ] && gnome-terminal -- bash -c "/home/rwolff/Documentos/Skripte/hello.sh; exec bash" || exit 5
