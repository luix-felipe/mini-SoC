#!/usr/bin/env bash
set -euo pipefail

readonly EXPECTED_IBEX_REV="8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd -P)"
readonly WORKSPACE_ROOT="$(cd -- "$REPO_ROOT/.." && pwd -P)"
readonly IBEX_DIR="${IBEX_DIR:-$WORKSPACE_ROOT/ip-candidates/riscv/ibex}"
readonly TEMP_ROOT="$(mktemp -d /tmp/chipus-soc-smoke.XXXXXX)"
readonly FW_DIR="$TEMP_ROOT/firmware"
readonly FUSESOC_BUILD="$TEMP_ROOT/fusesoc-build"
readonly VERILATOR_BUILD="$TEMP_ROOT/verilator-build"

cleanup() {
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

for tool in python3 verilator riscv64-unknown-elf-gcc riscv64-unknown-elf-objcopy; do
  command -v "$tool" >/dev/null 2>&1 || {
    printf '[FAIL] Ferramenta ausente: %s\n' "$tool" >&2
    exit 1
  }
done

if ! command -v fusesoc >/dev/null 2>&1 || [[ "$(fusesoc --version 2>/dev/null)" != "2.4.3" ]]; then
  python3 -m pip install \
    --quiet \
    --disable-pip-version-check \
    --only-binary=:all: \
    --target "$TEMP_ROOT/fusesoc" \
    fusesoc==2.4.3
  export PATH="$TEMP_ROOT/fusesoc/bin:$PATH"
  export PYTHONPATH="$TEMP_ROOT/fusesoc${PYTHONPATH:+:$PYTHONPATH}"
fi

[[ -d "$IBEX_DIR/.git" ]] || {
  printf '[FAIL] Clone do Ibex ausente: %s\n' "$IBEX_DIR" >&2
  exit 1
}
[[ "$(git -C "$IBEX_DIR" rev-parse HEAD)" == "$EXPECTED_IBEX_REV" ]] || {
  printf '[FAIL] Revisão inesperada do Ibex.\n' >&2
  exit 1
}

make -C "$REPO_ROOT/firmware" BUILD_DIR="$FW_DIR"

fusesoc --cores-root="$IBEX_DIR" run \
  --target=default \
  --tool=verilator \
  --setup \
  --build-root="$FUSESOC_BUILD" \
  lowrisc:ibex:ibex_top >"$TEMP_ROOT/fusesoc.log"

readonly VC_DIR="$FUSESOC_BUILD/lowrisc_ibex_ibex_top_0.1/default-verilator"
readonly VC_FILE="$VC_DIR/lowrisc_ibex_ibex_top_0.1.vc"

cd "$VC_DIR"
verilator -f "$VC_FILE" \
  "$REPO_ROOT/rtl/chipus_addr_map_pkg.sv" \
  "$REPO_ROOT/rtl/chipus_ibex_wrapper.sv" \
  "$REPO_ROOT/rtl/chipus_uart_tx.sv" \
  "$REPO_ROOT/rtl/chipus_soc_top.sv" \
  "$REPO_ROOT/tb/tb_chipus_soc.sv" \
  --binary \
  --timing \
  --top-module tb_chipus_soc \
  --Mdir "$VERILATOR_BUILD" \
  -DDISABLE_PRIM_CDC_RAND_DELAY

"$VERILATOR_BUILD/Vtb_chipus_soc" \
  +meminit="$FW_DIR/chipus_smoke.hex"
