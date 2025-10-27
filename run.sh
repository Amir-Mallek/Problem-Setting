#!/bin/bash

rm -f inputs/*      &&
./gen-ins.sh        &&
echo -e "\n\n\n"    &&
rm -f answers/*     &&
./gen-outs.sh       &&
echo -e "\n\n\n"    &&
./compare-sols.sh