# Safe Edit Bash Script

## Overview

The Safe Edit Bash Script is a tool designed to safely edit files by creating backups before making any changes. The script:

- Creates backups of files in a `./backup` directory.
- Logs backup information in a `backup_log.txt` file.
- Handles platform-specific commands for file manipulation.
- Provides an interactive and user-friendly experience.

## Features

- **Backup before editing**: Automatically backs up files before making changes.
- **Log backups**: Keeps track of backups in `backup_log.txt`.
- **Platform support**: Works on both Linux and macOS systems.
- **Interactive**: Prompts the user for input when needed.

## Prerequisites

- **Bash Shell**: This script is intended to be run in a Bash shell.
- **vi Editor**: The script uses the `vi` editor to edit files.

## Script Breakdown

### 1. `backupFile` Function

This function is responsible for creating a backup of the given file.

- **Input**: Takes a file path as an argument.
- **Operation**:
    - Checks if a backup directory exists (`./backup`), and creates it if necessary.
    - Creates a backup of the specified file with a `.bak` extension.
    - Logs the backup event in `backup_log.txt` (with timestamp).
    - Ensures that only the last 5 backup logs are kept in `backup_log.txt` (older logs are removed).

### 2. `edit` Function

This function is used to edit the specified file.

- **Input**: Takes a file path as an argument.
- **Operation**:
    - Checks if the file exists in the current directory.
    - Calls `backupFile` to create a backup of the file.
    - Opens the file in the `vi` editor for editing.
    - Displays error messages if the file cannot be found or `vi` fails to open.

### 3. Command-Line Usage

The script can be run in different ways:

#### 1 Argument
- **Usage**: `./script.sh <file_path>`
- **Operation**:
    - If exactly one argument is provided, the script will backup and edit the specified file.

#### Multiple Arguments
- **Usage**: `./script.sh <file1> <file2>`
- **Operation**:
    - If more than one argument is provided, an error message will be displayed.

#### No Arguments
- **Usage**: `./script.sh`
- **Operation**:
    - If no arguments are provided, the script will prompt the user to enter the file path they wish to edit.

### 4. Backup Log

The backup log is stored in `backup_log.txt`, with each entry containing the following information:

- Timestamp of the backup.
- The file that was backed up.
- The backup file name.

If the log exceeds 5 lines, the script will remove the oldest entry.

---

## Example Usage

### Example 1: Edit a File with One Argument

```bash
./safe_edit.sh myfile.txt
