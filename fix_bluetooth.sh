#!/bin/bash
set -e
echo -n "Enter MAC address: "
read mac
DEVICE_MAC=mac # Replace with your headphone's MAC address

echo "Unblocking Bluetooth if blocked..."
rfkill unblock bluetooth

echo "Restarting Bluetooth service..."
sudo systemctl restart bluetooth

echo "Loading Bluetooth kernel module..."
sudo modprobe bluetooth || echo "Bluetooth module may already be loaded"

echo "Restarting PipeWire and WirePlumber user services..."
systemctl --user restart pipewire pipewire-pulse wireplumber

echo "Checking PipeWire server name..."
pactl info | grep 'Server Name'

echo "Ensuring user is in bluetooth and audio groups..."
sudo usermod -aG bluetooth,audio $USER && echo "Added $USER to bluetooth and audio groups (logout/login needed)"

echo "Removing old Bluetooth device pairing..."
bluetoothctl remove "$DEVICE_MAC" || echo "Device not previously paired or removed"

echo "Scanning and pairing device..."
bluetoothctl <<EOF
scan on
pair $DEVICE_MAC
trust $DEVICE_MAC
connect $DEVICE_MAC
scan off
EOF

echo "Bluetooth connection script completed. Use pavucontrol to verify audio profile (A2DP)."
