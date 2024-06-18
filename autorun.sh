#!/bin/bash

# Ensure dependencies are installed
while IFS= read -r dependency; do
    if ! command -v "$dependency" &> /dev/null; then
        echo "$dependency is required but not installed. Please install it."
        exit 1
    fi
done < dependencies

# Run the main script
./wifi_monitor.sh
