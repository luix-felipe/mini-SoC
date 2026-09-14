IMAGE ?= isaiassh/unic-cass-tools:1.1.0
WORKSPACE_ROOT ?= $(abspath ../../..)
IBEX_DIR ?= $(WORKSPACE_ROOT)/ip-candidates/riscv/ibex
CROC_DIR ?= $(WORKSPACE_ROOT)/ip-candidates/riscv/croc
MINISOC_ROOT ?= $(abspath ../..)
IBEX_WRAPPER ?= $(MINISOC_ROOT)/rtl/chipus_ibex_wrapper.sv

.PHONY: check-clones ibex-core ibex-wrapper ibex-smoke croc-smoke chipus-soc-smoke

check-clones:
	@test -d "$(IBEX_DIR)/.git" || { echo "Clone do Ibex ausente: $(IBEX_DIR)"; exit 1; }
	@test -d "$(CROC_DIR)/.git" || { echo "Clone do Croc ausente: $(CROC_DIR)"; exit 1; }

ibex-core:
	@test -d "$(IBEX_DIR)/.git" || { echo "Clone do Ibex ausente: $(IBEX_DIR)"; exit 1; }
	@if command -v docker >/dev/null 2>&1; then \
		docker run --rm --entrypoint bash \
			-v "$(IBEX_DIR):/src/ibex:ro" \
			-v "$(CURDIR)/scripts:/qualification:ro" \
			"$(IMAGE)" -lc /qualification/run-ibex-core.sh; \
	else \
		echo "[INFO] Docker não encontrado; executando no ambiente atual."; \
		IBEX_SOURCE_DIR="$(IBEX_DIR)" "$(CURDIR)/scripts/run-ibex-core.sh"; \
	fi

ibex-wrapper:
	@test -d "$(IBEX_DIR)/.git" || { echo "Clone do Ibex ausente: $(IBEX_DIR)"; exit 1; }
	@test -f "$(IBEX_WRAPPER)" || { echo "Wrapper do Ibex ausente: $(IBEX_WRAPPER)"; exit 1; }
	@if command -v docker >/dev/null 2>&1; then \
		docker run --rm --entrypoint bash \
			-e IBEX_TOP_MODULE=chipus_ibex_wrapper \
			-e IBEX_EXTRA_SOURCE=/src/minisoc-rtl/chipus_ibex_wrapper.sv \
			-v "$(IBEX_DIR):/src/ibex:ro" \
			-v "$(MINISOC_ROOT)/rtl:/src/minisoc-rtl:ro" \
			-v "$(CURDIR)/scripts:/qualification:ro" \
			"$(IMAGE)" -lc /qualification/run-ibex-core.sh; \
	else \
		echo "[INFO] Docker não encontrado; executando no ambiente atual."; \
		IBEX_SOURCE_DIR="$(IBEX_DIR)" \
		IBEX_TOP_MODULE=chipus_ibex_wrapper \
		IBEX_EXTRA_SOURCE="$(IBEX_WRAPPER)" \
		"$(CURDIR)/scripts/run-ibex-core.sh"; \
	fi

ibex-smoke:
	@test -d "$(IBEX_DIR)/.git" || { echo "Clone do Ibex ausente: $(IBEX_DIR)"; exit 1; }
	@if command -v docker >/dev/null 2>&1; then \
		docker run --rm --entrypoint bash -u root -e HOME=/root \
			-v "$(IBEX_DIR):/src/ibex:ro" \
			-v "$(CURDIR)/scripts:/qualification:ro" \
			"$(IMAGE)" -lc /qualification/run-ibex-simple-system.sh; \
	else \
		echo "[ERRO] ibex-smoke instala toolchain e libelf no contêiner efêmero." >&2; \
		echo "       Execute este alvo no terminal WSL, fora do UNIC-CASS." >&2; \
		exit 2; \
	fi

croc-smoke:
	@test -d "$(CROC_DIR)/.git" || { echo "Clone do Croc ausente: $(CROC_DIR)"; exit 1; }
	@if command -v docker >/dev/null 2>&1; then \
		docker run --rm --entrypoint bash -u root -e HOME=/root \
			-v "$(CROC_DIR):/src/croc:ro" \
			-v "$(CURDIR)/scripts:/qualification:ro" \
			"$(IMAGE)" -lc /qualification/run-croc-smoke.sh; \
	else \
		echo "[ERRO] croc-smoke instala Bender e a toolchain no contêiner efêmero." >&2; \
		echo "       Execute este alvo no terminal WSL, fora do UNIC-CASS." >&2; \
		exit 2; \
	fi

chipus-soc-smoke:
	"$(MINISOC_ROOT)/scripts/test/run-chipus-soc-smoke.sh"
