#!/bin/zsh
# Install the LAN photo receiver as a launchd agent (auto-start + keep-alive).
set -e
BASE="$(cd "$(dirname "$0")" && pwd)"
LABEL="com.iphone-to-mac.receiver"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
UID_NUM="$(id -u)"

# 1. token (reuse if present, else generate)
[ -f "$BASE/.phone-token" ] || openssl rand -hex 8 > "$BASE/.phone-token"
TOKEN="$(cat "$BASE/.phone-token")"

# 2. build plist from sample
mkdir -p "$HOME/Library/LaunchAgents"
sed -e "s|__SCRIPT__|$BASE/phone-receiver.py|g" \
    -e "s|__BASE__|$BASE|g" \
    "$BASE/com.iphone-to-mac.receiver.plist.sample" > "$PLIST"

# 3. (re)load
launchctl bootout "gui/$UID_NUM/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$UID_NUM" "$PLIST"
sleep 1

# 4. done — print the URL for the iPhone Shortcut
HOST="$(scutil --get LocalHostName).local"
for i in 1 2 3 4 5; do sleep 1; PONG="$(curl -s --max-time 3 http://127.0.0.1:8787/ping)"; [ -n "$PONG" ] && break; done
echo ""
echo "✅ installed. ping: ${PONG:-no response yet}"
echo "Shortcut URL:  http://$HOST:8787/up/$TOKEN"
echo "(if .local fails, use your Mac's LAN IP instead)"
