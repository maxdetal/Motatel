# Motatel by Max DetaL

**Hold media keys to seek. Tap to skip.**

Motatel turns the **Previous**, **Next**, and **Play/Pause** media keys on macOS into proper playback controls.

It was originally built for **MIDI DOBRYNYA controllers by Max DetaL**, but it also works with the built-in MacBook keyboard and compatible HID or BLE media devices supported by Karabiner-Elements.

---

## Supported systems

Motatel v1.3 officially supports:

- Apple Silicon Macs
- M1 or newer
- macOS 13 Ventura or later

Intel Macs and macOS 12 Monterey or earlier are not officially supported by Motatel v1.3.

Older macOS versions require legacy Karabiner-Elements releases and may behave differently during installation.

---

## Installation

Open **Terminal**, paste this command, and press Enter:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/install.sh)"
```

That is the entire installation command.

The installer automatically:

- checks your Mac and macOS version
- checks whether Homebrew is installed
- installs Homebrew if necessary
- checks whether Python 3 is installed
- installs Python 3 if necessary
- checks whether media-control is installed
- installs media-control if necessary
- checks whether Karabiner-Elements is installed
- installs Karabiner-Elements if necessary
- opens Karabiner-Elements
- downloads and installs Motatel
- adds the required Karabiner rules
- backs up the existing Karabiner configuration
- installs and starts the background service
- configures Motatel to start automatically after login

### One manual step

macOS does not allow keyboard-control permissions to be granted automatically.

When Karabiner-Elements opens:

1. Follow the setup instructions shown by Karabiner.
2. Approve every requested macOS permission.
3. Return to Terminal.
4. Press **Enter** when the Motatel installer asks you to continue.

Depending on your macOS and Karabiner versions, the requested permissions may include:

- Background Services
- Accessibility
- Input Monitoring
- Driver Extension

After that, Motatel finishes the installation automatically.

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
- Backs up the Karabiner configuration before modifying it
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

### Karabiner-Elements

Receives and remaps media-key events.

Karabiner must remain installed while Motatel is used.

### Python 3

Runs the lightweight Motatel background daemon.

Python 3 must remain installed while Motatel is used.

### media-control

Provides access to macOS media playback information and seeking.

Motatel uses media-control to read the current playback position and perform precise seeking.

### Homebrew

Used by the installer to install missing dependencies.

Homebrew does not need to run in the background.

### Built-in macOS tools

Motatel also uses standard macOS components, including:

- `curl`
- `tar`
- `launchctl`
- LaunchAgents

These are already included with macOS.

---

## How it works

Karabiner-Elements receives media-key events and passes Motatel commands to a lightweight Python daemon.

The daemon communicates with macOS media sessions through **media-control**.

It tracks:

- the active seek direction
- how long the button has been held
- the current acceleration stage
- whether Play/Pause was pressed during seeking

A short press remains a regular track command.

Holding Previous or Next starts continuous seeking.

The daemon is managed by a macOS LaunchAgent and starts automatically after login.

---

## Updating

Run the installation command again:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/install.sh)"
```

The installer downloads the current version, replaces the Motatel files, creates another Karabiner configuration backup, and restarts the service.

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

Karabiner-Elements, Homebrew, Python, and media-control are intentionally left installed because other software may use them.

Motatel's Karabiner rules are currently left in the configuration to avoid accidentally damaging an existing setup.

---

## Troubleshooting

### Karabiner was installed but did not open

Open it manually:

```bash
open "/Applications/Karabiner-Elements.app"
```

Complete the setup, return to Terminal, and run the Motatel installation command again.

### Buttons do nothing

Make sure all Karabiner setup steps have been completed and every requested macOS permission has been granted.

Restart the background service:

```bash
launchctl kickstart -k gui/$(id -u)/com.yarw.media-seek-daemon
```

### Seeking does not work

Verify that media-control is installed:

```bash
media-control --version
```

If the command is missing:

```bash
brew install media-control
```

Then restart Motatel:

```bash
launchctl kickstart -k gui/$(id -u)/com.yarw.media-seek-daemon
```

### Check whether Motatel is running

```bash
launchctl print gui/$(id -u)/com.yarw.media-seek-daemon
```

### Built-in keyboard works, but another device does not

Open Karabiner-EventViewer and verify that the device sends standard media-key events.

A device may appear in EventViewer while still being incompatible with Karabiner complex modifications.

---

## Known limitations

- Karabiner permissions must be approved manually in macOS
- Intel Macs are not officially supported by Motatel v1.3
- macOS 12 Monterey and earlier are not officially supported
- Device compatibility depends on its HID or BLE implementation
- The Play/Pause 60-second jump may not be available on every MIDI DOBRYNYA mapping
- Different media players expose playback information differently
- Some USB media receivers do not trigger Karabiner complex modifications correctly

---

## Version

**Motatel v1.3**

---

## Author

**Max DetaL**

Built for MIDI DOBRYNYA controllers and anyone who thinks media keys should know how to actually rewind.
