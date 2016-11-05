#!/bin/sh
config_dir="$HOME/.config/xmind"
if [ ! -d "$config_dir" ]; then
    mkdir "$config_dir"
    cp -ar /opt/xmind-8/_dir/configuration/* "$config_dir"
fi
exec /opt/xmind-8/_dir/XMind -configuration $config_dir -data $config_dir "$@"
