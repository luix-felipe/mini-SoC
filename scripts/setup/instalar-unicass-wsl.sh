#!/usr/bin/env bash
# Instalação do ambiente UNIC-CASS em Ubuntu 24.04 no WSL2.
# Pressupõe Docker Desktop com integração WSL habilitada.

set -euo pipefail

REPO_URL="https://github.com/unic-cass/uniccass-icdesign-tools.git"
REPO_DIR="${UNICCASS_REPO_DIR:-$HOME/eda/uniccass-icdesign-tools}"
IMAGE="${UNICCASS_IMAGE:-isaiassh/unic-cass-tools:1.1.0}"
PDK_ALVO="${UNICCASS_PDK:-sky130A}"
PROJECT_NAME="${UNICCASS_PROJECT_NAME:-}"

case "$PDK_ALVO" in
  sky130A|ihp-sg13g2|gf180mcuD) ;;
  *) printf 'ERRO: PDK não suportado: %s\n' "$PDK_ALVO" >&2; exit 1 ;;
esac

[[ "$PROJECT_NAME" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] \
  || { printf 'ERRO: defina UNICCASS_PROJECT_NAME com um nome simples e não sensível.\n' >&2; exit 1; }

log() { printf '\n\033[1;36m=== %s ===\033[0m\n' "$1"; }
fail() { printf '\nERRO: %s\n' "$1" >&2; exit 1; }

log "Pré-verificações"
[[ -n "${DISPLAY:-}" ]] || fail "DISPLAY vazio. Ative guiApplications=true no arquivo C:\\Users\\<usuario>\\.wslconfig e execute wsl --shutdown."
[[ -S /tmp/.X11-unix/X0 ]] || fail "Socket X11 /tmp/.X11-unix/X0 não encontrado. Teste o WSLg com xclock antes de continuar."
command -v docker >/dev/null || fail "Docker não encontrado no WSL. Habilite a integração da distribuição no Docker Desktop."
docker info >/dev/null 2>&1 || fail "Docker daemon inacessível. Abra o Docker Desktop e confirme a integração WSL."

log "Pacotes do Ubuntu"
sudo apt update
sudo apt install -y \
  git make curl wget build-essential \
  x11-apps x11-xserver-utils mesa-utils \
  gcc-riscv64-unknown-elf \
  binutils-riscv64-unknown-elf \
  picolibc-riscv64-unknown-elf

log "Repositório UNIC-CASS"
mkdir -p "$(dirname "$REPO_DIR")"
if [[ ! -d "$REPO_DIR/.git" ]]; then
  [[ ! -e "$REPO_DIR" ]] || fail "O destino existe, mas não é um repositório Git: $REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR"
else
  git -C "$REPO_DIR" fetch --all --tags
fi
cd "$REPO_DIR"
PROJECT_DIR="$REPO_DIR/shared_xserver/$PROJECT_NAME"

log "PDK padrão e estrutura do projeto"
touch .env
if grep -q '^PDK=' .env; then
  sed -i "s/^PDK=.*/PDK=$PDK_ALVO/" .env
else
  printf 'PDK=%s\n' "$PDK_ALVO" >> .env
fi
mkdir -p "$PROJECT_DIR"/{rtl,tb,firmware,analog,flow,docs,results}
mkdir -p shared_xserver/bin

log "Compatibilidade WSL sem /dev/dri"
if [[ ! -e /dev/dri ]] && grep -q -- '--device=/dev/dri:/dev/dri' Makefile; then
  cp -n Makefile Makefile.backup || true
  sed -i '\|--device=/dev/dri:/dev/dri|d' Makefile
  echo "Linha /dev/dri removida porque o dispositivo não existe neste WSL."
else
  echo "Nenhuma alteração necessária em /dev/dri."
fi

log "Wrapper LibreLane para usar o PDK local"
cat > shared_xserver/bin/librelane-local <<'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail
exec librelane \
  --manual-pdk \
  --pdk-root "${PDK_ROOT:-/opt/pdks}" \
  --pdk "${PDK:-sky130A}" \
  "$@"
WRAPPER
chmod +x shared_xserver/bin/librelane-local

log "Verificador persistente"
cat > shared_xserver/bin/verificar-ambiente-unicass <<'VERIFY'
#!/usr/bin/env bash
set -u

ferramentas=(
  librelane openroad yosys iverilog verilator
  xschem ngspice magic klayout netgen
  openvaf cace cvc_rv
)
pdks=(sky130A ihp-sg13g2 gf180mcuD)
falhas=0

echo "PDK=${PDK:-não definido}"
echo "PDK_ROOT=${PDK_ROOT:-não definido}"
echo
for f in "${ferramentas[@]}"; do
  printf '%-12s : ' "$f"
  if command -v "$f" >/dev/null 2>&1; then command -v "$f"; else echo "NÃO ENCONTRADA"; falhas=$((falhas+1)); fi
done

echo
for p in "${pdks[@]}"; do
  printf '%-12s : ' "$p"
  if [[ -e "/opt/pdks/$p" ]]; then readlink -f "/opt/pdks/$p"; else echo "NÃO ENCONTRADO"; falhas=$((falhas+1)); fi
done

echo
if [[ -x /home/designer/shared/bin/librelane-local ]]; then
  echo "librelane-local: OK"
else
  echo "librelane-local: NÃO ENCONTRADO"
  falhas=$((falhas+1))
fi

(( falhas == 0 )) && echo "RESULTADO: AMBIENTE COMPLETO" || echo "RESULTADO: $falhas ITEM(NS) COM PROBLEMA"
exit "$falhas"
VERIFY
chmod +x shared_xserver/bin/verificar-ambiente-unicass

log "Imagem Docker"
docker image inspect "$IMAGE" >/dev/null 2>&1 || docker pull "$IMAGE"

log "Validação da toolchain RISC-V no host"
riscv64-unknown-elf-gcc --version | head -n 1
riscv64-unknown-elf-gcc -print-multi-lib | grep -q 'rv32imac/ilp32' \
  && echo "Suporte RV32: OK" \
  || fail "Toolchain instalada, mas o multilib RV32 esperado não foi encontrado."

log "Instalação preparada"
cat <<MSG
Próximos comandos:

  cd "$REPO_DIR"
  make start PDK="$PDK_ALVO"

Dentro do container:

  /home/designer/shared/bin/verificar-ambiente-unicass
  /home/designer/shared/bin/librelane-local --smoke-test

Para abrir o projeto no VS Code pelo WSL:

  cd "$PROJECT_DIR"
  code .
MSG
