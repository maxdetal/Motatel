# Motatel by Max DetaL'

**Hold media keys to seek. Tap to skip.**

Motatel turns the **Previous**, **Next**, and **Play/Pause** media keys on macOS into something much more useful.

It was originally built for **MIDI DOBRYNYA controllers by Max DetaL**, but it also works with the built-in MacBook keyboard and other HID or BLE devices that send standard media key events through Karabiner-Elements.

---

## What it does

### Previous / Next buttons

- **Short press** → previous or next track
- **Hold** → continuous seeking backward or forward
- Seeking speed increases automatically while the button is held

### Play/Pause button

- **Normal press** → regular Play/Pause
- **Press while holding Previous or Next** → jump 60 seconds in the current seek direction

The Play/Pause jump works on the Mac keyboard and on compatible HID devices.

On current MIDI DOBRYNYA mappings, the hold-to-seek controls work, while the extra Play/Pause jump may not be available depending on the controller firmware and mapping.

---

## Features

- Short press keeps normal Previous / Next behavior
- Hold enables continuous seeking
- Progressive seek acceleration
- Play/Pause while seeking jumps ±60 seconds
- Starts automatically after login
- Creates a Karabiner configuration backup before changing anything
- Lightweight Python daemon
- No permanent app window
- Designed to work with MIDI DOBRYNYA controllers

---

## Compatible devices

Motatel is intended to work with:

- MacBook built-in media keys
- Apple keyboards
- MIDI DOBRYNYA controllers
- BLE media controllers
- HID media keyboards and remotes
- Other devices that Karabiner-Elements can remap correctly

Compatibility depends on whether Karabiner-Elements can receive and manipulate the device's media key events.

Some cheap USB receivers may appear in Karabiner EventViewer but still fail to trigger complex modifications.

---

## Seeking profile

Motatel v1.3 currently uses this acceleration profile:

- First second: 20-second seek steps
- From 1 to 2.5 seconds: 35-second seek steps
- After 2.5 seconds: 60-second seek steps

The longer you hold the button, the faster it moves.

---

## Requirements

- macOS
- Karabiner-Elements
- Python 3

Karabiner-Elements must be opened at least once before installing Motatel.

macOS will ask for permissions such as Input Monitoring and Accessibility. These permissions must be approved manually in System Settings.

---

## Installation

### 1. Install Karabiner-Elements

Download and install Karabiner-Elements.

Open it once and approve the permissions requested by macOS.

### 2. Install Motatel

Open Terminal and run:

```bash
rm -rf /tmp/Motatel-main /tmp/Motatel.tar.gz && \
curl -fL https://github.com/maxdetal/Motatel/archive/refs/heads/main.tar.gz -o /tmp/Motatel.tar.gz && \
tar -xzf /tmp/Motatel.tar.gz -C /tmp && \
bash /tmp/Motatel-main/install.sh
```

The installer will:

- install the Motatel scripts
- install the background daemon
- install the LaunchAgent
- add the required Karabiner rules
- back up the existing Karabiner configuration
- start Motatel automatically

After installation, test the Previous and Next media buttons.

---

## How it works

Karabiner-Elements intercepts media key events and sends commands to Motatel.

Motatel runs a lightweight Python daemon in the background.

The daemon tracks:

- which seek direction is currently active
- how long the media button has been held
- which seek speed should be used
- whether Play/Pause was pressed during seeking

The actual playback position is controlled through macOS media information and AppleScript-based commands.

Short presses remain normal track controls.

Long presses become continuous seeking.

---

## Repository structure

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

## Uninstall

From the downloaded Motatel folder, run:

```bash
bash uninstall.sh
```

The uninstall script removes the Motatel daemon, helper scripts, and LaunchAgent.

Karabiner rules are not automatically deleted in order to avoid damaging an existing configuration.

---

## Known limitations

- Karabiner compatibility depends on the connected device and its USB or BLE implementation
- Some media players may expose playback position differently
- The Play/Pause 60-second jump may not be available on every MIDI DOBRYNYA mapping
- macOS security permissions cannot be granted automatically from Terminal

---

## Roadmap

- configurable seek speeds
- configurable acceleration timing
- easier one-line installer
- automatic Karabiner-Elements installation assistance
- support for more media players
- improved uninstall process
- dedicated MIDI DOBRYNYA presets

---

## Version

**Motatel v1.3**

---

## Author

**Max DetaL**

Built for MIDI DOBRYNYA controllers and anyone who thinks media keys should know how to actually rewind.
