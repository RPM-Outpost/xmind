#!/bin/sh
# Author: TheElectronWill
# This script downloads the latest version of XMind for linux, and creates a package with rpmbuild.

rpm_dir="$PWD/RPMs"
archive_name='xmind-linux.zip'

desktop_model="$PWD/xmind.desktop"
startsh_model="$PWD/start-xmind.sh"
spec_file="$PWD/xmind.spec"
icon_file="$PWD/xmind-logo.png"

work_dir="$PWD/work"
downloaded_dir="$work_dir/xmind"
desktop_file="$work_dir/xmind.desktop"
startsh_file="$downloaded_dir/start-xmind.sh"
archive_file="$work_dir/$archive_name"

# Checks that rpmbuild is installed
if ! type 'rpmbuild' > /dev/null; then
	echo 'You need the rpm development tools to create rpm packages.'
	read -n 1 -p 'Do you want to install the rpmdevtools package now? [y/N]' answer
	echo
	case "$answer" in
		y|Y)
			sudo -p 'Enter your password to install rpmdevtools: ' dnf install rpmdevtools
			;;
		*) 
			echo "Ok, I won't install rpmdevtools."
			exit
	esac
else
	echo "rpmbuild detected!"
fi

# Download the xmind zip archive.
download_xmind() {
	echo 'Downloading xmind for linux. This may take a while...'
	wget -q --show-progress 'http://dl2.xmind.net/xmind-downloads/xmind-8-update1-linux.zip' -O "$archive_file"
}

# Asks the user if they want to remove the specified directory, and removes it if they want to.
ask_remove_dir() {
	read -n 1 -p "Do you want to remove the \"$1\" directory? [y/N]" answer
	echo
	case "$answer" in
		y|Y)
			rm -r "$1"
			echo "\"$1\" directory removed."		
			;;
		*)
			echo "Ok, I won't remove it."
	esac
}

# If the specified directory exists, asks the user if they want to remove it.
# If it doesn't exist, creates it.
manage_dir() {
	if [ -d "$1" ]; then
		echo "The $2 directory already exist. It may contain outdated things."
		ask_remove_dir "$1"
	fi
	mkdir -p "$1"
}

manage_dir "$work_dir"
manage_dir "$rpm_dir"
cd "$work_dir"

# Download xmind if needed
if [ -e "$archive_name" ]; then
	echo "Found $archive_name"
	read -n 1 -p 'Do you want to use this archive instead of downloading a new one? [y/N]' answer
	echo
	case "$answer" in
		y|Y)
			echo 'Ok, I will use this archive.'
			;;
		*)
			rm "$archive_name"
			download_discord
	esac
else
	download_xmind
fi

# Extracts the archive
echo 'Extracting the files...'
if [ ! -d "$downloaded_dir" ]; then
	mkdir "$downloaded_dir"
fi
unzip -q "$archive_name" -d "$downloaded_dir"

# Gets infos
echo 'Analysing the files...'
arch="$(uname -m)"
if [ "$arch" = "x86_64" ]; then
	executable="$downloaded_dir/XMind_amd64/XMind"
	executable_dir="XMind_amd64"
else
	executable="$downloaded_dir/XMind_i386/XMind"
	executable_dir="XMind_i386"
	arch="i386"
fi
echo "Archive: $archive_name"
echo "Architecture: $arch"
echo "Executable: $executable"

# Creates a .desktop file:
echo 'Creating .desktop file...'
cp "$icon_file" "$downloaded_dir"
cp "$desktop_model" "$desktop_file"
sed "s/@dir/$executable_dir/g" "$startsh_model" > "$startsh_file"

# Fixes XMind.ini:
echo 'Fixing XMind.ini...'
ini_file="$downloaded_dir/$executable_dir/XMind.ini"
user_xmind_config="@user.home/.config/xmind/configuration"
user_xmind_workspace="@user.home/.config/xmind/workspace"
sed -i "s|./configuration|$user_xmind_config|; s|../workspace|$user_xmind_workspace|" "$ini_file"

# Chooses the spec file based on the system's architecture and build the packages
echo 'Creating the RPM package...'
rpmbuild -bb --quiet --nocheck "$spec_file" --define "_topdir $work_dir" --define "_rpmdir $rpm_dir"\
	--define "arch $arch" --define "downloaded_dir $downloaded_dir" --define "desktop_file $desktop_file"

echo '-----------'
echo 'Done!'
echo "The RPM package is located in the \"RPMs/$arch\" folder."

# Removes the work directory if the user wants to
ask_remove_dir "$work_dir"
