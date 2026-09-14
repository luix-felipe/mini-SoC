# Qualificação dos cores RISC-V

Usa clones externos somente para leitura e não importa RTL ao `mini-SoC`.

| Candidato | Revisão |
| --- | --- |
| Ibex | `8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2` |
| Croc | `968bab17b37e88d9200a0899cb9181e42850ec87` |
| CVE2 do Croc | `53076d64c97685b1d2f5d07cd7f5cc439cf1f351` |

## Executar

Use preferencialmente a interface em [`pipe-clean`](../../pipe-clean/README.md):

```bash
make -C mini-SoC/pipe-clean ibex-core
make -C mini-SoC/pipe-clean ibex-wrapper
make -C mini-SoC/pipe-clean ibex-smoke
make -C mini-SoC/pipe-clean croc-smoke
```

## Resultado

| Gate | Estado |
| --- | --- |
| `ibex_top` elaborado no Verilator | `PASS` |
| wrapper CHIPUS + `ibex_top` elaborados no Verilator | `PASS` |
| Ibex Simple System com firmware e halt | `SMOKE-PASS` |
| Croc RTL completo compilado | `PASS` |
| Croc `helloworld` com término limpo | `BLOCKED` |

No Croc, JTAG/SRAM e UART funcionaram, mas houve repetição de diagnóstico de
instrução ilegal sem marcador final de sucesso. O alvo retorna erro para não
confundir atividade parcial com passe.

Adaptações de execução ficam isoladas nos scripts: correção de opção obsoleta do
Simple System Ibex e compatibilidade temporária da toolchain do Croc. Nenhum
clone upstream é modificado.

Evidência: [`evidence/2026-09-01.md`](evidence/2026-09-01.md).
