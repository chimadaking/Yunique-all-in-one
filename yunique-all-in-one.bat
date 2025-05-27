@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: -----------------------
:: Version info
set "version=0.9"
set "scriptName=%~nx0"

:: -----------------------
:: Update URLs on GitHub (edit these to your repo/raw URLs after upload)
set "versionUrl=https://raw.githubusercontent.com/chimadaking/Yunique-all-in-one/main/version.txt"
set "updateUrl=https://raw.githubusercontent.com/chimadaking/Yunique-all-in-one/main/yunique-all-in-one.bat"
:: -----------------------
:: Auto-elevate to admin if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: -----------------------
:: Check for updates function
call :CheckForUpdates

:: -----------------------
:: Show main menu loop
:MainMenu
cls
echo ================================
echo   Yunique All-in-One Tool v%version%
echo ================================
echo.
echo [1] Reset User Password
echo [2] Rename User
echo [3] Create New User
echo [4] Delete User
echo [5] Microsoft Defender Control Panel
echo [6] Activate Windows/Office
echo [7] Online Activation (Office & Windows)
echo [0] Exit
echo.
set /p choice=Choose an option: 

if "%choice%"=="1" call :ResetPassword & goto MainMenu
if "%choice%"=="2" call :RenameUser & goto MainMenu
if "%choice%"=="3" call :CreateNewUser & goto MainMenu
if "%choice%"=="4" call :DeleteUser & goto MainMenu
if "%choice%"=="5" call :DefenderControl & goto MainMenu
if "%choice%"=="6" call :ActivateOffline & goto MainMenu
if "%choice%"=="7" call :ActivateOnline & goto MainMenu
if "%choice%"=="0" exit /b

echo Invalid option, try again.
pause
goto MainMenu

:: -----------------------
:: Function Definitions

:CheckForUpdates
echo Checking for updates...
powershell -Command ^
  "try {^
    $remoteVersion = (Invoke-WebRequest -UseBasicParsing '%versionUrl%').Content.Trim(); ^
    if ([version]'%version%' -lt [version]$remoteVersion) { ^
        Write-Host 'Update found! Downloading new version...'; ^
        Invoke-WebRequest -Uri '%updateUrl%' -OutFile 'update_temp.bat' -UseBasicParsing; ^
        Start-Sleep -Seconds 1; ^
        Move-Item -Force 'update_temp.bat' '%scriptName%'; ^
        Write-Host 'Update applied. Please restart the script.'; ^
        exit 2; ^
    } else { ^
        Write-Host 'You have the latest version.'; ^
    } ^
  } catch { ^
    Write-Host 'Update check failed: ' $_.Exception.Message; ^
  }"
if %errorlevel%==2 (
    echo.
    echo Script updated successfully. Please restart.
    exit /b
)
echo.

exit /b

:ResetPassword
cls
echo *** Reset User Password to Blank ***
echo.
set /p "username=Enter username to reset password: "
if "%username%"=="" (
    echo Username cannot be empty.
    pause
    exit /b
)
net user "%username%" "" >nul 2>&1
if %errorlevel% neq 0 (
    echo User "%username%" not found or error resetting password.
) else (
    echo Password for "%username%" reset to blank.
)
pause
exit /b

:RenameUser
cls
echo *** Rename User Account ***
echo.
set /p "oldname=Enter existing username: "
if "%oldname%"=="" (
    echo Username cannot be empty.
    pause
    exit /b
)
set /p "newname=Enter new username: "
if "%newname%"=="" (
    echo New username cannot be empty.
    pause
    exit /b
)
wmic useraccount where name="%oldname%" rename "%newname%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to rename user "%oldname%" to "%newname%".
) else (
    echo User "%oldname%" renamed to "%newname%".
)
pause
exit /b

:CreateNewUser
cls
echo *** Create New User Account ***
echo.
set /p "newuser=Enter new username: "
if "%newuser%"=="" (
    echo Username cannot be empty.
    pause
    exit /b
)
set /p "newpass=Enter password (leave blank for no password): "
net user "%newuser%" "%newpass%" /add >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to create user "%newuser%".
) else (
    echo User "%newuser%" created successfully.
)
pause
exit /b

:DeleteUser
cls
echo *** Delete User Account ***
echo.
set /p "deluser=Enter username to delete: "
if "%deluser%"=="" (
    echo Username cannot be empty.
    pause
    exit /b
)
net user "%deluser%" /delete >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to delete user "%deluser%".
) else (
    echo User "%deluser%" deleted successfully.
)
pause
exit /b

:DefenderControl
cls
echo *** Microsoft Defender Control Panel ***
echo.
echo [1] Disable Temporarily (Real-time protection off)
echo [2] Disable Permanently (Group Policy style)
echo [3] Enable Temporarily
echo [4] Enable Permanently
echo.
set /p dchoice=Select an option (1-4): 

if "%dchoice%"=="1" (
    powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
    echo Real-time protection disabled temporarily.
) else if "%dchoice%"=="2" (
    powershell -Command "New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Force | Out-Null; Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -Value 1"
    echo Microsoft Defender disabled permanently. Restart required.
) else if "%dchoice%"=="3" (
    powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false"
    echo Real-time protection enabled temporarily.
) else if "%dchoice%"=="4" (
    powershell -Command "Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -ErrorAction SilentlyContinue"
    echo Microsoft Defender enabled permanently. Restart required.
) else (
    echo Invalid option.
)
pause
exit /b

:ActivateOffline
cls
echo *** Activate Windows / Office (Offline) ***
echo.
:: Run your offline activation script here, assuming it's called activate-offline.cmd
if exist activate-offline.cmd (
    call activate-offline.cmd
) else (
    echo Offline activation script not found!
)
pause
exit /b

:ActivateOnline
cls
echo *** Online Activation for Windows & Office ***
echo.
echo Running online activation script...
powershell -Command "irm https://get.activated.win | iex"
echo.
pause
exit /b
