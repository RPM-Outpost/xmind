#!/bin/bash
# Author: TheElectronWill
# This script downloads the latest version of XMind for linux, and creates a package with rpmbuild.

source terminal-colors.sh # Adds color variables
source common-functions.sh # Adds utilities functions
source basic-checks.sh # Checks that rpmbuild is available and that the script isn't started as root

rpm_dir="$PWD/RPMs"
archive_name='xmind-linux.zip'
version_number='8.9'
download_url='http://dl2.xmind.net/xmind-downloads/xmind-8-update9-linux.zip'

icon_name="xmind-256.png"
startsh_name="start-xmind.sh"

desktop_model="$PWD/xmind.desktop"
startsh_model="$PWD/$startsh_name"
icon256_file="$PWD/$icon_name"
icon64_file="$PWD/xmind-64.png"

mime_spec='xmind.xml'
mime_spec_file="$PWD/$mime_spec"
spec_file="$PWD/xmind.spec"

work_dir="$PWD/work"
downloaded_dir="$work_dir/xmind"
desktop_file="$work_dir/xmind.desktop"
startsh_file="$downloaded_dir/start-xmind.sh"
archive_file="$work_dir/$archive_name"

# Downloads the xmind zip archive.
download_xmind() {
	echo 'Downloading xmind for linux. This may take a while...'
	wget -q $wget_progress "$download_url" -O "$archive_file"
}

manage_dir "$work_dir" 'work'
manage_dir "$rpm_dir" 'RPMs'
cd "$work_dir"

# Downloads xmind if needed.
if [ -e "$archive_name" ]; then
	echo "Found the archive \"$archive_name\"."
	ask_yesno 'Do you want to use this archive instead of downloading a new one?' answer
	case "$answer" in
		y|Y)
			echo 'Existing archive selected.'
			;;
		*)
			rm "$archive_name"
			download_xmind
	esac
else
	download_xmind
fi

# Extracts the files:
echo
if [ ! -d "$downloaded_dir" ]; then
	mkdir "$downloaded_dir"
fi
extract "$archive_name" "$downloaded_dir"


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
echo " -- Archive: $archive_name"
echo " -- Architecture: $arch"
echo " -- Executable: $executable"


echo 'Creating .desktop file...'
cp "$mime_spec_file" "$downloaded_dir"
cp "$icon256_file" "$downloaded_dir"
cp "$desktop_model" "$desktop_file"
sed "s/@dir/$executable_dir/g" "$startsh_model" > "$startsh_file"
sed "s/@version/$version_number/; s/@icon/$icon_name/; s/@exe/$startsh_name/" "$desktop_model" > "$desktop_file"


echo 'Fixing XMind.ini...'
ini_file="$downloaded_dir/$executable_dir/XMind.ini"
user_xmind_config="@user.home/.config/xmind/configuration"
user_xmind_workspace="@user.home/.config/xmind/workspace"
sed -i "s|./configuration|$user_xmind_config|; s|../workspace|$user_xmind_workspace|" "$ini_file"


disp "${yellow}Creating the RPM package (this may take a while)..."
rpmbuild -bb --quiet --nocheck "$spec_file" --define "_topdir $work_dir" --define "_rpmdir $rpm_dir"\
	--define "arch $arch" --define "downloaded_dir $downloaded_dir" --define "desktop_file $desktop_file"\
	--define "mime_icon $icon64_file" --define "mime_icon_big $icon256_file" --define "mime_spec $mime_spec"\
	--define "version_number $version_number"

disp "${bgreen}Done!${reset_font}"
disp "The RPM package is located in the \"RPMs/$arch\" folder."
disp '----------------'

ask_remove_dir "$work_dir"
ask_installpkg
