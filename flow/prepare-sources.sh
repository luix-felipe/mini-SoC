#!/usr/bin/env bash
set -euo pipefail

readonly EXPECTED_IBEX_REV="8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2"
readonly FLOW_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(cd -- "$FLOW_DIR/.." && pwd -P)"
readonly WORKSPACE_ROOT="$(cd -- "$REPO_ROOT/.." && pwd -P)"
readonly IBEX_DIR="${IBEX_DIR:-$WORKSPACE_ROOT/ip-candidates/riscv/ibex}"
readonly OUTPUT_DIR="${LIBRELANE_SOURCE_DIR:-$FLOW_DIR/src}"
readonly TEMP_ROOT="$(mktemp -d /tmp/chipus-librelane-sources.XXXXXX)"
readonly BUILD_ROOT="$TEMP_ROOT/build"

cleanup() {
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

command -v python3 >/dev/null 2>&1 || {
  echo '[FAIL] Python 3 não encontrado.' >&2
  exit 1
}
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
  echo '[FAIL] Revisão inesperada do Ibex.' >&2
  exit 1
}

fusesoc --cores-root="$IBEX_DIR" run \
  --target=default \
  --tool=verilator \
  --setup \
  --build-root="$BUILD_ROOT" \
  lowrisc:ibex:ibex_top >"$TEMP_ROOT/fusesoc.log"

readonly VC_DIR="$BUILD_ROOT/lowrisc_ibex_ibex_top_0.1/default-verilator"
readonly VC_FILE="$VC_DIR/lowrisc_ibex_ibex_top_0.1.vc"
readonly RTL_DIR="$OUTPUT_DIR/rtl"
readonly INCLUDE_DIR="$OUTPUT_DIR/include"
mkdir -p "$RTL_DIR" "$INCLUDE_DIR"
find "$OUTPUT_DIR" -maxdepth 1 -type f -delete
find "$RTL_DIR" "$INCLUDE_DIR" -maxdepth 1 -type f -delete

copy_source() {
  local source_file="$1"
  local destination_dir="$2"
  local target_name="${3:-$(basename -- "$source_file")}"
  local target_file="$destination_dir/$target_name"
  if [[ -e "$target_file" ]] && ! cmp -s "$source_file" "$target_file"; then
    printf '[FAIL] Colisão ao achatar fontes: %s\n' "$target_name" >&2
    exit 1
  fi
  cp "$source_file" "$target_file"
}

source_index=0
while IFS= read -r entry; do
  case "$entry" in
    src/*.sv)
      printf -v ordered_name '%03d_%s' "$source_index" "$(basename -- "$entry")"
      copy_source "$VC_DIR/$entry" "$RTL_DIR" "$ordered_name"
      source_index=$((source_index + 1))
      ;;
    +incdir+*)
      include_dir="$VC_DIR/${entry#+incdir+}"
      while IFS= read -r include_file; do
        copy_source "$include_file" "$INCLUDE_DIR"
      done < <(find "$include_dir" -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' \) | sort)
      ;;
  esac
done <"$VC_FILE"

printf '[PASS] %s fontes RTL ordenadas e %s includes Ibex preparados em %s\n' \
  "$(find "$RTL_DIR" -maxdepth 1 -type f | wc -l)" \
  "$(find "$INCLUDE_DIR" -maxdepth 1 -type f | wc -l)" \
  "$OUTPUT_DIR"
