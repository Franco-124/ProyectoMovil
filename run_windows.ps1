# Liberar bloqueos de archivos en la carpeta build deteniendo de forma forzada procesos de Dart huerfanos
Write-Host "Liberando bloqueos de archivos de compilacion..." -ForegroundColor Cyan
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force

# Compilar y ejecutar como aplicacion nativa de Windows Escritorio (no aplica politicas CORS de navegadores)
flutter run -d windows
