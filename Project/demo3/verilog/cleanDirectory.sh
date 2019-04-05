#!/bin/sh
find ./ -type f ! \( -iname \*.v -o -iname \*.sh \) | xargs rm -f
rm -rf __work/
