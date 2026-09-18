#!/usr/bin/env bash
set -euo pipefail

readonly EXPECTED_CROC_REV="968bab17b37e88d9200a0899cb9181e42850ec87"
readonly BENDER_VERSION="0.32.1"
readonly BENDER_SHA256="59a36723b056a06b266dc68d4ceedcd0aa17a1c096e8c2ea512af264ff6a13f6"
readonly FLOW_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(cd -- "$FLOW_DIR/.." && pwd -P)"
readonly WORKSPACE_ROOT="$(cd -- "$REPO_ROOT/.." && pwd -P)"
readonly CROC_DIR="${CROC_DIR:-$WORKSPACE_ROOT/ip-candidates/riscv/croc}"
readonly OUTPUT_DIR="$FLOW_DIR/croc-src"
readonly TEMP_ROOT="$(mktemp -d /tmp/chipus-croc-sources.XXXXXX)"
readonly BENDER_ARCHIVE="$TEMP_ROOT/bender.tar.xz"
readonly BENDER_DIR="$TEMP_ROOT/bender"
readonly FLIST="$TEMP_ROOT/croc.f"

cleanup() {
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  exit 1
}

for tool in curl sha256sum tar git; do
  command -v "$tool" >/dev/null 2>&1 || fail "Ferramenta ausente: $tool"
done

[[ -d "$CROC_DIR/.git" ]] || fail "Clone Croc ausente: $CROC_DIR"
[[ "$(git -C "$CROC_DIR" rev-parse HEAD)" == "$EXPECTED_CROC_REV" ]] \
  || fail "Revisão Croc inesperada."

curl --fail --location --silent --show-error \
  "https://github.com/pulp-platform/bender/releases/download/v${BENDER_VERSION}/bender-x86_64-unknown-linux-gnu.tar.xz" \
  --output "$BENDER_ARCHIVE"
echo "${BENDER_SHA256}  ${BENDER_ARCHIVE}" | sha256sum --check
mkdir -p "$BENDER_DIR"
tar -xJf "$BENDER_ARCHIVE" -C "$BENDER_DIR" --strip-components=1
chmod +x "$BENDER_DIR/bender"

(
  cd "$CROC_DIR"
  "$BENDER_DIR/bender" script flist-plus \
    -t synthesis \
    -D COMMON_CELLS_ASSERTS_OFF=1 >"$FLIST"
)

[[ "$OUTPUT_DIR" == "$FLOW_DIR/croc-src" ]] || fail "Destino de fontes inválido: $OUTPUT_DIR"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/rtl" "$OUTPUT_DIR/include"

copy_source() {
  local source_file="$1"
  local target_name="$2"
  local target_file="$OUTPUT_DIR/rtl/$target_name"
  [[ ! -e "$target_file" ]] || fail "Colisão ao achatar fontes: $target_name"
  cp "$source_file" "$target_file"
}

copy_include_dir() {
  local source_dir="$1"
  local label="$2"
  local target_dir="$OUTPUT_DIR/include/$label"
  [[ -d "$source_dir" ]] || fail "Include ausente: $source_dir"
  mkdir -p "$target_dir"
  cp -a "$source_dir/." "$target_dir/"
}

source_index=0
while IFS= read -r entry; do
  case "$entry" in
    "") ;;
    +incdir+*)
      include_dir="${entry#+incdir+}"
      [[ "$include_dir" == "$CROC_DIR/rtl/"*/include ]] \
        || fail "Include fora do Croc: $include_dir"
      include_label="${include_dir#"$CROC_DIR/rtl/"}"
      include_label="${include_label%/include}"
      copy_include_dir "$include_dir" "$include_label"
      ;;
    "$CROC_DIR"/*.sv)
      printf -v ordered_name '%03d_%s' "$source_index" "$(basename -- "$entry")"
      copy_source "$entry" "$ordered_name"
      source_index=$((source_index + 1))
      ;;
    +define+*) ;;
    *) fail "Entrada Bender não suportada: $entry" ;;
  esac
done <"$FLIST"

printf '[PASS] %s fontes Croc e %s diretórios de include preparados em %s\n' \
  "$(find "$OUTPUT_DIR/rtl" -maxdepth 1 -type f | wc -l)" \
  "$(find "$OUTPUT_DIR/include" -mindepth 1 -maxdepth 1 -type d | wc -l)" \
  "$OUTPUT_DIR"
