@echo off
setlocal EnableExtensions DisableDelayedExpansion
:: ============================================================
::  Fix Printer - TuGG Tool - All-in-one (FINAL)
::  Muc 5: bam la chay FULL CLEAN DriverStore
:: ============================================================

:: ---------- Self-elevate to Admin (UAC) ----------
net session >nul 2>&1 || (powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"; exit /b)

:: ---------- Console ----------
mode con: cols=90 lines=30
title Fix Printer - TuGG Tool - All-in-one

:: >>> Jump to MENU <<<
goto MENU

:: ============================================================
:: HELPERS CHUNG
:: ============================================================
:PAUSE_BACK
echo.
echo Bam phim bat ky de quay lai...
pause >nul
goto :EOF

:RESTART_SPOOLER
echo   - Stop Spooler...
sc stop spooler >nul 2>&1
taskkill /f /im spoolsv.exe >nul 2>&1
echo   - Start Spooler...
sc start spooler >nul 2>&1
goto :EOF

:COPY_MSCMS_IF_MISSING
set "SRC=%SystemRoot%\System32\mscms.dll"
set "DST64=%SystemRoot%\System32\spool\drivers\x64\3"
set "DST32=%SystemRoot%\System32\spool\drivers\w32x86\3"
if exist "%SRC%" (
  if exist "%DST64%" if not exist "%DST64%\mscms.dll" copy /y "%SRC%" "%DST64%\mscms.dll" >nul
  if exist "%DST32%" if not exist "%DST32%\mscms.dll" copy /y "%SRC%" "%DST32%\mscms.dll" >nul
)
goto :EOF

:ASK_YN
setlocal EnableDelayedExpansion
choice /C YN /N /M "%~1 [Y/N]: "
set "rc=!errorlevel!"
endlocal & set "YN=%rc%"
goto :EOF

:: ============================================================
:: =============== MAIN MENU ==================================
:: ============================================================
:MENU
cls
echo ===== Tung Nguyen Tool - All-in-one =====
echo [1] Fix may in
echo [2] Mo Quan ly thiet bi
echo [3] Mo Quan ly may in
echo [4] Mo tab Trinh dieu khien Drivers
echo [5] Go driver may in (nang cao) - FULL CLEAN DriverStore
echo [6] Mo Devices and Printers
echo [0] Thoat
echo ============================================================
choice /C 1234560 /N /M "Chon [1-6,0]: "
set "sel=%errorlevel%"
if "%sel%"=="1" goto FIX_MENU
if "%sel%"=="2" (start "" devmgmt.msc & goto MENU)
if "%sel%"=="3" (start "" printmanagement.msc & goto MENU)
if "%sel%"=="4" (start "" rundll32 printui.dll,PrintUIEntry /s /t2 & goto MENU)
if "%sel%"=="5" goto CLEAN_ALL
if "%sel%"=="6" (start "" explorer.exe shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A} & goto MENU)
if "%sel%"=="7" goto END
goto MENU

:END
exit /b

:: ============================================================
:: =============== SUBMENU: FIX PRINT =========================
:: ============================================================
:FIX_MENU
cls
echo --- FIX MAY IN ---
echo [1] Fix Communication Error (Canon LBP 2900/3300)
echo [2] Fix loi 0x0000007c
echo [3] Fix loi 0x0000011b
echo [4] Fix loi 0x00000709
echo [5] Fix loi 0x00000040
echo [6] Fix loi 0x00000bc4
echo [7] Fix loi 0x000006d9
echo [8] Printer Cannot Connect (7 buoc)
echo [9] Fix loi 0x00000012
echo [A] Fix loi 0x000003eb
echo [B] Fix loi 0x00000771
echo [C] Xoa hang doi in
echo [D] Khoi dong lai Print Spooler
echo [E] Reset USB Monitor
echo [0] Quay lai MENU chinh
echo -----------------------
choice /C 123456789ABCDE0 /N /M "Chon: "
set "pick=%errorlevel%"
if "%pick%"=="1"  goto FIX_COMM
if "%pick%"=="2"  goto FIX_7C_VER
if "%pick%"=="3"  goto FIX_11B
if "%pick%"=="4"  goto FIX_709
if "%pick%"=="5"  goto FIX_40
if "%pick%"=="6"  goto FIX_BC4
if "%pick%"=="7"  goto FIX_6D9
if "%pick%"=="8"  goto FIX_CONNECT
if "%pick%"=="9"  goto FIX_12
if "%pick%"=="10" goto FIX_3EB
if "%pick%"=="11" goto FIX_771
if "%pick%"=="12" goto CLEAR_SPOOL
if "%pick%"=="13" goto RST_SPOOLER
if "%pick%"=="14" goto RESET_USB_MON
if "%pick%"=="15" goto MENU
goto FIX_MENU

:: ============================================================
::  CÁC FIX CHI TIẾT
:: ============================================================

