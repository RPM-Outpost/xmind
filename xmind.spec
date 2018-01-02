# Defined by the caller (ie the script):
# downloaded_dir
# desktop_file
# arch
# mime_icon

%define install_dir /opt/xmind-8
%define apps_dir /usr/share/applications
%define fonts_dir /usr/share/fonts/truetype/xmind
%define _build_id_links none

# Disable brp-java-repack-jars which is really slow, and not useful for XMind.
%define __jar_repack 0

Name:		xmind
Version:	%{version_number}
Release:	1%{?dist}
Summary:	Powerful mind map editor.

Group:		Applications/Office
License:	EPL, LGPLv3
URL:		https://www.xmind.net/
BuildArch:	%{arch}
Requires:   java, gtk3

# Disable automatic dependency processing, so that the rpm package only
# provides xmind, and not crazy OSGI stuff.
AutoReqProv: no

%description
Mind Mapping Software

%prep

%build

%install
mkdir -p "%{buildroot}%{install_dir}"
mkdir -p "%{buildroot}%{apps_dir}"
mv "%{downloaded_dir}"/* "%{buildroot}%{install_dir}" # Install the app
cp "%{desktop_file}" "%{buildroot}%{apps_dir}" # Install the desktop file
chmod +x "%{buildroot}%{install_dir}/start-xmind.sh" # Make the launch script executable
mkdir -p "%{buildroot}%{fonts_dir}"
cp "%{buildroot}%{install_dir}/fonts"/* "%{buildroot}%{fonts_dir}" # Install the fonts

# Package the files
%files
%{install_dir}
%{apps_dir}/* 
# Important! If the '/*' is removed, the apps_dir will be considered as created by XMind,
# which is not true and problematic, because removing xmind would delete the folder. 
%{fonts_dir}

%post
xdg-mime install --mode system --novendor "%{install_dir}/xmind.xml" # Remove the MIME data
xdg-icon-resource install --context mimetypes --size 64 "%{mime_icon}" application-xmind # Remove the file icons
xdg-icon-resource install --context mimetypes --size 256 "%{mime_icon_big}" application-xmind # Remove the HD file icon
update-desktop-database # Update the MIME database
fc-cache -f # Update the font cache

%preun
xdg-mime uninstall --mode system "%{install_dir}/xmind.xml" # Remove the MIME data
xdg-icon-resource uninstall --context mimetypes --size 64 application-xmind # Remove the small file icon
xdg-icon-resource uninstall --context mimetypes --size 256 application-xmind # Remove the HD file icon
rm -rf /usr/share/fonts/truetype/xmind # Remove fonts
