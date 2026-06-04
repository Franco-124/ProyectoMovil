# Liberar bloqueos de archivos deteniendo de forma forzada procesos residuales de Dart, Chrome y ChromeDriver
Write-Host "Liberando bloqueos de archivos de compilacion..." -ForegroundColor Cyan
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "chromedriver" -ErrorAction SilentlyContinue | Stop-Process -Force

# Eliminar de manera agresiva la carpeta build\flutter_assets para evitar fallos de Flutter en Windows
if (Test-Path "build\flutter_assets") {
    cmd /c "rmdir /s /q build\flutter_assets"
}

# Iniciar la aplicacion en modo depuracion en Chrome
flutter run -d chrome
