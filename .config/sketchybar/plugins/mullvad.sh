#!/bin/sh

which mullvad 1>&- || exit 1

if mullvad status | grep -E '^Connected' >/dev/null; then
  ICON=""
else
  ICON=""
fi

sketchybar --set "mullvad" icon="$ICON"
