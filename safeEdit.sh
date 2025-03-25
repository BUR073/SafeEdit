#!/bin/bash

# Safe Edit Bash Script

# backup file function
backupFile(){

    # Define filePath var
    local filePath="$1"  

    # Create timeStamp
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")  

    # Define backup dir path
    local backupDir="./backup"

    # Check if the file exists before attempting to back it up
    if [ ! -f "$filePath" ]; then

        # Show user error message
        echo "Error: $filePath does not exist"

        # Exit the function if file does not exist
        return 1  
    fi

    # Ensure backup directory exists
    if [ ! -d "$backupDir" ]; then

        # Create folder if it doesn't exist
        mkdir -p "$backupDir"
    fi

    # Create backup file name by removing file extension and replacing it with .bak
    backupFileName="${filePath%.*}.bak"

    # Create backup of file and save to backup folder
    cp "$filePath" "$backupDir/$(basename "$backupFileName")"

    # Check if cp command was successful
    if [ $? -ne 0 ]; then

        # Show error message to user
        echo "Error: Failed to create backup for $filePath"

        # Exit program
        return 1
    fi

    # Check number of lines in backupLog.txt
    local numberOfLines=$(wc -l < backupLog.txt)

    # Check if the backupLog.txt file exists
    if [ ! -f "backupLog.txt" ]; then

        # Create a new backupLog if one doesn't exist
        touch backupLog.txt

        # Tell user new backupLog has been created
        echo "backupLog.txt created"
    fi

    # If backupLog.txt has 5 lines, remove the first one (oldest entry)
    if [ "$numberOfLines" -eq 5 ]; then

        # Check platform as the sed command syntax is different on macOS and linux
        if [[ "$OSTYPE" == "darwin"* ]]; then

            # For macOS
            sed -i '' '1d' backupLog.txt

        else

            # For linux
            sed -i '1d' backupLog.txt
        fi
    fi    
    
    # Write backup log to the file with timestamp
    echo "[$timestamp] Backup created: $filePath → $backupFileName" >> backupLog.txt

    # Tell user the backup has been created
    echo "Backup of $filePath created successfully at $timestamp"
}


# edit function
edit(){

    local filePath="$1"
    # Check wether the filepath exists in the current dir
    if [ -f "$filePath" ]; then
        
        # Backup the file
        backupFile "$filePath"

        # Open vi editor
        if ! vi "$filePath"; then
        
            # Show user error message if vi failed to open the file
            echo "Error: Failed to open $filePath with vi."
        fi   

    else

        # Give user warning message saying the file doesn't exist 
        echo "Error: $filePath does not exist in the current directory."
    fi
}

# User welcome message
echo "Welcome to the Safe Editor!"

# Check if there is a command line argument
if [ $# -eq 1 ]; then

    # If exactly one argument is given, call edit function
    edit "$1"  

    # If more than one argument is given
elif [ $# -gt 1 ]; then

    # Display error message too user
    echo "Error: Too many parameters entered."
else

    # Ask user which file they want to edit
    echo "Which file would you like to edit?"

    # Read into var filePath
    read -r filePath 

    # Call the edit function with the filePath
    edit "$filePath"
fi

