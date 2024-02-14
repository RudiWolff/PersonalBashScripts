#!/bin/bash

decor() {
    test "$2" && echo $2 | tee -a $logDatei
    for ((i=0;i<$1;i++));do
        echo -n "*" | tee -a $logDatei
    done
echo | tee -a $logDatei
}

no_root() {
# Die Funtkion prüft darauf, ob Anwender root-Rechte hat
    if [ $EUID -ne 0 ];then
        echo >&2 "ERROR: You have to be root."
        exit 1
    fi
}
