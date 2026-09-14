# Ibex oficial

- upstream: <https://github.com/lowRISC/ibex>;
- revisão: `8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2`;
- clone: `ip-candidates/riscv/ibex`;
- top: `ibex_top`;
- ferramentas: FuseSoC 2.4.3 e Verilator 5.026.

```bash
make -C mini-SoC/pipe-clean ibex-core   # elaboração RTL
make -C mini-SoC/pipe-clean ibex-smoke  # execução de firmware
```

Resultado atual: `PASS` na elaboração e `SMOKE-PASS` funcional. Isso ainda não
comprova conformidade ISA completa, síntese ou timing em SKY130.
