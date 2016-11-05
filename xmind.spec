# Defined by the caller (ie the script):
# downloaded_dir
# desktop_file
# arch

%define install_dir /opt/xmind-8
%define apps_dir /usr/share/applications

# Disable brp-java-repack-jars which is really slow, and not useful for XMind.
%define __jar_repack 0

Name:		xmind
Version:	8
Release:	0%{?dist}
Summary:	Free Voice and Text Chat for Gamers.

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
mv "%{downloaded_dir}"/* "%{buildroot}%{install_dir}"
cp "%{desktop_file}" "%{buildroot}%{apps_dir}"
chmod +x "%{buildroot}%{install_dir}"/start-xmind.sh

%files
%{install_dir}
%{apps_dir}/*
