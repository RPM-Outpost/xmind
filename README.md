# RPM Package for XMind
A script to create an RPM package of [VisualVM](https://visualvm.github.io/).

## How to use
1. Run the [create-package.sh](https://github.com/RPM-Outpost/xmind/blob/master/create-package.sh) script from the command line. It will download the latest version of XMind and build an RPM package.
2. Then, install the package with `sudo dnf install <rpm file>`.

### Requirements
You need to install the `rpmdevtools` package to build RPM packages and use the script.
Don't worry: the script detects if it isn't installed, and can install it for you.

### About root privileges
Building an RPM package with root privileges is dangerous, because a mistake in SPEC file could result in running nasty commands.
See http://serverfault.com/questions/10027/why-is-it-bad-to-build-rpms-as-root.

### About download speed
Downloading xmind is really slow, and I can't do much about it. It's a problem with the XMind's download servers, not with my script.

## Update xmind
When a new version of visualvm is released, you can run the `create-package.sh` script again to create an updated package.
Then, simply install the updated package with `sudo dnf install <rpm file>`.

## Supported distributions
- Fedora 24
- Fedora 25

It probably work on other RPM-based distros but I haven't tested it. Let me know if it works for you!
