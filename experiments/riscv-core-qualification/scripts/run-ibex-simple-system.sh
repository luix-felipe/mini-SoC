#!/usr/bin/env bash
set -euo pipefail

readonly EXPECTED_IBEX_REV="8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2"
readonly SOURCE_DIR="/src/ibex"
readonly WORK_DIR="/tmp/ibex"

apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  gcc-riscv64-unknown-elf libelf-dev srecord >/tmp/ibex-apt.log
python3 -m pip install --quiet fusesoc==2.4.3
export PATH="/root/.local/bin:/opt/verilator/cd693ce/bin:${PATH}"

cp -a "${SOURCE_DIR}" "${WORK_DIR}"
cd "${WORK_DIR}"

actual_rev="$(git -c safe.directory="${WORK_DIR}" rev-parse HEAD)"
if [[ "${actual_rev}" != "${EXPECTED_IBEX_REV}" ]]; then
  echo "[FAIL] Revisao Ibex inesperada: ${actual_rev}" >&2
  exit 1
fi

make -C examples/sw/simple_system/hello_test distclean >/tmp/ibex-sw-clean.log
make -C examples/sw/simple_system/hello_test \
  CC=riscv64-unknown-elf-gcc \
  ARCH=rv32imc >/tmp/ibex-sw-build.log

# ibex_config.py ainda emite BaseIsa, mas o target Simple System desta revisao
# nao declara esse parametro. Removemos somente a opcao incompatível.
read -ra config_opts <<< "$(
  python3 util/ibex_config.py small fusesoc_opts |
    sed 's/--BaseIsa=[^ ]* //'
)"

fusesoc --cores-root=. run \
  --target=sim \
  --setup \
  --build \
  lowrisc:ibex:ibex_simple_system \
  "${config_opts[@]}" >/tmp/ibex-simple-build.log

./build/lowrisc_ibex_ibex_simple_system_0/sim-verilator/Vibex_simple_system \
  --meminit=ram,./examples/sw/simple_system/hello_test/hello_test.elf \
  >/tmp/ibex-simple-console.log 2>&1

grep -q "Hello simple system" ibex_simple_system.log
grep -q "Terminating simulation by software request" /tmp/ibex-simple-console.log

echo "[PASS] IBEX_SIMPLE_SYSTEM_SMOKE: firmware executado ate o halt"
grep -E \
  "Terminating simulation|Executed cycles:|Cycles:|Instructions Retired:" \
  /tmp/ibex-simple-console.log
grep "Hello simple system" ibex_simple_system.log
