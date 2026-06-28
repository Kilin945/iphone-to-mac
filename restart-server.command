#!/bin/zsh
# Double-click to restart the receiver if it ever gets stuck.
launchctl kickstart -k "gui/$(id -u)/com.iphone-to-mac.receiver"
echo "✅ restarted. (you can close this window)"
sleep 1
