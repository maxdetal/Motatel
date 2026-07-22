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
KARABINER_APP="/Applications/Karabiner-Elements.app"

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

cleanup() {
    rm -rf "$TMP_ROOT"
}

trap cleanup EXIT

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  $APP_TITLE"
echo "  Automatic installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

say "Checking system compatibility..."

ARCH="$(uname -m)"
MACOS_VERSION="$(sw_vers -productVersion)"
MACOS_MAJOR="${MACOS_VERSION%%.*}"

if [ "$ARCH" != "arm64" ]; then
    fail "Motatel v1.3 currently supports Apple Silicon Macs only (M1 or newer)."
fi

if [ "$MACOS_MAJOR" -lt 13 ]; then
    fail "Motatel v1.3 requires macOS 13 Ventura or later."
fi

echo "✓ Architecture: $ARCH"
echo "✓ macOS: $MACOS_VERSION"

say "Checking Homebrew..."

load_brew

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew was not found."
    echo "Installing Homebrew..."
    echo

    /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    load_brew
fi

if ! command -v brew >/dev/null 2>&1; then
    fail "Homebrew installation could not be completed."
fi

echo "✓ Homebrew: $(brew --version | head -n 1)"

say "Checking Python 3..."

if ! command -v python3 >/dev/null 2>&1; then
    echo "Python 3 was not found."
    echo "Installing Python 3..."
    echo

    brew install python
fi

if ! command -v python3 >/dev/null 2>&1; then
    fail "Python 3 installation could not be completed."
fi

PYTHON_BIN="$(command -v python3)"

if [ ! -x "$PYTHON_BIN" ]; then
    fail "Python 3 was found, but it is not executable."
fi

echo "✓ Python: $("$PYTHON_BIN" --version)"
echo "✓ Python path: $PYTHON_BIN"

say "Checking media-control..."

if ! command -v media-control >/dev/null 2>&1; then
    echo "media-control was not found."
    echo "Installing media-control..."
    echo

    brew install media-control
fi

if ! command -v media-control >/dev/null 2>&1; then
    fail "media-control installation could not be completed."
fi

MEDIA_CONTROL_BIN="$(command -v media-control)"

if [ ! -x "$MEDIA_CONTROL_BIN" ]; then
    fail "media-control was found, but it is not executable."
fi

echo "✓ media-control installed"
echo "✓ media-control path: $MEDIA_CONTROL_BIN"

say "Checking Karabiner-Elements..."

if [ ! -d "$KARABINER_APP" ]; then
    echo "Karabiner-Elements was not found."
    echo "Installing Karabiner-Elements..."
    echo

    brew install --cask karabiner-elements
fi

if [ ! -d "$KARABINER_APP" ]; then
    fail "Karabiner-Elements installation could not be completed."
fi

echo "✓ Karabiner-Elements installed"

say "Opening Karabiner-Elements..."

if ! open "$KARABINER_APP"; then
    fail "Karabiner-Elements could not be opened. Open it manually and run the installer again."
fi

echo
echo "macOS may now ask for permissions."
echo
echo "Please complete the Karabiner setup and enable"
echo "all permissions requested by macOS."
echo
echo "These may include:"
echo
echo "  - Background Services"
echo "  - Accessibility"
echo "  - Input Monitoring"
echo "  - Driver Extension"
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
    fail "Karabiner did not create its configuration file. Open Karabiner once, complete its setup, then run the installer again."
fi

echo "✓ Karabiner configuration found"

say "Downloading Motatel..."

rm -rf "$TMP_ROOT"
mkdir -p "$TMP_ROOT"

curl -fL \
    "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" \
    -o "$ARCHIVE"

tar -xzf "$ARCHIVE" -C "$TMP_ROOT"

if [ ! -d "$PAYLOAD" ]; then
    fail "The Motatel payload could not be found."
fi

for required in \
    media-seek-daemon.py \
    media-seek-command \
    media-seek-jump \
    com.yarw.media-seek-daemon.plist \
    karabiner-rules.json
do
    if [ ! -f "$PAYLOAD/$required" ]; then
        fail "Missing file: payload/$required"
    fi
done

echo "✓ Motatel downloaded"

say "Installing Motatel..."

mkdir -p "$TARGET_HOME/.local/bin"
mkdir -p "$TARGET_HOME/Library/LaunchAgents"
mkdir -p "$TARGET_HOME/Library/Logs"
mkdir -p "$TARGET_HOME/.config/karabiner"

"$PYTHON_BIN" - \
    "$PAYLOAD" \
    "$TARGET_HOME" \
    "$PYTHON_BIN" \
    "$MEDIA_CONTROL_BIN" <<'PY'
from pathlib import Path
import sys

payload = Path(sys.argv[1])
home = Path(sys.argv[2])
python_bin = sys.argv[3]
media_control_bin = sys.argv[4]

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

    text = text.replace(
        "__MOTATEL_PYTHON__",
        python_bin,
    )

    text = text.replace(
        "__MEDIA_CONTROL__",
        media_control_bin,
    )

    # Compatibility with payload files from earlier Motatel builds.
    text = text.replace(
        "/opt/homebrew/bin/media-control",
        media_control_bin,
    )

    if filename in {
        "media-seek-daemon.py",
        "media-seek-jump",
    }:
        if text.startswith("#!/usr/bin/python3"):
            text = text.replace(
                "#!/usr/bin/python3",
                f"#!{python_bin}",
                1,
            )

    if filename == "com.yarw.media-seek-daemon.plist":
        text = text.replace(
            "<string>/usr/bin/python3</string>",
            f"<string>{python_bin}</string>",
            1,
        )

    destination.write_text(text)

    print(f"  ✓ {destination}")
PY

chmod +x \
    "$TARGET_HOME/.local/bin/media-seek-daemon.py" \
    "$TARGET_HOME/.local/bin/media-seek-command" \
    "$TARGET_HOME/.local/bin/media-seek-jump"

if ! plutil -lint "$PLIST" >/dev/null; then
    fail "The installed LaunchAgent configuration is invalid."
fi

echo "✓ LaunchAgent configuration valid"

say "Installing the Karabiner rules..."

"$PYTHON_BIN" - \
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

mkdir -p /tmp/media-seek
rm -f \
    /tmp/media-seek/forward \
    /tmp/media-seek/backward

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

if ! pgrep -f "media-seek-daemon.py" \
    >/dev/null 2>&1
then
    fail "The Motatel service was loaded, but the background daemon is not running."
fi

echo "✓ Motatel background service is running"

cleanup
trap - EXIT

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
