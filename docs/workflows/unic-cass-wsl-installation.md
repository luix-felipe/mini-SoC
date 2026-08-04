# Instalação automatizada do UNIC-CASS em WSL2

**Status:** tutorial inicial.  
**Data:** 2026-08-04.  
**Escopo:** preparar WSL2/WSLg no Windows e instalar o ambiente UNIC-CASS no Ubuntu WSL.  
**Scripts:** `scripts/setup/preparar-wslg.ps1` e `scripts/setup/instalar-unicass-wsl.sh`.

## 1. Segurança e dados sensíveis

Os exemplos deste tutorial usam variáveis e placeholders. Não inserir senhas, tokens ou chaves diretamente nos scripts.

| Placeholder/variável | Significado |
| --- | --- |
| `%UserProfile%` | Diretório do usuário atual no Windows, resolvido pelo sistema |
| `$HOME` | Diretório do usuário atual no Ubuntu WSL |
| `<PASTA_DOS_SCRIPTS>` | Pasta local onde as automações foram disponibilizadas |
| `UNICCASS_REPO_DIR` | Destino opcional do repositório no WSL |
| `UNICCASS_IMAGE` | Imagem Docker opcional; o padrão é público e versionado |
| `UNICCASS_PDK` | PDK: `sky130A`, `ihp-sg13g2` ou `gf180mcuD` |
| `UNICCASS_PROJECT_NAME` | Nome local do projeto; obrigatório e não deve conter dados pessoais |

Não registrar em capturas de tela ou logs compartilhados:

- nome real do usuário Windows/WSL;
- conteúdo completo de `%UserProfile%\.wslconfig`;
- caminhos de rede ou endereços IP privados;
- credenciais do Docker, Git ou proxy;
- conteúdo de `.env`, chaves SSH ou tokens de acesso.

Os scripts usam somente a URL pública do UNIC-CASS e a imagem Docker pública configurada. Se a organização exigir proxy ou autenticação, configurar isso fora dos scripts conforme a política local.

## 2. Pré-requisitos

- Windows com WSL2 e suporte a WSLg;
- Ubuntu 24.04 no WSL;
- Docker Desktop instalado;
- integração do Docker Desktop habilitada para a distribuição Ubuntu;
- rede para atualizar WSL, instalar pacotes, clonar o repositório e obter a imagem;
- espaço disponível para ferramentas, PDKs e resultados;
- acesso administrativo ao PowerShell para atualizar o WSL.

As automações alteram o ambiente da máquina:

- `preparar-wslg.ps1` atualiza o WSL, ajusta `%UserProfile%\.wslconfig` e executa `wsl --shutdown`;
- `instalar-unicass-wsl.sh` instala pacotes com `sudo apt`, clona ou atualiza o UNIC-CASS, cria diretórios e baixa a imagem Docker quando necessário.

Fechar trabalhos importantes no WSL antes de iniciar, pois `wsl --shutdown` encerra todas as distribuições em execução.

## 3. Preparar WSL2 e WSLg no Windows

Abra o PowerShell **como Administrador** e acesse a pasta que contém os scripts:

```powershell
Set-Location '<PASTA_DOS_SCRIPTS>'
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\preparar-wslg.ps1
```

O bypass vale somente para a sessão atual. O script:

1. executa `wsl --update`;
2. cria ou ajusta a seção `[wsl2]` em `.wslconfig`;
3. preserva `.wslconfig.backup` quando o arquivo já existe;
4. confirma `guiApplications=true` sem imprimir todo o arquivo;
5. encerra o WSL para aplicar a configuração.

Depois, abra novamente o Ubuntu e valide o WSLg:

```bash
printf 'DISPLAY=%s\n' "${DISPLAY:-não definido}"
xclock
```

Ao compartilhar evidências, informe apenas se `DISPLAY` estava definido e se a janela abriu corretamente.

## 4. Confirmar o Docker no WSL

No Docker Desktop, confirme a integração WSL para a distribuição Ubuntu. Depois, no terminal Ubuntu:

```bash
docker version
docker info
```

Não publique a saída integral sem revisão: ela pode incluir nome da máquina, caminhos, registries internos e configuração de proxy. Para o relatório, registre sucesso/falha e versões após sanitização.

## 5. Executar a instalação no Ubuntu WSL

Na pasta em que o script Bash foi disponibilizado:

```bash
cd '<PASTA_DOS_SCRIPTS>'
bash ./instalar-unicass-wsl.sh
```

Valores padrão:

```text
repositório: $HOME/eda/uniccass-icdesign-tools
imagem:      isaiassh/unic-cass-tools:1.1.0
PDK:         sky130A
projeto:     definido pelo operador
```

Para alterar opções sem editar o arquivo:

```bash
UNICCASS_REPO_DIR="$HOME/eda/uniccass-icdesign-tools" \
UNICCASS_IMAGE="isaiassh/unic-cass-tools:1.1.0" \
UNICCASS_PDK="sky130A" \
UNICCASS_PROJECT_NAME="<NOME_DO_PROJETO>" \
bash ./instalar-unicass-wsl.sh
```

Essas variáveis devem conter apenas valores não secretos. O instalador aceita `sky130A`, `ihp-sg13g2` ou `gf180mcuD` como PDK. O nome do projeto aceita somente letras, números, ponto, sublinhado e hífen.

O instalador:

1. verifica WSLg e acesso ao daemon Docker;
2. instala Git, Make, utilitários X11 e toolchain RISC-V;
3. clona o repositório público ou executa `git fetch` se ele já existir;
4. atualiza somente a entrada `PDK=` do `.env`, preservando outras configurações;
5. cria a estrutura inicial usando o nome de projeto informado;
6. ajusta o uso de `/dev/dri` apenas quando o dispositivo não existe;
7. cria wrappers compartilhados do LibreLane e de verificação;
8. obtém a imagem Docker quando ela ainda não está local;
9. confirma a presença do multilib RV32 na toolchain do host.

## 6. Iniciar e verificar o ambiente

Depois da instalação:

```bash
cd "$HOME/eda/uniccass-icdesign-tools"
make start PDK=sky130A
```

Dentro do contêiner:

```bash
export PROJECT_NAME="<NOME_DO_PROJETO>"
cd "/home/designer/shared/$PROJECT_NAME"
/home/designer/shared/bin/verificar-ambiente-unicass
/home/designer/shared/bin/librelane-local --smoke-test
```

O verificador imprime caminhos de ferramentas e PDKs. Antes de compartilhar sua saída fora do time, substituir nomes de usuário, mounts internos e caminhos específicos por placeholders.

## 7. Abrir o projeto

Em outro terminal WSL, fora do contêiner:

```bash
export PROJECT_NAME="<NOME_DO_PROJETO>"
cd "$HOME/eda/uniccass-icdesign-tools/shared_xserver/$PROJECT_NAME"
code .
```

A rotina diária de compilação, simulação e implementação está em `docs/workflows/development-routine.md`.

## 8. Solução de problemas sem expor dados

Ao solicitar ajuda, informar:

- etapa que falhou;
- comando executado;
- código de saída;
- mensagem de erro relevante;
- presença ou ausência da ferramenta/PDK.

Antes de anexar logs, substituir:

```text
/home/<USUARIO_WSL>/...
C:\Users\<USUARIO_WINDOWS>\...
\\<SERVIDOR_INTERNO>\<COMPARTILHAMENTO>\...
<IP_PRIVADO>
<TOKEN_OU_CREDENCIAL>
```

Não remover o texto técnico do erro, nomes de ferramentas, versões públicas ou nomes dos PDKs; eles são necessários para diagnóstico.
