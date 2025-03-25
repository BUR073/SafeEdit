#!/bin/bash

# Safe Edit Bash Script

backupFile(){
    # Define filePath var
    local filePath="$1"  

    # Create timeStamp
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")  

    # Check if the file exists before attempting to back it up
    if [ ! -f "$filePath" ]; then
        echo "Error: $filePath does not exist"
        return 1  # Exit the function if file does not exist
    fi

    # Create backup of file
    cp "$filePath" "$filePath.bak"

    # Check number of lines in backupLog.txt
    local numberOfLines=$(wc -l < backupLog.txt)

    # If backupLog.txt has 5 lines, remove the first one (oldest entry)
    if [ "$numberOfLines" -eq 5 ]; then
        # sed -i '1d' backupLog.txt --> Correct for linux, line below is just so i can test on mac
        # For macOS, use this sed syntax to remove the first line
        sed -i '' '1d' backupLog.txt
    fi    
    
    # Write backup log to the file with timestamp
    echo "[$timestamp] Backup created: $filePath → $filePath.bak" >> backupLog.txt

    echo "Backup of $filePath created successfully at $timestamp"
}



edit(){

    local filePath="$1"
    # Check wether the filepath exists in the current dir
    if [ -f "$filePath" ]; then
        
        # Backup the file
        backupFile "$filePath"

        # Open vim editor 
        vim $filePath

    else
        echo "Error: $filePath does not exist in the current directory."
    fi
}

echo "Welcome to the Safe Edit Bash Script!"
echo "This script will allow you to safely edit a file with backup and logging."

# Check if there is a command line argument
if [ $# -eq 1 ]; then
    # If exactly one argument is given, call edit function
    edit "$1"  # Pass the argument to the edit function
elif [ $# -gt 1 ]; then
    # If more than one argument is given, show an error
    echo "Error: Too many parameters entered."
else
    # Ask user which file they want to edit
    echo "Which file would you like to edit?"

    # Read into var filePath
    read filePath 

    # Call the edit function with the filePath
    edit "$filePath"
fi

