#!/usr/bin/env bash
set -euo pipefail

readonly EXPECTED_CROC_REV="968bab17b37e88d9200a0899cb9181e42850ec87"
readonly BENDER_VERSION="0.32.1"
readonly BENDER_SHA256="59a36723b056a06b266dc68d4ceedcd0aa17a1c096e8c2ea512af264ff6a13f6"
readonly SOURCE_DIR="/src/croc"
readonly WORK_DIR="/tmp/croc"

apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  gcc-riscv64-unknown-elf curl xz-utils >/tmp/croc-apt.log

curl --fail --location --silent --show-error \
  "https://github.com/pulp-platform/bender/releases/download/v${BENDER_VERSION}/bender-x86_64-unknown-linux-gnu.tar.xz" \
  --output /tmp/bender.tar.xz
echo "${BENDER_SHA256}  /tmp/bender.tar.xz" | sha256sum --check
mkdir -p /tmp/bender
tar -xJf /tmp/bender.tar.xz -C /tmp/bender --strip-components=1
install -m 0755 /tmp/bender/bender /usr/local/bin/bender
export PATH="/opt/verilator/cd693ce/bin:${PATH}"

cp -a "${SOURCE_DIR}" "${WORK_DIR}"
cd "${WORK_DIR}"

actual_rev="$(git -c safe.directory="${WORK_DIR}" rev-parse HEAD)"
if [[ "${actual_rev}" != "${EXPECTED_CROC_REV}" ]]; then
  echo "[FAIL] Revisao Croc inesperada: ${actual_rev}" >&2
  exit 1
fi

# A toolchain GCC 10 da distribuicao nao aceita rv32i_zicsr e nao fornece
# libm para rv32. A adaptacao mantem o subconjunto RV32I usado neste smoke.
readonly riscv_flags="-march=rv32i -mabi=ilp32 -mcmodel=medany -static -std=gnu99 -Os -nostdlib -fno-builtin -ffreestanding"
make -C sw clean >/tmp/croc-sw-clean.log
make -C sw \
  RISCV_MARCH=rv32i \
  RISCV_FLAGS="${riscv_flags}" \
  RISCV_LDFLAGS="-static -nostartfiles -lgcc ${riscv_flags}" \
  >/tmp/croc-sw-build.log

cd verilator
VERILATOR_JOBS="${VERILATOR_JOBS:-4}" \
  ./run_verilator.sh --build >/tmp/croc-rtl-build.log 2>&1
echo "[PASS] CROC_RTL_COMPILE: modelo Verilator gerado"

set +e
timeout 120 obj_dir_rtl/Vtb_croc_soc \
  +binary=../sw/bin/helloworld.hex >/tmp/croc-smoke.log 2>&1
sim_rc=$?
set -e

if grep -q '\[JTAG\] Simulation finished: SUCCESS' /tmp/croc-smoke.log; then
  echo "[PASS] CROC_SYSTEM_SMOKE: termino JTAG confirmado"
  grep -E '\[CORE\]|\[JTAG\]|\[UART\]' /tmp/croc-smoke.log | tail -n 20
  exit 0
fi

echo "[BLOCKED] CROC_SYSTEM_SMOKE: sem marcador JTAG de sucesso (rc=${sim_rc})" >&2
grep -m 1 '\[UART\] Hello World from Croc!' /tmp/croc-smoke.log || true
grep -m 1 'Illegal instruction' /tmp/croc-smoke.log || true
exit 1
