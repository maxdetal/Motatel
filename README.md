# Motatel by Max DetaL

**Hold media keys to seek. Tap to skip.**

Motatel turns the **Previous**, **Next**, and **Play/Pause** media keys on macOS into proper playback controls.

It was originally built for **MIDI DOBRYNYA controllers by Max DetaL**, but it also works with the built-in MacBook keyboard and compatible HID or BLE media devices supported by Karabiner-Elements.

---

## Installation

Open **Terminal**, paste this command, and press Enter:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/install.sh)"
```

That is the entire installation command.

The installer will automatically:

- check whether Homebrew is installed
- install Homebrew if necessary
- check whether Python 3 is installed
- install Python 3 if necessary
- check whether Karabiner-Elements is installed
- install Karabiner-Elements if necessary
- open Karabiner-Elements
- download and install Motatel
- add the required Karabiner rules
- create a backup of the existing Karabiner configuration
- install and start the background service
- configure Motatel to start automatically after login

### One manual step

macOS does not allow keyboard-control permissions to be granted silently from Terminal.

When Karabiner-Elements opens, follow its setup prompts and approve the permissions requested by macOS. Depending on the macOS and Karabiner versions, this can include:

- Background Services
- Accessibility
- Input Monitoring
- Driver Extension

Return to Terminal afterwards and press **Enter** when the installer asks you to continue.

Then Motatel will finish the installation automatically.

---

## What it does

### Previous / Next

- **Tap** → previous or next track
- **Hold** → continuous seeking backward or forward
- Seeking automatically accelerates while the button is held

### Play/Pause

- **Normal press** → regular Play/Pause
- **Press while holding Previous or Next** → jump 60 seconds in the active seek direction

The additional Play/Pause jump works with the built-in Mac keyboard and compatible HID devices.

On current MIDI DOBRYNYA mappings, hold-to-seek works, while the additional Play/Pause jump may not be available depending on the controller firmware and mapping.

---

## Seeking profile

Motatel v1.3 uses three acceleration stages:

- Up to 1 second → 20-second seek steps
- From 1 to 2.5 seconds → 35-second seek steps
- After 2.5 seconds → 60-second seek steps

The longer you hold the button, the faster Motatel moves.

---

## Features

- Tap Previous / Next to switch tracks
- Hold Previous / Next to seek continuously
- Progressive seek acceleration
- Play/Pause while seeking jumps ±60 seconds
- Starts automatically after login
- Runs silently in the background
- Creates a Karabiner configuration backup before modifying it
- Designed for MIDI DOBRYNYA controllers
- Also works with compatible media keyboards and remotes

---

## Compatible devices

Motatel is intended to work with:

- MacBook built-in media keys
- Apple keyboards
- MIDI DOBRYNYA controllers
- BLE media controllers
- HID media keyboards
- HID media remotes
- Other devices whose media events can be remapped by Karabiner-Elements

Compatibility depends on how each device reports its media buttons.

Some USB receivers may appear inside Karabiner-EventViewer but still fail to trigger Karabiner complex modifications.

---

## Requirements

Motatel uses:

### Karabiner-Elements

Receives and remaps media-key events.

Karabiner must remain installed while Motatel is being used.

### Python 3

Runs the lightweight Motatel background daemon.

Python 3 must remain installed while Motatel is being used.

### Homebrew

Used by the installer to install missing dependencies.

Homebrew does not need to run in the background.

### Built-in macOS tools

Motatel also uses standard macOS components, including:

- `curl`
- `launchctl`
- LaunchAgents
- macOS media controls

These are already part of macOS.

---

## How it works

Karabiner-Elements receives the media-key events and passes Motatel commands to a lightweight Python daemon.

The daemon tracks:

- the active seek direction
- how long the button has been held
- the current acceleration stage
- whether Play/Pause was pressed during seeking

A short press remains a regular track command.

Holding Previous or Next starts continuous seeking.

The daemon is managed by a macOS LaunchAgent and starts automatically after login.

---

## Updating

Run the same installation command again:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/install.sh)"
```

The installer will download the current version, replace the Motatel files, back up the Karabiner configuration again, and restart the service.

---

## Uninstall

Open Terminal and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/uninstall.sh)"
```

The uninstaller removes:

- the Motatel Python daemon
- the helper scripts
- the LaunchAgent
- the running background service

Karabiner-Elements, Homebrew, and Python are not removed because other software may use them.

Motatel's Karabiner rules are currently left in the configuration to avoid accidentally damaging an existing setup.

---

## Troubleshooting

### Karabiner opens, but the buttons do nothing

Make sure the setup steps displayed by Karabiner-Elements have been completed.

Check that its required background services and macOS permissions are enabled.

Then restart Motatel:

```bash
launchctl kickstart -k gui/$(id -u)/com.yarw.media-seek-daemon
```

### Check whether Motatel is running

```bash
launchctl print gui/$(id -u)/com.yarw.media-seek-daemon
```

### Built-in keyboard works, but another device does not

Open Karabiner-EventViewer and check whether the device sends standard media-key events.

A device may be visible in EventViewer but still be incompatible with Karabiner complex modifications.

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

## Known limitations

- Karabiner permissions must be approved manually in macOS
- Compatibility depends on the device's HID or BLE implementation
- The Play/Pause 60-second jump may not be available on every MIDI DOBRYNYA mapping
- Different media players may expose playback information differently
- Some USB media receivers do not trigger Karabiner complex modifications correctly

---

## Version

**Motatel v1.3**

---

## Author

**Max DetaL**

Built for MIDI DOBRYNYA controllers and anyone who thinks media keys should know how to actually rewind.
