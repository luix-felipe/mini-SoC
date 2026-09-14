# Evidência — top-level mínimo CHIPUS

- data: 2026-09-14;
- Ibex: `8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2`;
- FuseSoC: 2.4.3;
- Verilator: 5.023 devel;
- GCC RISC-V: 13.2.0;
- ISA do firmware: RV32IMC.

Comando reproduzível:

```bash
make -C pipe-clean chipus-soc-smoke
```

Resultado:

```text
[PASS] CHIPUS_SOC_SMOKE: reset, fetch, SRAM load/store and MMIO status
[PASS] CHIPUS_UART_SMOKE: transmitted 'O'
```

Também passou o lint do `chipus_soc_top` com as macros `SYNTHESIS` e
`DISABLE_PRIM_CDC_RAND_DELAY`.

O teste executa firmware real a partir de `0x1000_0080`, grava e relê a SRAM,
transmite `O` pela UART e termina escrevendo `1` no registrador de status.

Com autorização do operador, o LibreLane executou lint com zero erros e iniciou
`Yosys.Synthesis`. A tentativa com a SRAM RTL completa expandiu a memória em
mais de 1,6 milhão de células e provocou o reinício do WSL antes do fim da
síntese. O diagnóstico, as medições e a proteção adicionada ao fluxo estão em
`docs/reports/2026-09-14-librelane-wsl-incident.md`.

A conclusão da síntese, o STA e o P&R continuam pendentes. O `config.yaml` agora
reduz a SRAM para 1 KiB somente no gate de infraestrutura; os 64 KiB continuam
sendo usados pela simulação funcional.
