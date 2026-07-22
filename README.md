# Motatel by Max DetaL'

**Hold media keys to seek. Tap to skip.**

Motatel turns the **Previous**, **Next**, and **Play/Pause** media keys on macOS into proper playback controls.

It was originally built for **MIDI DOBRYNYA controllers by Max DetaL**, but it also works with the built-in MacBook keyboard and compatible HID or BLE media devices supported by Karabiner-Elements.

---

## What it does

### Previous / Next

- **Short press** → previous or next track
- **Hold** → continuous seeking backward or forward
- Seeking automatically accelerates while the button is held

### Play/Pause

- **Normal press** → regular Play/Pause
- **Press while holding Previous or Next** → jump 60 seconds in the current direction

The additional Play/Pause jump works with the Mac keyboard and compatible HID devices.

On current MIDI DOBRYNYA mappings, hold-to-seek works, while the additional Play/Pause jump may not be available depending on the controller firmware and mapping.

---

## Features

- Tap Previous / Next to switch tracks
- Hold Previous / Next to seek continuously
- Progressive seek acceleration
- Play/Pause while seeking jumps ±60 seconds
- Starts automatically after login
- Runs silently in the background
- Creates a backup of the Karabiner configuration
- Designed for MIDI DOBRYNYA controllers
- Also works with compatible macOS media keyboards and remotes

---

## Seeking profile

Motatel v1.3 uses the following acceleration profile:

- Up to 1 second: 20-second seek steps
- From 1 to 2.5 seconds: 35-second seek steps
- After 2.5 seconds: 60-second seek steps

The longer you hold the button, the faster Motatel moves.

---

# Installation

## Fresh Mac installation

You will need:

1. Homebrew
2. Python 3
3. Karabiner-Elements
4. Motatel

Follow the steps below in order.

---

## Step 1: Install Homebrew

Open **Terminal**, paste this command, and press Enter:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Homebrew may ask for your macOS password.

While typing the password, Terminal will not display letters, dots, or stars. This is normal. Type the password and press Enter.

When the installation finishes, run:

```bash
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
```

Check that Homebrew works:

```bash
brew --version
```

---

## Step 2: Install Python 3

Run:

```bash
brew install python
```

Check that Python works:

```bash
python3 --version
```

Motatel uses Python 3 for its background seeking daemon.

---

## Step 3: Install Karabiner-Elements

Run:

```bash
brew install --cask karabiner-elements
```

Then open Karabiner-Elements:

```bash
open -a "Karabiner-Elements"
```

Karabiner must be launched at least once before installing Motatel.

Approve the permissions requested by macOS.

Depending on your macOS version, Karabiner may request access in:

- System Settings → Privacy & Security → Accessibility
- System Settings → Privacy & Security → Input Monitoring
- System Settings → Privacy & Security → Driver Extensions

These permissions cannot be granted automatically from Terminal.

After granting the permissions, quit and reopen Karabiner-Elements if macOS asks you to do so.

---

## Step 4: Install Motatel

Open Terminal and run:

```bash
rm -rf /tmp/Motatel-main /tmp/Motatel.tar.gz && \
curl -fL "https://github.com/maxdetal/Motatel/archive/refs/heads/main.tar.gz" -o /tmp/Motatel.tar.gz && \
tar -xzf /tmp/Motatel.tar.gz -C /tmp && \
bash /tmp/Motatel-main/install.sh
```

Motatel will automatically:

- install the Python daemon
- install the helper scripts
- install the LaunchAgent
- add the required Karabiner rules
- back up the existing Karabiner configuration
- start the background service
- start automatically after future logins

When Terminal says that installation is complete, test the Previous and Next media buttons.

---

# Quick installation

Use this section if Homebrew, Python 3, and Karabiner-Elements are already installed and Karabiner has already received its macOS permissions.

```bash
rm -rf /tmp/Motatel-main /tmp/Motatel.tar.gz && \
curl -fL "https://github.com/maxdetal/Motatel/archive/refs/heads/main.tar.gz" -o /tmp/Motatel.tar.gz && \
tar -xzf /tmp/Motatel.tar.gz -C /tmp && \
bash /tmp/Motatel-main/install.sh
```

That is it.

---

# Full setup as one Terminal block

This block installs Homebrew if necessary, installs Python and Karabiner-Elements, opens Karabiner, and downloads Motatel.

You will still need to manually approve the macOS permissions requested by Karabiner.

