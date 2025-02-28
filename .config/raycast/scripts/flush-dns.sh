#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Flush DNS
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "password", "placeholder": "password" }


echo "${1?}" | sudo -S dscacheutil -flushcache; sudo killall -HUP mDNSResponder
