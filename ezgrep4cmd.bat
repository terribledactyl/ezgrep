@echo off
setlocal enabledelayedexpansion

:: Function to get user input
:input
set /p "inputPrompt= %1"
echo.
exit /b

:: Function to search for keywords
:search
set "dir=%1"
set "keyword=%2"
set "caseSensitive=%3"
set "wholeWord=%4"
set "recursion=%5"

if "%recursion%"=="Y" (
    set "flags=/S"
) else (
    set "flags="
)

for /r "%dir%" %%f in (*) do (
    if exist "%%f" (
        set "fileContent="
        for /f "delims=" %%l in ('type "%%f"') do set "fileContent=!fileContent! %%l"
        
        if "%caseSensitive%"=="N" (
            set "fileContent=!fileContent:~0,1!"
        )
        
        if "%wholeWord%"=="Y" (
            echo !fileContent! | findstr /R /C:"\b%keyword%\b" >nul 2>&1
        ) else (
            echo !fileContent! | findstr /C:"%keyword%" >nul 2>&1
        )

        if !errorlevel! equ 0 (
            echo Match found in file: %%f
        )
    )
)

exit /b

:: Main script
echo Enter the directory to search in:
set /p "directory="
if not exist "%directory%" (
    echo The directory "%directory%" does not exist.
    exit /b
)

echo Enter the keywords to search for (separated by commas):
set /p "keywords="
set "keywords=%keywords:,= %"

echo Do you want to search recursively through subdirectories? (Y/N):
set /p "recursionChoice="

echo Do you want the search to be case-sensitive? (Y/N):
set /p "caseSensitiveChoice="

echo Do you want to match whole words only? (Y/N):
set /p "wholeWordChoice="

echo.

for %%k in (%keywords%) do (
    call :search "%directory%" "%%k" "%caseSensitiveChoice%" "%wholeWordChoice%" "%recursionChoice%"
)

echo Search complete.
endlocal
