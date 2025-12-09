# fixprint.ps1
# Script tải và chạy fixprint.cmd từ GitHub

$url = "https://raw.githubusercontent.com/meoconzizizi/fixprint/refs/heads/main/fixprint.cmd"
$tempFile = "$env:TEMP\fixprint.cmd"

Write-Host "Đang tải fixprint.cmd từ GitHub..." -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri $url -OutFile $tempFile -ErrorAction Stop
    Write-Host "Tải thành công: $tempFile" -ForegroundColor Green
}
catch {
    Write-Host "Lỗi khi tải file từ GitHub!" -ForegroundColor Red
    exit 1
}

Write-Host "Đang chạy fixprint.cmd..." -ForegroundColor Yellow

Start-Process $tempFile -Verb RunAs  # chạy với quyền admin

Write-Host "Hoàn tất." -ForegroundColor Green
