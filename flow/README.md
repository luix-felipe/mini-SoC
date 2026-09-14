# Fluxo LibreLane

Prepare a lista achatada de fontes do Ibex a partir do clone externo fixado:

```bash
make -C pipe-clean librelane-prepare
```

O resultado fica em `flow/src/`, é gerado e não pertence ao Git. O script
mantém os includes com seus nomes originais e prefixa numericamente as fontes
RTL para preservar a ordem de compilação produzida pelo FuseSoC. Dentro do
contêiner UNIC-CASS, entre no clone do projeto e execute:

```bash
cd /caminho/para/mini-SoC
/home/designer/shared/bin/librelane-local \
  --to Yosys.Synthesis \
  --run-tag chipus-synth \
  flow/config.yaml
```

O arquivo `config.yaml` seleciona `chipus_soc_top`, clock inicial de 20 MHz,
frontend Slang para SystemVerilog e biblioteca `sky130_fd_sc_hd` quando o PDK é
`sky130A`. Ele limita `SramWords` a 256 palavras (1 KiB) apenas no gate de
síntese. Isso valida frontend, integração e ferramentas sem expandir os 64 KiB
do modelo funcional em mais de 1,6 milhão de células. Não remova esse limite
antes de integrar uma macro SRAM.

A SRAM funcional tem 64 KiB em RTL inferido. O fluxo serve para validar a
infraestrutura e obter uma primeira síntese reduzida; área, timing e
implementação física não devem ser congelados antes da integração de uma macro
de memória. O incidente que motivou essa proteção está documentado em
`docs/reports/2026-09-14-librelane-wsl-incident.md`.
