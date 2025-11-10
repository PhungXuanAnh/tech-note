#!/bin/bash

# Automated file picker interaction script
# This script waits for a file dialog to appear and automatically selects the image file

echo "Starting automated file picker interaction..."

# Function to handle file picker
handle_file_picker() {
    local max_attempts=10
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        echo "Attempt $((attempt + 1)): Looking for file picker dialog..."
        
        # Try different common dialog titles
        DIALOG_ID=$(xdotool search --name "Open" 2>/dev/null | head -1)
        if [ -z "$DIALOG_ID" ]; then
            DIALOG_ID=$(xdotool search --name "Choose.*file" 2>/dev/null | head -1)
        fi
        if [ -z "$DIALOG_ID" ]; then
            DIALOG_ID=$(xdotool search --name "Select.*file" 2>/dev/null | head -1)
        fi
        if [ -z "$DIALOG_ID" ]; then
            DIALOG_ID=$(xdotool search --name "File" 2>/dev/null | head -1)
        fi
        if [ -z "$DIALOG_ID" ]; then
            DIALOG_ID=$(xdotool search --class "nautilus" 2>/dev/null | head -1)
        fi
        
        if [ -n "$DIALOG_ID" ]; then
            echo "Found file dialog with ID: $DIALOG_ID"
            
            # Focus on the dialog
            xdotool windowfocus $DIALOG_ID
            sleep 0.5
            
            # Navigate to the file location by typing the path
            echo "Typing file path..."
            xdotool key --window $DIALOG_ID ctrl+l
            sleep 0.15
            xdotool type --window $DIALOG_ID "/home/xuananh/Downloads/vm-screenshot/"
            xdotool key --window $DIALOG_ID Return
            sleep 0.15
            
            # Select the image file
            echo "Selecting image.png..."
            xdotool type --window $DIALOG_ID "image.png"
            sleep 0.15

            # Press Enter or click Open button
            xdotool key --window $DIALOG_ID Return
            
            echo "File selection completed!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        sleep 0.5
    done
    
    echo "File picker dialog not found after $max_attempts attempts"
    return 1
}

# Run the file picker handler
handle_file_picker

echo "Automated file picker script done"