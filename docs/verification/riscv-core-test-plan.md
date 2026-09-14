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
| Síntese/STA SKY130 | não executado | não executado |

O top-level mínimo CHIPUS com Ibex passou em reset, fetch, load/store na SRAM,
status MMIO e transmissão UART. A síntese SKY130 permanece pendente.

Ibex Simple System produziu `Hello simple system`, terminou por software e
aposentou 261 instruções. Croc acessou SRAM por JTAG e imprimiu pela UART, mas
entrou em diagnósticos repetidos de instrução ilegal sem o marcador de sucesso.

## Regressão mínima

```bash
make -C mini-SoC/pipe-clean ibex-core
make -C mini-SoC/pipe-clean ibex-wrapper
make -C mini-SoC/pipe-clean ibex-smoke
make -C mini-SoC/pipe-clean croc-smoke
make -C mini-SoC/pipe-clean chipus-soc-smoke
```

O `ibex-core` funciona no WSL ou dentro do UNIC-CASS. Os outros dois alvos devem
ser iniciados no WSL, pois criam contêineres efêmeros com dependências extras.

## Próximos gates

1. corrigir/reproduzir o término do smoke do Croc;
2. executar `print_config` e periféricos do Croc;
3. adicionar testes Ibex de reset, loads/stores, erro, exceção e interrupção;
4. executar conformidade ISA para a configuração escolhida;
5. comparar cores com mesma ISA, memória, clock e interconexão;
6. sintetizar e executar STA com `sky130_fd_sc_hd`.

Resultados detalhados ficam em
[`experiments/riscv-core-qualification/evidence`](../../experiments/riscv-core-qualification/evidence/).
