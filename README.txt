Motatel by Max DetaL v1.3
=========================

Continuous media seeking for macOS.

Originally built for MIDI DOBRYNYA controllers by Max DetaL.

------------------------------------------------------------
WHAT IT DOES
------------------------------------------------------------

Previous / Next

• Tap
  Previous / Next track

• Hold
  Continuous seeking

• Hold + Play/Pause
  Jump ±60 seconds in the current seek direction

Seek speed increases automatically while holding the button.

------------------------------------------------------------
REQUIREMENTS
------------------------------------------------------------

Before installing Motatel, make sure you have:

✓ Homebrew

✓ Python 3

✓ Karabiner-Elements

Launch Karabiner-Elements at least once and approve all
requested macOS permissions.

------------------------------------------------------------
INSTALLATION
------------------------------------------------------------

If Homebrew is not installed:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Install Python:

brew install python

Install Karabiner-Elements:

brew install --cask karabiner-elements

Launch Karabiner once:

open -a "Karabiner-Elements"

Approve the requested macOS permissions.

Then install Motatel:

bash install.sh

------------------------------------------------------------
WHAT THE INSTALLER DOES
------------------------------------------------------------

• installs Motatel

• installs the background daemon

• installs helper scripts

• installs the LaunchAgent

• patches your Karabiner configuration

• creates a backup before modifying anything

• starts automatically after login

------------------------------------------------------------
UNINSTALL
------------------------------------------------------------

bash uninstall.sh

------------------------------------------------------------
AUTHOR
------------------------------------------------------------

Max DetaL

https://github.com/maxdetal

------------------------------------------------------------
VERSION
------------------------------------------------------------

1.3
