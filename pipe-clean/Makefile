PIPE_CLEAN_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
MINISOC_ROOT := $(abspath $(PIPE_CLEAN_DIR)/..)
WORKSPACE_ROOT := $(abspath $(MINISOC_ROOT)/..)
QUALIFICATION_DIR := $(MINISOC_ROOT)/experiments/riscv-core-qualification
IBEX_DIR := $(WORKSPACE_ROOT)/ip-candidates/riscv/ibex
CROC_DIR := $(WORKSPACE_ROOT)/ip-candidates/riscv/croc

.PHONY: show ibex-core ibex-wrapper ibex-smoke croc-smoke

show:
	@echo "Workspace .......... $(WORKSPACE_ROOT)"
	@echo "Repositorio mini-SoC $(MINISOC_ROOT)"
	@echo "Ibex oficial ....... $(IBEX_DIR)"
	@echo "Croc oficial ....... $(CROC_DIR)"
	@echo "Scripts de teste ... $(QUALIFICATION_DIR)"
	@echo
	@echo "Ibex commit: $$(git -C "$(IBEX_DIR)" rev-parse HEAD)"
	@echo "Croc commit: $$(git -C "$(CROC_DIR)" rev-parse HEAD)"

ibex-core:
	$(MAKE) -C "$(QUALIFICATION_DIR)" ibex-core

ibex-wrapper:
	$(MAKE) -C "$(QUALIFICATION_DIR)" ibex-wrapper

ibex-smoke:
	$(MAKE) -C "$(QUALIFICATION_DIR)" ibex-smoke

croc-smoke:
	$(MAKE) -C "$(QUALIFICATION_DIR)" croc-smoke
