Motatel by Max DetaL v1.3
=========================

Hold media keys to seek. Tap to skip.

SUPPORTED SYSTEMS
-----------------

Apple Silicon Macs only.
M1 or newer.
macOS 13 Ventura or later.

Intel Macs and macOS 12 or earlier are not officially supported.

INSTALLATION
------------

Open Terminal and run:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/install.sh)"

The installer automatically:

- checks system compatibility
- installs Homebrew (if needed)
- installs Python 3 (if needed)
- installs media-control (if needed)
- installs Karabiner-Elements (if needed)
- installs Motatel
- configures Karabiner
- installs and starts the background service

When Karabiner-Elements opens, follow its setup instructions
and approve all permissions requested by macOS.

Return to Terminal and press Enter when prompted.

WHAT IT DOES
------------

Previous / Next

Tap:
Previous or next track.

Hold:
Continuous seeking backward or forward.

Play/Pause

Normal press:
Regular Play/Pause.

Press while seeking:
Jump 60 seconds in the active direction.

SEEKING PROFILE
---------------

Up to 1 second:
20-second seek steps.

From 1 to 2.5 seconds:
35-second seek steps.

After 2.5 seconds:
60-second seek steps.

COMPATIBLE DEVICES
------------------

- MacBook built-in keyboard
- Apple keyboards
- MIDI DOBRYNYA controllers
- Compatible BLE media controllers
- Compatible HID keyboards and remotes

UNINSTALL
---------

Open Terminal and run:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/maxdetal/Motatel/main/uninstall.sh)"

AUTHOR
------

Max DetaL

VERSION
-------

1.3
