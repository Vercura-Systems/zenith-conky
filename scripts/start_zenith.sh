#!/usr/bin/env bash
# Wait for display server and desktop compositor to initialize
sleep 2

# Kill any existing conky instances
killall -q conky || true

# Launch Zenith Conky
exec /usr/bin/conky -c "$HOME/.config/conky/conky.conf"
