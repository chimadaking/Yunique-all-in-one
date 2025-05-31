@echo off
title Yunique All-in-One v1.0
:: Auto-elevate to Admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:MENU
cls
echo ============================================
echo         Yunique All-in-One v1.0
echo ============================================
echo [1] Show System Info
echo [2] Activate Windows & Office (Online)
echo [3] Activate IDM (Online)
echo [4] Disable Microsoft Defender (Temp/Permanent)
echo [5] Reset All Local User Passwords to Blank
echo [6] Clean Temp, Recycle Bin & Old Updates
echo [7] Disable Windows Updates
echo [0] Exit
echo ============================================
set /p choice=Enter your choice: 

if "%choice%"=="1" goto SYSINFO
if "%choice%"=="2" goto ACTIVATE
if "%choice%"=="3" goto IDM
if "%choice%"=="4" goto DISABLEDEFENDER
if "%choice%"=="5" goto RESETPASSWORD
if "%choice%"=="6" goto CLEAN
if "%choice%"=="7" goto DISABLEUPDATE
if "%choice%"=="0" exit
goto MENU

:SYSINFO
cls
powershell -Command "Get-ComputerInfo | Select-Object CsName, WindowsProductName, WindowsVersion, OsArchitecture | Format-List"
goto FOOTER

:ACTIVATE
cls
echo Activating Windows & Office Online...
powershell -Command "irm https://get.activated.win | iex"
goto FOOTER

:IDM
cls
echo Activating IDM Online...
powershell -Command "iex(irm is.gd/idm_reset)"
goto FOOTER

:DISABLEDEFENDER
cls
echo [1] Disable Temporarily (Real-time protection off)
echo [2] Disable Permanently (Group Policy style)
echo [3] Re-enable Temporarily
echo [4] Re-enable Permanently
set /p defopt=Select an option (1-4): 
powershell -Command ^
    "switch ('%defopt%') { ^
        '1' { Set-MpPreference -DisableRealtimeMonitoring $true; 'Temporarily disabled' } ^
        '2' { New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Force | Out-Null; Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -Value 1; 'Permanently disabled' } ^
        '3' { Set-MpPreference -DisableRealtimeMonitoring $false; 'Temporarily enabled' } ^
        '4' { Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -ErrorAction SilentlyContinue; 'Permanently enabled' } ^
        default { 'Invalid option' } }"
goto FOOTER

:RESETPASSWORD
cls
echo Resetting all local user passwords to blank...
powershell -Command ^
  "$users = Get-LocalUser | Where-Object { -not $_.Disabled -and $_.Name -ne 'Administrator' }; ^
   foreach ($user in $users) { ^
     try { ^
       net user $user.Name \"\" ^
       Write-Host \"Password cleared for: $($user.Name)\" -ForegroundColor Green ^
     } catch { Write-Host \"Failed for: $($user.Name)\" -ForegroundColor Red } }"
goto FOOTER

:CLEAN
cls
echo Cleaning Temp, Recycle Bin & Windows Update Cache...
powershell -Command ^
  "Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; ^
   Clear-RecycleBin -Force -ErrorAction SilentlyContinue; ^
   Remove-Item 'C:\Windows\SoftwareDistribution\Download\*' -Recurse -Force -ErrorAction SilentlyContinue"
echo Done.
goto FOOTER

:DISABLEUPDATE
cls
echo Disabling Windows Updates...
sc stop wuauserv >nul
sc config wuauserv start= disabled >nul
echo Windows Updates Disabled.
goto FOOTER

:FOOTER
echo.
echo ============================================
echo ==> Made with ^<3 by Chimayu | Yunique All-in-One v1.0
pause
goto MENU
