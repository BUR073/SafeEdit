@echo off
setlocal enabledelayedexpansion

:: backupFile function
:backupFile

:: set filePath to the var passed into the function
set filePath=%1

:: Create a timestamp 
for /f "tokens=1-4 delims=/- " %%a in ('date /t') do (
    set day=%%a
    set month=%%b
    set year=%%c
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set hour=%%a
    set minute=%%b
)
set timestamp=%year%-%month%-%day% %hour%:%minute%

:: Define backup dir path
set backupDir=backupBatch

:: Check if the file exists before attempting to back it up
if not exist "%filePath%" (
    echo Error: %filePath% does not exist
    goto :eof
)

:: Ensure backup directory exists
if not exist "%backupDir%" (
    mkdir "%backupDir%"
)

:: Create backup file name by removing the extension and adding .bak
set backupFileName=%filePath:.bak=%
set backupFileName=%backupFileName%.bak

:: Create backup of file and save to backup folder
copy "%filePath%" "%backupDir%\%backupFileName%"

:: Check if the copy command was successful
if errorlevel 1 (
    echo Error: Failed to create backup for %filePath%
    goto :eof
)

:: Check the number of lines in backupLogBash.txt
set /a numberOfLines=0
for /f "delims=" %%a in (backupLogBash.txt) do set /a numberOfLines+=1

:: Check if backupLogBash.txt exists
if not exist backupLogBash.txt (
    echo backupLogBash.txt created
    echo. > backupLogBash.txt
)

:: If backupLogBash.txt has 5 lines, remove the first one (oldest entry)
if %numberOfLines% geq 5 (
    for /f "skip=1 delims=" %%a in (backupLogBash.txt) do echo %%a >> tempLog.txt
    move /y tempLog.txt backupLogBash.txt
)

:: Write backup log to the file with timestamp
echo [%timestamp%] Backup created: %filePath% → %backupFileName% >> backupLogBash.txt

:: Tell user the backup has been created
echo Backup of %filePath% created successfully at %timestamp%
goto :eof


:: edit function
:edit
set filePath=%1

:: Check if the file exists in the current directory
if exist "%filePath%" (

    :: Backup the file 
    call :backupFile "%filePath%"

    :: Try to open the file with a text editor 
    start "" notepad "%filePath%"

    :: Check if the editor failed to open
    if errorlevel 1 (
        echo Error: Failed to open %filePath% with Notepad.
    )

) else (
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

    call :edit "!filePath!"

) else if "%2"=="" (
    :: If exactly one argument is given, call edit function
    call :edit "%1"

) else (
    :: If more than one argument is given, show error
    echo Error: Too many parameters entered.
)

pause