```bash
set -e

if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

brew install python
brew install --cask karabiner-elements

open -a "Karabiner-Elements"

echo
echo "Karabiner-Elements has been opened."
echo "Approve its macOS permissions, then return to Terminal."
echo
read -r -p "Press Enter after the permissions have been granted..."

rm -rf /tmp/Motatel-main /tmp/Motatel.tar.gz

curl -fL \
    "https://github.com/maxdetal/Motatel/archive/refs/heads/main.tar.gz" \
    -o /tmp/Motatel.tar.gz

tar -xzf /tmp/Motatel.tar.gz -C /tmp

bash /tmp/Motatel-main/install.sh
```

---

# What is actually required?

## Homebrew

Homebrew is only used to install dependencies conveniently.

Motatel does not need Homebrew running in the background after installation.

## Python 3

Python 3 is required while Motatel is running.

The background daemon is written in Python.

## Karabiner-Elements

Karabiner-Elements is required while Motatel is running.

It receives media key events and sends the appropriate commands to Motatel.

## Built-in macOS components

Motatel also uses components already included with macOS:

- Terminal
- `curl`
- `tar`
- `launchctl`
- LaunchAgents
- AppleScript
- macOS media information

These do not need to be installed separately.

---

# Compatible devices

Motatel is intended to work with:

- MacBook built-in media keys
- Apple keyboards
- MIDI DOBRYNYA controllers
- BLE media controllers
- HID media keyboards
- HID media remotes
- Other devices whose media events can be remapped by Karabiner-Elements

Compatibility depends on how the device reports its media buttons.

Some USB receivers may appear inside Karabiner EventViewer but still fail to trigger Karabiner complex modifications.

---

# How it works

Karabiner-Elements intercepts the media key events.

A short press is handled as a normal track command.

When Previous or Next is held, Karabiner sends commands to a lightweight Python daemon running in the background.

The daemon tracks:

- the active seeking direction
- how long the button has been held
- the current acceleration level
- whether Play/Pause was pressed during seeking

Motatel then changes the current playback position using macOS media controls.

The daemon is started by a macOS LaunchAgent and automatically launches after login.

---

# Repository structure

```text
Motatel/
├── install.sh
├── uninstall.sh
├── README.md
├── README.txt
├── VERSION
└── payload/
    ├── media-seek-daemon.py
    ├── media-seek-command
    ├── media-seek-jump
    ├── com.yarw.media-seek-daemon.plist
    └── karabiner-rules.json
```

---

# Updating Motatel

Run the installation command again:

```bash
rm -rf /tmp/Motatel-main /tmp/Motatel.tar.gz && \
curl -fL "https://github.com/maxdetal/Motatel/archive/refs/heads/main.tar.gz" -o /tmp/Motatel.tar.gz && \
tar -xzf /tmp/Motatel.tar.gz -C /tmp && \
bash /tmp/Motatel-main/install.sh
```

The installer will replace the Motatel files with the current version and create another Karabiner configuration backup.

---

# Uninstall

Download the repository or use the copy already on your computer, then run:

```bash
bash uninstall.sh
```

The uninstall script removes:

- the Motatel Python daemon
- the helper scripts
- the LaunchAgent
- the running background service

Karabiner rules are not automatically removed to avoid accidentally damaging an existing Karabiner configuration.

---

# Troubleshooting

## `brew: command not found`

Homebrew is either not installed or is not currently available in your shell.

Run:

```bash
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
```

Then check:

```bash
brew --version
```

## `python3: command not found`

Install Python:

```bash
brew install python
```

## Karabiner configuration was not found

Open Karabiner-Elements at least once:

```bash
open -a "Karabiner-Elements"
```

Then run the Motatel installation command again.

## Buttons do nothing

Check:

1. Karabiner-Elements is running
2. Accessibility permission is enabled
3. Input Monitoring permission is enabled
4. Motatel is running

Check the Motatel service:

```bash
launchctl print gui/$(id -u)/com.yarw.media-seek-daemon
```

Restart it:

```bash
launchctl kickstart -k gui/$(id -u)/com.yarw.media-seek-daemon
```

## Built-in keyboard works, but another device does not

The device may use a media-key implementation that Karabiner can see but cannot manipulate correctly.

Check the device inside Karabiner EventViewer.

---

# Known limitations

- Karabiner permissions must be approved manually
- Device compatibility depends on its HID or BLE implementation
- The Play/Pause 60-second jump may not be available on every MIDI DOBRYNYA mapping
- Different media players may expose playback information differently
- Some USB media receivers do not trigger Karabiner complex modifications correctly

---

# Version

**Motatel v1.3**

---

# Author

**Max DetaL**

Built for MIDI DOBRYNYA controllers and anyone who thinks media keys should know how to actually rewind.
