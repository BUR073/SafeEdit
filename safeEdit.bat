@echo off
setlocal enabledelayedexpansion

:: Safe Edit Batch Script

:: Main program execution starts here
goto :main

:: backup file function
:backupFile

:: Define filePath var as the file path that was passed to the function
set "filePath=%~1"

:: Create timeStamp
for /f "tokens=1-6 delims=/: " %%a in ('echo %date% %time%') do (
    set "timestamp=%%c-%%a-%%b %%d:%%e:%%f"
)

:: Define backup dir path
set "backupDir=.\backupBatch"

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
:: Check if the backupLogBatch.txt file exists
if not exist "backupLogBatch.txt" (

    :: Create a new backupLogBatch if one doesn't exist
    type nul > backupLogBatch.txt

    :: Tell user new backupLogBatch has been created
    echo backupLogBatch.txt created

    :: Give the user a chance to read the echo message
    timeout /t 2 >nul
)

:: Check number of lines in backupLogBatch.txt
for /f %%a in ('type "backupLogBatch.txt" ^| find /c /v ""') do set "numberOfLines=%%a"

:: If backupLogBatch.txt has 5 lines, ::ove the first one
if "%numberOfLines%"=="5" (

    :: Create a temporary file without the first line
    more +1 "backupLogBatch.txt" > "backupLogBatch.tmp"

    :: Replace the original file with the temp file
    move /y "backupLogBatch.tmp" "backupLogBatch.txt" >nul
)

:: Write backup log to the file with timestamp
echo [%timestamp%] Backup created: %filePath% → %backupFileName% >> backupLogBatch.txt

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
    :: Open notepad editor (since vi isn't standard on Windows)

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
echo Thank you for using Safe Editor!
endlocal