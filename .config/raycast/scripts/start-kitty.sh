#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Start kitty
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐈


open -n -a kitty --args --single-instance -d "$HOME" >/dev/null 2>&1
