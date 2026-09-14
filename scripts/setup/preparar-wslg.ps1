# Preparação do WSL2/WSLg para o ambiente UNIC-CASS.
# Execute no PowerShell como Administrador. O nome da distribuição pode ser
# informado com: .\preparar-wslg.ps1 -Distro Ubuntu-24.04

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$Distro = "Ubuntu-24.04"
)

$ErrorActionPreference = "Stop"

function Invoke-Wsl {
    param([Parameter(Mandatory)][string[]]$Arguments)

    & wsl.exe @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar: wsl.exe $($Arguments -join ' ')"
    }
}

$principal = [Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Abra o PowerShell como Administrador e execute o script novamente."
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw "wsl.exe não foi encontrado. Instale/ative o WSL no Windows antes de continuar."
}

Write-Host "=== Atualizando WSL ===" -ForegroundColor Cyan
Invoke-Wsl -Arguments @("--update")

Write-Host "=== Verificando distribuições instaladas ===" -ForegroundColor Cyan
$lista = & wsl.exe --list --quiet
if ($LASTEXITCODE -ne 0) {
    throw "Não foi possível consultar as distribuições WSL instaladas."
}
$distrosInstaladas = @($lista -replace "`0", "" | ForEach-Object { $_.Trim() } | Where-Object { $_ })

if ($distrosInstaladas -contains $Distro) {
    $distroSelecionada = $Distro
    Write-Host "A distribuição $Distro já está instalada." -ForegroundColor Green
} else {
    # Algumas instalações antigas registram Ubuntu 24.04 apenas como "Ubuntu".
    $ubuntuCompativel = $distrosInstaladas | Where-Object {
        if ($_ -notmatch '^Ubuntu(?:-\d{2}\.\d{2})?$') {
            return $false
        }

        $osRelease = & wsl.exe --distribution $_ --exec cat /etc/os-release 2>$null
        $LASTEXITCODE -eq 0 -and $osRelease -match '(?m)^VERSION_ID="?24\.04"?\s*$'
    } | Select-Object -First 1

    if ($ubuntuCompativel) {
        $distroSelecionada = $ubuntuCompativel
        Write-Host "Usando a distribuição Ubuntu já instalada: $distroSelecionada" -ForegroundColor Green
    } else {
        Write-Host "Instalando a distribuição $Distro..." -ForegroundColor Yellow
        Invoke-Wsl -Arguments @("--install", "--distribution", $Distro, "--no-launch")
        $distroSelecionada = $Distro
        Write-Host "A distribuição $Distro foi instalada." -ForegroundColor Green
    }
}

$configPath = Join-Path $env:USERPROFILE ".wslconfig"

Write-Host "=== Ajustando WSLg ===" -ForegroundColor Cyan
if (-not (Test-Path $configPath)) {
    $content = @"
[wsl2]
guiApplications=true
"@
} else {
    $backupPath = "$configPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $configPath -Destination $backupPath
    Write-Host "Backup criado em $backupPath" -ForegroundColor DarkGray
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
}

# UTF-8 sem BOM evita corromper comentários e valores não ASCII preexistentes.
$utf8SemBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($configPath, $content, $utf8SemBom)

if (-not (Select-String -Path $configPath -Pattern '(?im)^\s*guiApplications\s*=\s*true\s*$' -Quiet)) {
    throw "Não foi possível confirmar guiApplications=true no .wslconfig."
}

Write-Host "Configuração WSLg aplicada em %UserProfile%\.wslconfig." -ForegroundColor Green
Write-Host "O conteúdo completo não é exibido para evitar exposição de outras configurações." -ForegroundColor DarkGray

Write-Host "=== Reiniciando WSL ===" -ForegroundColor Cyan
Invoke-Wsl -Arguments @("--shutdown")

Write-Host "Concluído. Inicialize com 'wsl.exe --distribution $distroSelecionada'." -ForegroundColor Green
Write-Host 'Depois execute o instalador Bash; ele instalará x11-apps. Confirme o WSLg com: echo $DISPLAY; xclock' -ForegroundColor Green
