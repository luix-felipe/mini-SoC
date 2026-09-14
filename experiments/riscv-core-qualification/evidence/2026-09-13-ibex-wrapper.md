# Evidência — wrapper Ibex

- data: 2026-09-13;
- Ibex: `8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2`;
- ambiente: `isaiassh/unic-cass-tools:1.1.0`;
- ferramentas: FuseSoC 2.4.3 e Verilator 5.026.

```bash
make -C mini-SoC/pipe-clean ibex-wrapper
```

Resultado:

```text
Built from 76.436 MB sources in 145 modules
[PASS] IBEX_RTL_COMPILE: chipus_ibex_wrapper elaborado com Verilator
```

O teste comprova sintaxe, dependências e elaboração do wrapper com o Ibex
oficial. Não comprova simulação funcional, síntese ou implementação SKY130.
