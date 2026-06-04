# Liberar bloqueos de archivos en la carpeta build deteniendo de forma forzada procesos de Dart y Chrome residuales
Write-Host "Liberando bloqueos de archivos de compilacion..." -ForegroundColor Cyan
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "chromedriver" -ErrorAction SilentlyContinue | Stop-Process -Force

# Eliminar de manera forzada la carpeta de assets para evitar que Flutter falle al intentar borrarla
if (Test-Path "build\flutter_assets") {
    Remove-Item -Path "build\flutter_assets" -Recurse -Force -ErrorAction SilentlyContinue
}

# Levantar la aplicacion como servidor web en el puerto 8080
# Podras copiar la URL (http://localhost:8080) e ingresar desde tu Chrome de uso diario
flutter run -d web-server --web-port=8080
