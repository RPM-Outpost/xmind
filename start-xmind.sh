#!/bin/sh
config_dir="$HOME/.config/xmind/configuration"
if [ ! -d "$config_dir" ]; then
	mkdir -p "$config_dir"
	cp -ar /opt/xmind-8/@dir/configuration/* "$config_dir"
fi
exec /opt/xmind-8/@dir/XMind "$@"
