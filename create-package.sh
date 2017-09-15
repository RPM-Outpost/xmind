#!/bin/sh
# Author: TheElectronWill
# This script downloads the latest version of XMind for linux, and creates a package with rpmbuild.

rpm_dir="$PWD/RPMs"
archive_name='xmind-linux.zip'

desktop_model="$PWD/xmind.desktop"
startsh_model="$PWD/start-xmind.sh"
icon256_file="$PWD/xmind-256.png"
icon64_file="$PWD/xmind-64.png"

mime_spec='xmind.xml'
mime_spec_file="$PWD/$mime_spec"
spec_file="$PWD/xmind.spec"

work_dir="$PWD/work"
downloaded_dir="$work_dir/xmind"
desktop_file="$work_dir/xmind.desktop"
startsh_file="$downloaded_dir/start-xmind.sh"
archive_file="$work_dir/$archive_name"

# It's a bad idea to run rpmbuild as root!
if [ "$(id -u)" = "0" ]; then
	echo '------------------------ WARNING ------------------------'
	echo 'This script should NOT be executed with root privileges!'
	echo 'Building rpm packages as root is dangerous and may harm the system!'
	echo 'Actually, badly written RPM spec files may execute dangerous command in the system directories.'
	echo 'So it is REALLY safer not to run this script as root.'
	echo 'If you still want to run this script as root, type "do it!" within 5 seconds (type anything else to exit):'
	read -t 5 -n 6 -p 'Do you really want to do it (not recommended)? ' answer
	if [ "$answer" != "do it!" ]; then
		exit
	fi
	echo '------------------------ WARNING ------------------------'
	echo
fi

# Checks that the rpmbuild package is installed.
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

# Downloads the xmind zip archive.
download_xmind() {
	echo 'Downloading xmind for linux. This may take a while...'
	wget -q --show-progress 'http://dl2.xmind.net/xmind-downloads/xmind-8-update4-linux.zip' -O "$archive_file"
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
	echo
}

# If the specified directory exists, asks the user if they want to remove it.
# If it doesn't exist, creates it.
manage_dir() {
	if [ -d "$1" ]; then
		echo "The $2 directory already exist and may contain outdated data."
		ask_remove_dir "$1"
	fi
	mkdir -p "$1"
}

manage_dir "$work_dir" 'work'
manage_dir "$rpm_dir" 'RPMs'
cd "$work_dir"

# Downloads xmind if needed.
if [ -e "$archive_name" ]; then
	echo "Found the archive \"$archive_name\"."
	read -n 1 -p 'Do you want to use this archive instead of downloading a new one? [y/N]' answer
	echo
	case "$answer" in
		y|Y)
			echo 'Ok, I will use this archive.'
			;;
		*)
			rm "$archive_name"
			download_xmind
	esac
else
	download_xmind
fi


echo
echo 'Extracting the files...'
if [ ! -d "$downloaded_dir" ]; then
	mkdir "$downloaded_dir"
fi
unzip -q "$archive_name" -d "$downloaded_dir"


echo 'Analysing the files...'
dir64='XMind_amd64'
dir32='XMind_i386'
arch="$(uname -m)"
if [ "$arch" = "x86_64" ]; then
	executable="$downloaded_dir/$dir64/XMind"
	executable_dir="$dir64"
	rm -r "$downloaded_dir/$dir32" # Removes the other architecture.
elif [ "$arch" = "i386" ] || [ "$arch" = "i686" ]; then
	executable="$downloaded_dir/$dir32/XMind"
	executable_dir="$dir32"
	rm -r "$downloaded_dir/$dir64" # Removes the other architecture.
	arch="i386"
else
	echo '------------------------- ERROR -------------------------'
	echo "Your architecture ($arch) is not supported by XMind. Sorry :("
	exit 2
fi
echo "    Archive: $archive_name"
echo "    Architecture: $arch"
echo "    Executable: $executable"


echo 'Creating .desktop file...'
cp "$mime_spec_file" "$downloaded_dir"
cp "$icon256_file" "$downloaded_dir"
cp "$desktop_model" "$desktop_file"
sed "s/@dir/$executable_dir/g" "$startsh_model" > "$startsh_file"


echo 'Fixing XMind.ini...'
ini_file="$downloaded_dir/$executable_dir/XMind.ini"
user_xmind_config="@user.home/.config/xmind/configuration"
user_xmind_workspace="@user.home/.config/xmind/workspace"
sed -i "s|./configuration|$user_xmind_config|; s|../workspace|$user_xmind_workspace|" "$ini_file"


echo 'Creating the RPM package (this may take a while)...'
rpmbuild -bb --quiet --nocheck "$spec_file" --define "_topdir $work_dir" --define "_rpmdir $rpm_dir"\
	--define "arch $arch" --define "downloaded_dir $downloaded_dir" --define "desktop_file $desktop_file"\
	--define "mime_icon $icon64_file" --define "mime_spec $mime_spec"

echo
echo '------------------------- Done! -------------------------'
echo "The RPM package is located in the \"RPMs/$arch\" folder."
ask_remove_dir "$work_dir"
