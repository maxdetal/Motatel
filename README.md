# Motatel by Max DetaL

**Hold media keys to seek. Tap to skip.**

## Quick controls

| Action | Result |
|--------|--------|
| Tap Previous / Next | Previous / Next track |
| Hold Previous / Next | Continuous seek |
| Shift + Previous / Next | ±30 seconds |
| Hold Previous / Next + Play | ±90 seconds |

Motatel turns the **Previous**, **Next**, and **Play/Pause** media keys on macOS into proper playback controls.

Originally built for **MIDI DOBRYNYA controllers by Max DetaL**, Motatel also works with the built-in MacBook keyboard and compatible HID or BLE media devices supported by Karabiner-Elements.

---

## Supported systems

Motatel v1.4 officially supports:

- Apple Silicon Macs
- M1 or newer
- macOS 13 Ventura or later

Intel Macs and macOS 12 Monterey or earlier are not officially supported by Motatel v1.4.

Older macOS versions require legacy Karabiner-Elements releases and may behave differently during installation.

---

## Installation

Open **Terminal**, paste this command, and press **Enter**:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/install.sh)"
```

That's the entire installation.

The installer automatically:

- checks your Mac and macOS version
- installs Homebrew if necessary
- installs Python 3 if necessary
- installs media-control if necessary
- installs Karabiner-Elements if necessary
- downloads the latest Motatel release
- installs all required files
- backs up your Karabiner configuration
- installs the Motatel rules
- installs and starts the background service
- enables automatic startup after login

### One manual step

macOS does not allow keyboard permissions to be granted automatically.

When Karabiner-Elements opens:

1. Complete the Karabiner setup.
2. Approve every requested macOS permission.
3. Return to Terminal.
4. Press **Enter** when the installer asks you to continue.

Depending on your macOS version, the requested permissions may include:

- Background Services
- Accessibility
- Input Monitoring
- Driver Extension

After that, Motatel finishes the installation automatically.

---

## What it does

### Previous / Next

- **Tap** → previous or next track
- **Hold** → continuous seeking
- **Shift + Previous / Next** → jump ±30 seconds
- Seeking automatically accelerates while the button is held

### Play/Pause

- **Normal press** → Play / Pause
- **Press while holding Previous or Next** → jump ±90 seconds

The additional jump commands work with the built-in Mac keyboard and compatible HID devices.

Depending on the firmware and mapping, some MIDI DOBRYNYA controllers may not expose every shortcut.

---

## Seeking profile

Motatel v1.4 uses three acceleration stages:

- Up to 1 second → 20-second seek steps
- From 1 to 2.5 seconds → 35-second seek steps
- After 2.5 seconds → 60-second seek steps

The longer you hold the button, the faster seeking becomes.

---

## Features

- Tap Previous / Next to change tracks
- Hold Previous / Next for continuous seeking
- Shift + Previous / Next jumps ±30 seconds
- Play/Pause while seeking jumps ±90 seconds
- Progressive seek acceleration
- Starts automatically after login
- Runs silently in the background
- Automatically backs up the Karabiner configuration
- Designed for MIDI DOBRYNYYA controllers
- Works with compatible media keyboards and remotes

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

Some USB receivers may appear in Karabiner-EventViewer while still being incompatible with Karabiner complex modifications.

---

## Requirements

### Karabiner-Elements

Receives and remaps media-key events.

### Python 3

Runs the Motatel background daemon.

### media-control

Provides playback information and precise media seeking.

### Homebrew

Installs missing dependencies automatically.

### Built-in macOS tools

Motatel also uses:

- `curl`
- `tar`
- `launchctl`
- LaunchAgents

These are already included with macOS.

---

## How it works

Karabiner-Elements receives media-key events and forwards them to the Motatel background daemon.

The daemon communicates with macOS media sessions through **media-control**.

It tracks:

- the current seek direction
- how long the key has been held
- the current acceleration stage
- whether Play/Pause was pressed while seeking

A quick tap remains a normal media key.

Holding Previous or Next starts continuous seeking.

The daemon runs as a LaunchAgent and starts automatically after login.

---

## Updating

Run the installation command again:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/install.sh)"
```

The installer downloads the latest version, replaces the Motatel files, updates the Karabiner rules, creates another configuration backup, and restarts the service.

---

## Uninstall

Open Terminal and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/uninstall.sh)"
```

The uninstaller removes:

- the Motatel daemon
- helper scripts
- the LaunchAgent
- the running background service

Karabiner-Elements, Homebrew, Python and media-control are intentionally left installed because other software may depend on them.

---

## Troubleshooting

### Karabiner was installed but did not open

```bash
open "/Applications/Karabiner-Elements.app"
```

Complete the setup and run the installer again.

### Buttons do nothing

Make sure every required Karabiner permission has been granted.

Restart the service:

```bash
launchctl kickstart -k gui/$(id -u)/com.yarw.media-seek-daemon
```

### Seeking does not work

Verify that media-control is installed:

```bash
media-control --version
```

If it is missing:

```bash
brew install media-control
```

Restart Motatel:

```bash
launchctl kickstart -k gui/$(id -u)/com.yarw.media-seek-daemon
```

### Check whether Motatel is running

```bash
launchctl print gui/$(id -u)/com.yarw.media-seek-daemon
```

### Built-in keyboard works, but another device does not

Open Karabiner-EventViewer and verify that the device sends standard media-key events.

---

## Known limitations

- Karabiner permissions must be approved manually
- Intel Macs are not officially supported
- macOS 12 Monterey and earlier are not officially supported
- Device compatibility depends on its HID or BLE implementation
- Some MIDI DOBRYNYA mappings may not expose every shortcut
- Different media players expose playback information differently
- Some USB media receivers are incompatible with Karabiner complex modifications

---

## Version

**Motatel v1.4**

---

## Author

**Max DetaL**

Built for MIDI DOBRYNYA controllers and everyone who thinks media keys should actually know how to rewind.
