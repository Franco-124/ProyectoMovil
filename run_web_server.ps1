# Liberar bloqueos de archivos en la carpeta build deteniendo de forma forzada procesos de Dart huerfanos
Write-Host "Liberando bloqueos de archivos de compilacion..." -ForegroundColor Cyan
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force

# Levantar la aplicacion como servidor web en el puerto 8080
# Podras copiar la URL (http://localhost:8080) e ingresar desde tu Chrome de uso diario
flutter run -d web-server --web-port=8080
