# RPM Package for XMind
All you need to simply build an RPM package of [XMind](http://xmind.net).

## How to use
Run the [create-package.sh](https://github.com/RPM-Outpost/discord/blob/master/create-package.sh) script (from the command line).
It will download the latest version of discord and build an RPM package.
Then, install the package with `sudo dnf install <rpm file>`.

**Note:** You need to install the `rpmdevtools` package to use the script.
Don't worry: the script detects if isn't installed, and can install it for you.

## How to update
When a new version of discord is released, you can run the `create-package.sh` script again to create an updated package.
Then, simply install the updated package with `sudo dnf install <rpm file>`.
