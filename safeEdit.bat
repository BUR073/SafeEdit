@echo off
setlocal enabledelayedexpansion

:: Safe Edit Batch Script

:: Define backup function
:backupFile
set filePath=%1
set timestamp=%DATE% %TIME%

:: Define backup directory
set backupDir=.\backup

:: Check if the file exists before attempting to back it up
if not exist "%filePath%" (
    echo Error: %filePath% does not exist
    exit /b 1
)

:: Ensure backup directory exists
if not exist "%backupDir%" (
    mkdir "%backupDir%"
)

:: Create backup file name by removing file extension and replacing it with .bak
set backupFileName=%filePath:~0,-4%.bak

:: Create backup of file and save to backup folder
copy "%filePath%" "%backupDir%\%backupFileName%" >nul
if errorlevel 1 (
    echo Error: Failed to create backup for %filePath%
    exit /b 1
)

:: Check number of lines in backupLog.txt
set numberOfLines=0
if exist backupLog.txt (
    for /f "delims=" %%A in (backupLog.txt) do (
        set /a numberOfLines+=1
    )
)

:: If backupLog.txt has 5 lines, remove the first one (oldest entry)
if %numberOfLines% geq 5 (
    for /f "skip=1 tokens=* delims=" %%A in (backupLog.txt) do (
        echo %%A >> tempLog.txt
    )
    move /y tempLog.txt backupLog.txt >nul
)

:: Write backup log to the file with timestamp
echo [%timestamp%] Backup created: %filePath% → %backupFileName% >> backupLog.txt

:: Tell user the backup has been created
echo Backup of %filePath% created successfully at %timestamp%

goto :eof

:: Edit function
:edit
set filePath=%1

:: Check if the file exists
if exist "%filePath%" (
    :: Backup the file
    call :backupFile "%filePath%"

    :: Open the file in Notepad (vi is not available in Windows by default)
    notepad "%filePath%"

) else (
    :: Warn user if file doesn't exist
    echo Error: %filePath% does not exist in the current directory.
)

goto :eof

:: Main Script Execution

echo Welcome to the Safe Editor!

:: Check if there is a command line argument
if "%1"=="" (
    :: If no argument, prompt user for file
    echo Which file would you like to edit?
    set /p filePath=

    call :edit "%filePath%"

) else if "%2"=="" (
    :: If exactly one argument is given, call edit function
    call :edit "%1"
) else (
    :: If more than one argument is given, show error
    echo Error: Too many parameters entered.
)