:FIX_COMM
cls
echo Fix Communication Error...
net stop spooler >nul
taskkill /f /im spoolsv.exe >nul
for %%A in (
 "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\USB Monitor\UsbPortList"
 "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\USB Monitor\Port"
) do reg delete "%%~A" /f >nul 2>&1
del /q "%SystemRoot%\System32\spool\PRINTERS\*.*" >nul 2>&1
for /f "delims=" %%K in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors" 2^>nul ^| findstr /I "CNB USB"') do reg delete "%%K" /f >nul 2>&1
call :RESTART_SPOOLER
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:FIX_7C_VER
cls
echo Fix loi 0x0000007c...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul
call :RESTART_SPOOLER
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:FIX_11B
cls
echo Fix loi 0x0000011b...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverNamedPipes /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverTcp /t REG_DWORD /d 1 /f >nul
call :RESTART_SPOOLER
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:FIX_709
cls
echo Fix loi 0x00000709...
net stop spooler >nul
dism /Online /Enable-Feature /FeatureName:Printing-Foundation-InternetPrinting-Client /NoRestart >nul
dism /Online /Enable-Feature /FeatureName:Printing-LPRPortMonitor /NoRestart >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul
powershell -NoProfile -Command "$p='HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows';$acl=Get-Acl $p;$rule=New-Object System.Security.AccessControl.RegistryAccessRule('Everyone','FullControl','ContainerInherit,ObjectInherit','None','Allow');$acl.SetAccessRule($rule);Set-Acl -Path $p -AclObject $acl" >nul
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v LegacyDefaultPrinterMode /t REG_DWORD /d 1 /f >nul
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v Device /f >nul 2>&1
call :RESTART_SPOOLER
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:FIX_40
cls
echo Fix loi 0x00000040...
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:FIX_BC4
cls
echo Fix loi 0x00000bc4...
echo [1] RpcOverTcp=1, RpcOverNamedPipes=1
echo [2] RpcOverTcp=0, RpcOverNamedPipes=1
echo [3] Mo GPEDIT
echo [0] Quay lai
choice /C 1230 /N /M "Chon: "
set "bc=%errorlevel%"
if "%bc%"=="1" (
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverTcp /t REG_DWORD /d 1 /f >nul
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverNamedPipes /t REG_DWORD /d 1 /f >nul
  echo [DONE]
  call :PAUSE_BACK
  goto FIX_MENU
)
if "%bc%"=="2" (
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverTcp /t REG_DWORD /d 0 /f >nul
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverNamedPipes /t REG_DWORD /d 1 /f >nul
  echo [DONE]
  call :PAUSE_BACK
  goto FIX_MENU
)
if "%bc%"=="3" (
  start "" gpedit.msc
  call :PAUSE_BACK
  goto FIX_MENU
)
if "%bc%"=="4" goto FIX_MENU
goto FIX_BC4

:FIX_6D9
cls
echo Fix loi 0x000006d9...
sc config MpsSvc start= auto >nul
sc start MpsSvc >nul
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:FIX_CONNECT
cls
echo Fix Printer Cannot Connect...
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverNamedPipes /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverTcp /t REG_DWORD /d 1 /f >nul
call :COPY_MSCMS_IF_MISSING
for %%S in (Spooler fdPHost FDResPub SSDPSRV upnphost) do (
 sc config %%S start= auto >nul 2>&1
 sc start  %%S >nul 2>&1
)
call :RESTART_SPOOLER
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:FIX_12
cls
echo Fix loi 0x00000012...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverTcp /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcOverNamedPipes /t REG_DWORD /d 1 /f >nul
call :RESTART_SPOOLER
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:FIX_3EB
cls
echo Fix loi 0x000003eb...
net stop spooler >nul
del /q "%SystemRoot%\System32\spool\PRINTERS\*.*" >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul
sc start spooler >nul
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:FIX_771
cls
echo Fix loi 0x00000771...
net stop spooler >nul
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Devices" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\PrinterPorts" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v Device /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Print\Printers" /f >nul 2>&1
del /q "%SystemRoot%\System32\spool\PRINTERS\*.*" >nul 2>&1
sc start spooler >nul
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:CLEAR_SPOOL
cls
echo Xoa hang doi in...
net stop spooler >nul
del /q "%SystemRoot%\System32\spool\PRINTERS\*.*" >nul 2>&1
call :RESTART_SPOOLER
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:RST_SPOOLER
cls
echo Khoi dong lai Print Spooler...
call :RESTART_SPOOLER
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:RESET_USB_MON
cls
echo Reset USB Monitor...
for %%A in (
 "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\USB Monitor\UsbPortList"
 "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\USB Monitor\Port"
) do reg delete "%%A" /f >nul 2>&1
echo [DONE]
call :PAUSE_BACK
goto FIX_MENU

:: ============================================================
::  MUC 5 – CHI CON FULL CLEAN DRIVERSTORE
:: ============================================================
:CLEAN_ALL
cls
echo ========================================
echo   FULL CLEAN DRIVER STORE
echo ========================================
echo Dang quet va xoa TAT CA driver Printer...
echo ========================================

setlocal EnableDelayedExpansion
set /a COUNT=0
set "TEMP_FILE=%TEMP%\printer_drivers.txt"

pnputil /enum-drivers > "%TEMP_FILE%" 2>nul

set "CURRENT_DRV="
for /f "tokens=1,2 delims=:" %%A in ('type "%TEMP_FILE%"') do (
    if /I "%%A"=="Published Name" (
        set "CURRENT_DRV=%%B"
        set "CURRENT_DRV=!CURRENT_DRV: =!"
    )
    if /I "%%A"=="Class Name" (
        echo %%B | findstr /I "Printer" >nul
        if !errorlevel! EQU 0 (
            if defined CURRENT_DRV (
                set /a COUNT+=1
                echo [!COUNT!] Xoa: !CURRENT_DRV! ...
                pnputil /delete-driver !CURRENT_DRV! /uninstall /force >nul 2>&1
                if !errorlevel! EQU 0 (
                    echo     [OK]
                ) else (
                    echo     [FAIL]
                )
            )
        )
        set "CURRENT_DRV="
    )
)

del "%TEMP_FILE%" >nul 2>&1

echo.
echo ========================================
echo [HOAN TAT] Da xu ly !COUNT! driver(s).
echo ========================================

endlocal
call :PAUSE_BACK
goto MENU
