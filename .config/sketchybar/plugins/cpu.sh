#!/bin/sh

MULTICORE_PERCENT="$(ps -A -o %cpu | awk '{s+=$1} END {print s}')"

if [ "$MULTICORE_PERCENT" = "" ]; then
  exit 0
fi

# Divide by number of cores
NCORES="$(sysctl -n hw.ncpu)"
SINGLECORE_PERCENT="$(bc -e "$MULTICORE_PERCENT / $NCORES")"

sketchybar --set "cpu" icon="" label="${SINGLECORE_PERCENT}%"
