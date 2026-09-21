# Plano de testes dos cores RISC-V

**Escopo atual:** Croc/CVE2 primeiro; Ibex como fallback.

## O que os testes provam

| Teste | Prova | Não prova |
| --- | --- | --- |
| Lint/elaboração | sintaxe, dependências e hierarquia | execução correta |
| Smoke funcional | caminho mínimo com firmware e término | cobertura ampla |
| Teste dirigido | comportamento conhecido de uma função | ausência de casos raros |
| Conformidade/co-sim | comportamento ISA contra referência | integração dos periféricos |
| Assertions/formal | propriedades sob hipóteses declaradas | comportamento fora delas |
| Síntese/STA | mapeamento, área e timing na biblioteca | fechamento físico completo |
| Pós-síntese | equivalência prática RTL/netlist | DRC/LVS |

## Situação comprovada

| Gate | Ibex | Croc/CVE2 |
| --- | --- | --- |
| Revisão identificada | `PASS` | `PASS` |
| Elaboração RTL | `PASS`: core com 144 módulos; wrapper com 145 | `PASS`, 211 módulos |
| Firmware mínimo | `SMOKE-PASS` | atividade parcial |
| Término determinístico | `PASS` | `BLOCKED` |
| Conformidade/coverage | não executado | não executado |
| Fluxo físico SKY130 | `CANDIDATE`: segunda execução até GDSII; DRC/LVS/antena e hold aprovados; setup falhou em 2 cantos e slew/capacitância/fanout permanecem abertos | `CANDIDATE`: GDSII, DRC/LVS/antena e setup/hold aprovados; slew, capacitância e fanout abertos |

O top-level mínimo CHIPUS com Ibex passou em reset, fetch, load/store na SRAM,
status MMIO e transmissão UART. O wrapper isolado também percorreu o fluxo
SKY130 até GDSII, mas não atingiu fechamento elétrico.

Ibex Simple System produziu `Hello simple system`, terminou por software e
aposentou 261 instruções. Croc acessou SRAM por JTAG e imprimiu pela UART, mas
entrou em diagnósticos repetidos de instrução ilegal sem o marcador de sucesso.

Na segunda execução física do Ibex, o pior canto de setup foi
`max_ss_100C_1v60`: slack de -1,816531 ns, TNS de -23,537308 ns e 35 caminhos;
`nom_ss` teve uma violação adicional de -0,300858 ns. Hold passou nos nove
cantos. O pior canto teve 6.981 ocorrências de slew, 71 de capacitância e 18 de
fanout. Todos os 35 caminhos do pior canto partem do registrador associado a
`register_file_i.raddr_a_i[1]`; o trecho final contém seis buffers físicos
`clkdlybuf4s25_1` e um buffer de reparo de hold antes de `crash_dump_o[32]`.

O `core_wrap` do Croc também percorreu o fluxo SKY130 até GDSII. Na reexecução
didática, DRC, LVS, antena, setup e hold passaram; permaneceram 5.090
ocorrências de slew, 60 de capacitância e 8 de fanout no pior canto. A análise
rastreou parte importante dos drivers lentos a buffers físicos
`clkdlybuf4s25_1`; isso é uma pendência de implementação, não evidência de erro
funcional no RTL do CVE2.

## Regressão mínima

```bash
make -C mini-SoC/pipe-clean ibex-core
make -C mini-SoC/pipe-clean ibex-wrapper
make -C mini-SoC/pipe-clean ibex-smoke
make -C mini-SoC/pipe-clean croc-smoke
make -C mini-SoC/pipe-clean chipus-soc-smoke
```

`ibex-core` e `ibex-wrapper` funcionam no WSL ou dentro do UNIC-CASS.
`ibex-smoke`, `croc-smoke` e `chipus-soc-smoke` devem ser iniciados no WSL,
pois criam contêineres efêmeros com dependências extras.

## Próximos gates

1. preservar os dois relatórios de pipe-clean e as revisões usadas;
2. reproduzir e localizar a causa do término bloqueado no smoke do Croc;
3. executar `print_config` e testes de periféricos do Croc;
4. classificar os warnings de lint e executar equivalência RTL/netlist;
5. adicionar testes Ibex de reset, loads/stores, erro, exceção e interrupção;
6. executar conformidade ISA para a configuração escolhida;
7. comparar cores com mesma ISA, memória, clock e interconexão;
8. revisar constraints com PD e depois investigar setup e limites elétricos;
9. somente após seleção e constraints realistas, planejar fechamento físico.

Resultados detalhados ficam em
[`experiments/riscv-core-qualification/evidence`](../../experiments/riscv-core-qualification/evidence/).
Os relatórios físicos ficam nos diretórios
[`experiments/librelane-ibex/evidence`](../../experiments/librelane-ibex/evidence/)
e
[`experiments/librelane-croc/evidence`](../../experiments/librelane-croc/evidence/).
