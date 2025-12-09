@echo off
cls
echo.
echo "Fixing registry value..."
echo.
REG ADD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Print\ /f /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0
::reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f
reg import Fix_Error.reg
regedit/S Fix_Error.reg
echo.
echo "Restarting Print Spooler Service"

echo.
net stop spooler
net start spooler
pause