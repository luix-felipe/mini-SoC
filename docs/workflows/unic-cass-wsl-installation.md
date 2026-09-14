# Instalação do UNIC-CASS no WSL2

Scripts:

- `scripts/setup/preparar-wslg.ps1`: prepara WSL2/WSLg no Windows;
- `scripts/setup/instalar-unicass-wsl.sh`: instala dependências e configura o
  workspace no Ubuntu.

## Pré-requisitos

- Ubuntu 24.04 em WSL2/WSLg;
- Docker Desktop integrado à distribuição;
- rede e espaço para imagem e PDKs;
- PowerShell administrativo para preparar o WSL.

## Instalação

No PowerShell administrativo:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\preparar-wslg.ps1
```

Após reabrir o Ubuntu:

```bash
bash ./instalar-unicass-wsl.sh
```

Valores principais podem ser definidos sem editar o script:

```bash
UNICCASS_PDK=sky130A \
UNICCASS_PROJECT_NAME=chipus-soc \
bash ./instalar-unicass-wsl.sh
```

## Verificação

```bash
cd "$HOME/eda/uniccass-icdesign-tools"
make start PDK=sky130A
```

Dentro do contêiner:

```bash
/home/designer/shared/bin/verificar-ambiente-unicass
/home/designer/shared/bin/librelane-local --smoke-test
```

Não registrar credenciais, `.env`, chaves ou caminhos privados nos logs. Para o
uso diário, consulte [a rotina de desenvolvimento](development-routine.md).
