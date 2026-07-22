#!/bin/bash
set -euo pipefail

DOMAIN="gui/$(id -u)"
SERVICE="com.yarw.media-seek-daemon"

echo
echo "Удаляю Мотатель by Max DetaL v1.3..."

launchctl bootout \
    "$DOMAIN/$SERVICE" \
    2>/dev/null || true

rm -f \
    "$HOME/.local/bin/media-seek-daemon.py" \
    "$HOME/.local/bin/media-seek-command" \
    "$HOME/.local/bin/media-seek-jump" \
    "$HOME/Library/LaunchAgents/$SERVICE.plist"

echo
echo "Рабочие файлы и служба удалены."
echo "Правила Karabiner автоматически не удалялись,"
echo "чтобы случайно не повредить чужой конфиг."
echo
