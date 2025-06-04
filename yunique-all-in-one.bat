@echo off
:: Yunique All-in-One Tool v1.0
:: Author: Chimayu | Updated for professional structure & beginner safety
:: Description: System utility script with admin auto-elevation

:: === Auto-Elevate to Admin ===
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] Administrator privileges required. Requesting elevation...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:MENU
cls
color 0A
setlocal EnableDelayedExpansion

:: === Main Menu ===
echo ====================================================
echo             Yunique All-in-One Utility v1.0
echo ====================================================
echo [1] View System Information
echo [2] Activate Windows & Office (Online)
echo [3] Activate Internet Download Manager (Online)
echo [4] Toggle Microsoft Defender Protection
echo [5] Reset Local User Passwords to Blank
echo [6] Clean System (Temp, Recycle Bin, Update Cache)
echo [7] Disable Windows Update Service
echo [0] Exit
echo ====================================================
set /p choice=Enter your choice (0-7): 

if "%choice%"=="1" goto SYSINFO
if "%choice%"=="2" goto ACTIVATE
if "%choice%"=="3" goto IDM
if "%choice%"=="4" goto DEFENDER
if "%choice%"=="5" goto RESETPASS
if "%choice%"=="6" goto CLEANUP
if "%choice%"=="7" goto DISABLEUPDATES
if "%choice%"=="0" exit

echo Invalid choice. Please try again.
pause
goto MENU

:SYSINFO
cls
echo [System Information]
powershell -NoProfile -Command "Get-ComputerInfo | Select-Object CsName, WindowsProductName, WindowsVersion, OsArchitecture | Format-List"
goto FOOTER

:ACTIVATE
cls
echo [Activating Windows & Office...]
powershell -NoProfile -Command "irm https://get.activated.win | iex"
goto FOOTER

:IDM
cls
echo [Activating IDM...]
powershell -NoProfile -Command "iex(irm is.gd/idm_reset)"
goto FOOTER

:DEFENDER
cls
echo [Toggle Microsoft Defender Options]
echo  [1] Disable Temporarily
set "opt=0"
echo  [2] Disable Permanently
set /p opt=Select an option (1-4): 
if "%opt%"=="1" (powershell -NoProfile -Command "Set-MpPreference -DisableRealtimeMonitoring $true")
if "%opt%"=="2" (powershell -NoProfile -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name DisableAntiSpyware -Value 1")
if "%opt%"=="3" (powershell -NoProfile -Command "Set-MpPreference -DisableRealtimeMonitoring $false")
if "%opt%"=="4" (powershell -NoProfile -Command "Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name DisableAntiSpyware -ErrorAction SilentlyContinue")
if "%opt%"=="" goto DEFENDER
goto FOOTER

:RESETPASS
cls
echo [Resetting Local User Passwords to Blank...]
powershell -NoProfile -Command "Get-LocalUser | Where-Object { -not $_.Disabled -and $_.Name -ne 'Administrator' } | ForEach-Object { net user $_.Name \"\" }"
echo Operation complete.
goto FOOTER

:CLEANUP
cls
echo [Cleaning Temporary Files, Recycle Bin, and Update Cache...]
powershell -NoProfile -Command "Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; Clear-RecycleBin -Force; Remove-Item 'C:\Windows\SoftwareDistribution\Download\*' -Recurse -Force -ErrorAction SilentlyContinue"
echo Cleanup complete.
goto FOOTER

:DISABLEUPDATES
cls
echo [Disabling Windows Update Service...]
sc stop wuauserv >nul
sc config wuauserv start= disabled >nul
echo Windows Update service disabled.
goto FOOTER

:FOOTER
echo.
echo ====================================================
echo     Script by Chimayu | Yunique Utility v1.0
pause
goto MENU
