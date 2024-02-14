#!/bin/bash

source functions.sh

(
date

no_root

apt-get update

) | tee apt.file
