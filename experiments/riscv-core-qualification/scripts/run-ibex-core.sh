#!/usr/bin/env bash
set -euo pipefail

readonly EXPECTED_IBEX_REV="8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2"
readonly SOURCE_DIR="${IBEX_SOURCE_DIR:-/src/ibex}"
readonly TOP_MODULE="${IBEX_TOP_MODULE:-ibex_top}"
readonly EXTRA_SOURCE="${IBEX_EXTRA_SOURCE:-}"
readonly TEMP_ROOT="$(mktemp -d /tmp/ibex-pipe-clean.XXXXXX)"
readonly WORK_DIR="${TEMP_ROOT}/ibex"
readonly BUILD_DIR="${TEMP_ROOT}/ibex-top-build"

cleanup() {
  rm -rf "${TEMP_ROOT}"
}
trap cleanup EXIT

export PATH="/home/designer/.local/bin:${PATH}"

if ! command -v fusesoc >/dev/null 2>&1 || \
   [[ "$(fusesoc --version 2>/dev/null)" != "2.4.3" ]]; then
  echo "[INFO] Instalando FuseSoC 2.4.3 a partir de pacote binario (wheel)."
  python3 -m pip install \
    --user \
    --quiet \
    --disable-pip-version-check \
    --only-binary=:all: \
    --timeout 120 \
    --retries 10 \
    fusesoc==2.4.3
fi

actual_fusesoc_version="$(fusesoc --version)"
if [[ "${actual_fusesoc_version}" != "2.4.3" ]]; then
  echo "[FAIL] Versao FuseSoC inesperada: ${actual_fusesoc_version}" >&2
  exit 1
fi

cp -a "${SOURCE_DIR}" "${WORK_DIR}"
cd "${WORK_DIR}"

actual_rev="$(git -c safe.directory="${WORK_DIR}" rev-parse HEAD)"
if [[ "${actual_rev}" != "${EXPECTED_IBEX_REV}" ]]; then
  echo "[FAIL] Revisao Ibex inesperada: ${actual_rev}" >&2
  exit 1
fi

# O target lint desta revisao sobrescreve o fileset e omite o proprio RTL.
# O target default fornece a file list completa; executamos lint/elaboracao
# diretamente com essa lista, sem editar o clone upstream.
fusesoc --cores-root=. run \
  --target=default \
  --tool=verilator \
  --setup \
  --build-root="${BUILD_DIR}" \
  lowrisc:ibex:ibex_top >"${TEMP_ROOT}/ibex-fusesoc-setup.log"

cd "${BUILD_DIR}/lowrisc_ibex_ibex_top_0.1/default-verilator"
extra_sources=()
if [[ -n "${EXTRA_SOURCE}" ]]; then
  if [[ ! -f "${EXTRA_SOURCE}" ]]; then
    echo "[FAIL] Fonte RTL adicional ausente: ${EXTRA_SOURCE}" >&2
    exit 1
  fi
  extra_sources+=("${EXTRA_SOURCE}")
fi

verilator \
  -f lowrisc_ibex_ibex_top_0.1.vc \
  "${extra_sources[@]}" \
  --lint-only \
  --top-module "${TOP_MODULE}" \
  -DDISABLE_PRIM_CDC_RAND_DELAY

echo "[PASS] IBEX_RTL_COMPILE: ${TOP_MODULE} elaborado com Verilator"
echo "[INFO] Ibex revision: ${actual_rev}"
echo "[INFO] FuseSoC version: ${actual_fusesoc_version}"
verilator --version
