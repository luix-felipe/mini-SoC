# Preparação do WSL2/WSLg para o ambiente UNIC-CASS.
# Execute no PowerShell como Administrador.

$ErrorActionPreference = "Stop"
$distro = "Ubuntu-24.04"

Write-Host "=== Verificando se a distro $distro está instalada ===" -ForegroundColor Cyan

$distrosInstaladas = (wsl -l -q) -replace "`0", "" | ForEach-Object { $_.Trim() }

# Valida se a distro está na lista
if ($distrosInstaladas -contains $distro) {
    Write-Host "A distro $distro já está instalada!" -ForegroundColor Green
} else {
    Write-Host "A distro $distro NÃO está instalada. Iniciando instalação..." -ForegroundColor Yellow
    
    # Instala e define como padrão
    wsl --install -d $distro
    wsl --set-default $distro
    
    Write-Host "A distro $distro foi instalada e definida como padrão!" -ForegroundColor Green
}
Write-Host "Para iniciar o WSL, digite 'wsl' no terminal." -ForegroundColor Cyan

Write-Host "=== Atualizando WSL ===" -ForegroundColor Cyan
wsl --update
if ($LASTEXITCODE -ne 0) {
    throw "Não foi possível atualizar o WSL."
}

$configPath = Join-Path $env:USERPROFILE ".wslconfig"

Write-Host "=== Ajustando WSLg ===" -ForegroundColor Cyan
if (-not (Test-Path $configPath)) {
    @"
[wsl2]
guiApplications=true
"@ | Set-Content -Path $configPath -Encoding ascii
} else {
    Copy-Item -Path $configPath -Destination "$configPath.backup" -Force
    $content = Get-Content $configPath -Raw

    if ($content -match '(?im)^\s*guiApplications\s*=') {
        $content = [regex]::Replace(
            $content,
            '(?im)^\s*guiApplications\s*=.*$',
            'guiApplications=true'
        )
    } elseif ($content -match '(?im)^\s*\[wsl2\]\s*$') {
        $content = [regex]::Replace(
            $content,
            '(?im)^\s*\[wsl2\]\s*$',
            "[wsl2]`r`nguiApplications=true",
            1
        )
    } else {
        $content = "[wsl2]`r`nguiApplications=true`r`n`r`n" + $content
    }

    Set-Content -Path $configPath -Value $content -Encoding ascii
}

if (-not (Select-String -Path $configPath -Pattern '(?im)^\s*guiApplications\s*=\s*true\s*$' -Quiet)) {
    throw "Não foi possível confirmar guiApplications=true no .wslconfig."
}

Write-Host "Configuração WSLg aplicada em %UserProfile%\.wslconfig." -ForegroundColor Green
Write-Host "O conteúdo completo não é exibido para evitar exposição de outras configurações." -ForegroundColor DarkGray

Write-Host "=== Reiniciando WSL ===" -ForegroundColor Cyan
wsl --shutdown

Write-Host 'Concluído. Abra o Ubuntu, instale os pacotes gráficos (sudo apt install x11-apps) e confirme: echo $DISPLAY; xclock' -ForegroundColor Green
