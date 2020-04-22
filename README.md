![xmind logo](xmind-256.png)

# XMind rpm

Unofficial script to create an RPM package for XMind.

## How to use
Open a terminal in the project repository and run `./create-package.sh`

## Features
This rpm package has a lot of advantages over a manual XMind installation:
- Much easier removal: Run `sudo dnf remove xmind` and that's it!
- Sets XMind as the default application for `.xmind` files.
- Adds XMind to the applications' list with a nice HD icon
- Configures XMind properly: The xmind fonts are installed and a configuration directory is created for each user.
- Tested on Fedora 31 (may work on other distributions)

## More informations

### Warning - no accents

The path where you run the script must **not** contain any special character like é, ü, etc. This is a limitation of the rpm tools.

### How to update

When a new version of xmind is released:

1. Download the updated script from github.
2. Run the script to get the updated version.

### Requirements
The `rpmdevtools` package is required to build RPM packages and use the script. If it not installed the script will offer to install it.

### Root privileges
Building an RPM package with root privileges is dangerous, see http://serverfault.com/questions/10027/why-is-it-bad-to-build-rpms-as-root.

### Download speed
Downloading XMind is notoriously slow because of the XMind's servers, not because of my script.