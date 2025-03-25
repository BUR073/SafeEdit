@echo off
setlocal enabledelayedexpansion

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
