#!/bin/bash
set -euo pipefail

APP_TITLE="Мотатель by Max DetaL v1.3"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
PAYLOAD="$SOURCE_DIR/payload"
TARGET_HOME="$HOME"
DOMAIN="gui/$(id -u)"
SERVICE="com.yarw.media-seek-daemon"
PLIST="$TARGET_HOME/Library/LaunchAgents/$SERVICE.plist"
KARABINER_CONFIG="$TARGET_HOME/.config/karabiner/karabiner.json"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  $APP_TITLE"
echo "  Установка"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

if ! command -v python3 >/dev/null 2>&1; then
    echo "ОШИБКА: команда python3 не найдена."
    echo
    echo "Установи Python 3 и повторно запусти:"
    echo "bash install.sh"
    exit 1
fi

if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
    echo "ОШИБКА: Karabiner-Elements не установлен."
    echo
    echo "Установи Karabiner-Elements, запусти его один раз,"
    echo "выдай разрешения macOS и повторно запусти:"
    echo "bash install.sh"
    exit 1
fi

if [ ! -f "$KARABINER_CONFIG" ]; then
    echo "ОШИБКА: Karabiner ещё не создал свой конфиг."
    echo
    echo "Открой Karabiner-Elements хотя бы один раз,"
    echo "затем повторно запусти:"
    echo "bash install.sh"
    exit 1
fi

for required in \
    media-seek-daemon.py \
    media-seek-command \
    media-seek-jump \
    com.yarw.media-seek-daemon.plist \
    karabiner-rules.json
do
    if [ ! -f "$PAYLOAD/$required" ]; then
        echo "ОШИБКА: в пакете отсутствует:"
        echo "$PAYLOAD/$required"
        exit 1
    fi
done

echo "Создаю папки..."

mkdir -p "$TARGET_HOME/.local/bin"
mkdir -p "$TARGET_HOME/Library/LaunchAgents"
mkdir -p "$TARGET_HOME/.config/karabiner"

echo "Устанавливаю рабочие файлы..."

python3 - "$PAYLOAD" "$TARGET_HOME" <<'PY'
from pathlib import Path
import sys

payload = Path(sys.argv[1])
home = Path(sys.argv[2])

destinations = {
    "media-seek-daemon.py":
        home / ".local/bin/media-seek-daemon.py",

    "media-seek-command":
        home / ".local/bin/media-seek-command",

    "media-seek-jump":
        home / ".local/bin/media-seek-jump",

    "com.yarw.media-seek-daemon.plist":
        home / "Library/LaunchAgents"
        / "com.yarw.media-seek-daemon.plist",
}

for filename, destination in destinations.items():
    text = (payload / filename).read_text()

    text = text.replace(
        "__MOTATEL_HOME__",
        str(home),
    )

    destination.write_text(text)

    print(f"  ✓ {destination}")
PY

chmod +x \
    "$TARGET_HOME/.local/bin/media-seek-daemon.py" \
    "$TARGET_HOME/.local/bin/media-seek-command" \
    "$TARGET_HOME/.local/bin/media-seek-jump"

echo "Добавляю правила Karabiner..."

python3 - \
    "$PAYLOAD/karabiner-rules.json" \
    "$KARABINER_CONFIG" \
    "$TARGET_HOME" <<'PY'
from pathlib import Path
import json
import shutil
import sys
import time

rules_file = Path(sys.argv[1])
config_file = Path(sys.argv[2])
home = Path(sys.argv[3])

timestamp = time.strftime("%Y%m%d-%H%M%S")

backup = config_file.with_name(
    f"karabiner.json.before-motatel-{timestamp}.backup"
)

shutil.copy2(config_file, backup)

config = json.loads(config_file.read_text())

rules_text = rules_file.read_text().replace(
    "__MOTATEL_HOME__",
    str(home),
)

new_rules = json.loads(rules_text)

profiles = config.get("profiles", [])

if not profiles:
    raise SystemExit(
        "ОШИБКА: в Karabiner не найдено ни одного профиля."
    )

profile = next(
    (
        item for item in profiles
        if item.get("selected") is True
    ),
    profiles[0],
)

complex_modifications = profile.setdefault(
    "complex_modifications",
    {},
)

current_rules = complex_modifications.setdefault(
    "rules",
    [],
)

needles = (
    "media-seek",
    "media_seek",
    "media-seek-command",
    "media-seek-jump",
    "media-seek-daemon",
)

filtered_rules = []

for rule in current_rules:
    serialized = json.dumps(
        rule,
        ensure_ascii=False,
    )

    if not any(
        needle in serialized
        for needle in needles
    ):
        filtered_rules.append(rule)

filtered_rules.extend(new_rules)

complex_modifications["rules"] = filtered_rules

config_file.write_text(
    json.dumps(
        config,
        ensure_ascii=False,
        indent=4,
    ) + "\n"
)

print(f"  ✓ Резервная копия: {backup}")
print(f"  ✓ Добавлено правил: {len(new_rules)}")
PY

echo "Запускаю Мотатель..."

launchctl bootout \
    "$DOMAIN/$SERVICE" \
    2>/dev/null || true

launchctl bootstrap \
    "$DOMAIN" \
    "$PLIST"

launchctl enable \
    "$DOMAIN/$SERVICE"

launchctl kickstart -k \
    "$DOMAIN/$SERVICE"

launchctl kickstart -k \
    "$DOMAIN/org.pqrs.service.agent" \
    2>/dev/null || true

sleep 1

if launchctl print "$DOMAIN/$SERVICE" \
    >/dev/null 2>&1
then
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ГОТОВО"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "$APP_TITLE установлен и запущен."
    echo
    echo "Короткое нажатие:"
    echo "  предыдущий или следующий трек"
    echo
    echo "Удержание:"
    echo "  непрерывная перемотка"
    echo
    echo "Play/Pause во время удержания:"
    echo "  прыжок на 60 секунд"
    echo
    echo "Ускорение перемотки:"
    echo "  через 1.0 и 2.5 секунды"
    echo
    echo "Теперь проверяй кнопки."
    echo
else
    echo
    echo "Установка завершена, но служба не появилась"
    echo "в launchctl. Попробуй перезагрузить Mac."
    exit 1
fi
