# Liberar bloqueos de archivos de compilacion deteniendo procesos de Dart y Chrome residuales
Write-Host "Liberando bloqueos de archivos de compilacion..." -ForegroundColor Cyan
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "chromedriver" -ErrorAction SilentlyContinue | Stop-Process -Force

# Eliminar de manera forzada la carpeta de assets para evitar que Flutter falle al intentar borrarla
if (Test-Path "build\flutter_assets") {
    Remove-Item -Path "build\flutter_assets" -Recurse -Force -ErrorAction SilentlyContinue
}

# Ejecutar Flutter en Chrome desactivando las politicas de seguridad web (bypasea CORS en desarrollo)
flutter run -d chrome --web-browser-flag="--disable-web-security"
