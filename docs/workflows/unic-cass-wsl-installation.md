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
.\scripts\setup\preparar-wslg.ps1
```

Após reabrir o Ubuntu:

```bash
cd /caminho/do/clone/mini-SoC
bash scripts/setup/instalar-unicass-wsl.sh
```

Sem opções, o projeto é criado como `chipus-soc` e o clone de trabalho como
`mini-SoC`. O script pode ser iniciado de qualquer diretório: ele localiza o
repositório a partir da própria localização.

Valores principais podem ser definidos sem editar o script:

```bash
UNICCASS_PDK=sky130A \
UNICCASS_PROJECT_NAME=chipus-soc \
bash scripts/setup/instalar-unicass-wsl.sh
```

Também podem ser usados `UNICCASS_REPO_DIR` para escolher onde instalar as
ferramentas e `UNICCASS_PROJECT_REPO_NAME` para alterar o nome do checkout de
trabalho. A imagem Docker é resolvida pelo `Makefile` do UNIC-CASS, evitando que
o instalador e o projeto apontem para versões diferentes.

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
