@echo off
setlocal enabledelayedexpansion

:: Start of by calling the main function
goto :main

:: backup file function
:backupFile

:: Define filePath var as the file path that was passed to the function
set "filePath=%~1"

:: Create timeStamp with yyyy-mm-dd h:mm:ss format
for /f "tokens=1-3 delims=/" %%a in ('echo %date%') do (
    set "day=%%a"
    set "month=%%b"
    set "year=%%c"
)

:: Remove any leading spaces 
set "day=%day: =%"

:: Get time with seconds
for /f "tokens=1-3 delims=:." %%a in ('echo %time%') do (
    set "hour=%%a"
    set "minute=%%b"
    set "second=%%c"
)

:: Remove any leading spaces 
set "hour=%hour: =%"

:: Only keep first two digits of seconds
set "second=%second:~0,2%"

:: Format as yyyy-mm-dd h:mm:ss
set "timestamp=%year%-%month%-%day% %hour%:%minute%:%second%"

:: backup dir path
set "backupDir=.\backup"

:: Create backup file name by removing file extension and replacing it with .bak
for %%i in ("%filePath%") do set "backupFileName=%%~ni.bak"

:: Ensure backup directory exists
if not exist "%backupDir%" (

    :: Create folder if it doesn't exist
    mkdir "%backupDir%"
)

:: Create backup of file and save to backup folder
copy "%filePath%" "%backupDir%\%backupFileName%" >nul

:: Check if copy command was successful
if errorlevel 1 (

    :: Show error message to user
    echo Error: Failed to create backup for %filePath%

    :: Exit function
    goto :eof
)

:: Check if the backup_log.txt file exists
if not exist "backup_log.txt" (

    :: Create a new backupLogBatch if one doesn't exist
    type nul > backup_log.txt

    :: Tell user new backupLogBatch has been created
    echo backup_log.txt created

    :: Give the user a chance to read the echo message
    timeout /t 2 >nul
)

:: Check number of lines in backup_log.txt
for /f %%a in ('type "backup_log.txt" ^| find /c /v ""') do set "numberOfLines=%%a"

:: If backup_log.txt has 5 lines, remove the first one
if "%numberOfLines%"=="5" (

    :: Create a temporary file without the first line
    more +1 "backup_log.txt" > "backup_log.tmp"

    :: Replace the original file with the temp file
    move /y "backup_log.tmp" "backup_log.txt" >nul
)

:: Write backup log to the file with timestamp
echo [%timestamp%] Backup created: %filePath% -^> %backupFileName% >> backup_log.txt

:: Tell user the backup has been created
echo Backup of %filePath% created successfully at %timestamp%

:: Sleep to give the user a chance to read the above echo line
timeout /t 2 >nul

goto :eof

:: edit function
:edit

set "filePath=%~1"

:: Check whether the filepath exists in the current dir
if exist "%filePath%" (

    :: Backup the file
    call :backupFile "%filePath%"

    :: Open notepad editor 
    start /wait notepad "%filePath%"

    if errorlevel 1 (
        :: Show user error message if notepad failed to open the file

        echo Error: Failed to open %filePath% with notepad.
    )

) else (

    :: Give user warning message saying the file doesn't exist
    echo Error: %filePath% does not exist in the current directory.
)

goto :eof

:main
:: Check if there is a command line argument
if "%~1" neq "" (
    if "%~2" equ "" (

        :: User welcome message
        echo Welcome to the Safe Editor!

        :: If exactly one argument is given, call edit function
        call :edit "%~1"

    ) else (
        :: If more than one argument is given
        :: Display error message to user
        echo Error: Too many parameters entered.
    )
) else (

    :: User welcome message
    echo Welcome to the Safe Editor!

    :: Ask user which file they want to edit
    echo.

    echo Which file would you like to edit?

    :: Read into var filePath
    set /p filePath=

    :: Call the edit function with the filePath
    call :edit "!filePath!"
)

:end

endlocal