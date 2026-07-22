#!/bin/bash
set -euo pipefail

APP_TITLE="Motatel by Max DetaL v1.3"
REPO="maxdetal/Motatel"
BRANCH="main"

TMP_ROOT="/tmp/motatel-installer"
ARCHIVE="$TMP_ROOT/Motatel.tar.gz"
SOURCE_DIR="$TMP_ROOT/Motatel-$BRANCH"
PAYLOAD="$SOURCE_DIR/payload"

TARGET_HOME="$HOME"
DOMAIN="gui/$(id -u)"
SERVICE="com.yarw.media-seek-daemon"
PLIST="$TARGET_HOME/Library/LaunchAgents/$SERVICE.plist"
KARABINER_CONFIG="$TARGET_HOME/.config/karabiner/karabiner.json"

say() {
    printf "\n%s\n" "$1"
}

fail() {
    printf "\nERROR: %s\n\n" "$1" >&2
    exit 1
}

load_brew() {
    if command -v brew >/dev/null 2>&1; then
        return 0
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  $APP_TITLE"
echo "  Automatic installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

say "Checking Homebrew..."

load_brew

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew was not found."
    echo "Installing Homebrew..."

    /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    load_brew
fi

command -v brew >/dev/null 2>&1 \
    || fail "Homebrew installation could not be completed."

echo "✓ Homebrew: $(brew --version | head -n 1)"

say "Checking Python 3..."

if ! command -v python3 >/dev/null 2>&1; then
    echo "Python 3 was not found."
    echo "Installing Python 3..."

    brew install python
fi

command -v python3 >/dev/null 2>&1 \
    || fail "Python 3 installation could not be completed."

echo "✓ Python: $(python3 --version)"

say "Checking Karabiner-Elements..."

if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
    echo "Karabiner-Elements was not found."
    echo "Installing Karabiner-Elements..."

    brew install --cask karabiner-elements
fi

[ -d "/Applications/Karabiner-Elements.app" ] \
    || fail "Karabiner-Elements installation could not be completed."

echo "✓ Karabiner-Elements installed"

say "Opening Karabiner-Elements..."

open -a "Karabiner-Elements"

echo
echo "macOS may now ask for permissions."
echo
echo "Please enable the permissions requested by Karabiner,"
echo "including Accessibility and Input Monitoring."
echo
echo "Return to Terminal when Karabiner is ready."
echo

read -r -p "Press Enter to continue..."

say "Waiting for the Karabiner configuration..."

for _ in {1..30}; do
    if [ -f "$KARABINER_CONFIG" ]; then
        break
    fi

    sleep 1
done

if [ ! -f "$KARABINER_CONFIG" ]; then
    fail "Karabiner did not create its configuration file. Open Karabiner once, then run the installer again."
fi

say "Downloading Motatel..."

rm -rf "$TMP_ROOT"
mkdir -p "$TMP_ROOT"

curl -fL \
    "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" \
    -o "$ARCHIVE"

tar -xzf "$ARCHIVE" -C "$TMP_ROOT"

[ -d "$PAYLOAD" ] \
    || fail "The Motatel payload could not be found."

for required in \
    media-seek-daemon.py \
    media-seek-command \
    media-seek-jump \
    com.yarw.media-seek-daemon.plist \
    karabiner-rules.json
do
    [ -f "$PAYLOAD/$required" ] \
        || fail "Missing file: payload/$required"
done

say "Installing Motatel..."

mkdir -p "$TARGET_HOME/.local/bin"
mkdir -p "$TARGET_HOME/Library/LaunchAgents"
mkdir -p "$TARGET_HOME/.config/karabiner"

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
    text = text.replace("__MOTATEL_HOME__", str(home))
    destination.write_text(text)

    print(f"  ✓ {destination}")
PY

chmod +x \
    "$TARGET_HOME/.local/bin/media-seek-daemon.py" \
    "$TARGET_HOME/.local/bin/media-seek-command" \
    "$TARGET_HOME/.local/bin/media-seek-jump"

say "Installing the Karabiner rules..."

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
        "ERROR: No Karabiner profile was found."
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

print(f"  ✓ Backup: {backup}")
print(f"  ✓ Installed rules: {len(new_rules)}")
PY

say "Starting Motatel..."

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

if ! launchctl print "$DOMAIN/$SERVICE" \
    >/dev/null 2>&1
then
    fail "Motatel was installed, but the background service did not start."
fi

rm -rf "$TMP_ROOT"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  INSTALLATION COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "$APP_TITLE is installed and running."
echo
echo "Tap Previous / Next:"
echo "  previous or next track"
echo
echo "Hold Previous / Next:"
echo "  continuous seeking"
echo
echo "Press Play/Pause while seeking:"
echo "  jump 60 seconds"
echo
echo "Enjoy."
echo
