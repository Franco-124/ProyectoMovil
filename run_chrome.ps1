# Liberar bloqueos de archivos en la carpeta build deteniendo procesos de Dart huerfanos
Write-Host "Liberando bloqueos de archivos de compilacion..." -ForegroundColor Cyan
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force

# Ejecutar Flutter en Chrome desactivando las politicas de seguridad web (bypasea CORS en desarrollo)
flutter run -d chrome --web-browser-flag="--disable-web-security"
