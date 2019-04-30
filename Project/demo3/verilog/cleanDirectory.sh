#!/bin/sh
find ./ -type f ! \( -iname \*.v -o -iname \*.sh  -o -iname \*.img  -o -iname \*.list \) | xargs rm -f
rm -rf __work/
