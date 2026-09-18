# Laboratório LibreLane: core Croc/CVE2 isolado

Este experimento prepara a implementação física do `core_wrap` do Croc: o
wrapper que instancia o CVE2 e expõe clock, reset, interrupções, debug e duas
interfaces OBI. Ele não inclui `croc_soc`, SRAM, boot ROM, JTAG, UART, DMA ou
interconnect; portanto mede o core, não o SoC completo.

## Estado e escopo

Estado atual: `CANDIDATE` (sem signoff). O fluxo completo até GDSII foi
executado para `core_wrap`; DRC, LVS, antena e setup/hold passaram. Persistem
violações de slew e capacitância, além de limitações de IR drop e equivalência
RTL/netlist. Isso é independente do smoke funcional do Croc, que permanece
`BLOCKED` por falta de término JTAG determinístico.

### As pendências são defeitos do CVE2?

As evidências atuais não permitem atribuir essas pendências a defeitos do
RTL do CVE2. Elas aparecem em diferentes camadas do experimento:

| Pendência | Interpretação e próxima análise |
| --- | --- |
| Slew, capacitância e fanout | Violações elétricas da implementação física de `core_wrap`, influenciadas por buffers, roteamento, cargas e constraints SDC. Investigar os pontos violadores e validar as constraints de interface antes de alterá-las; ainda não há evidência de defeito no RTL do CVE2. |
| Smoke funcional com instrução ilegal | O teste do SoC Croc permanece `BLOCKED`. Firmware, ISA configurada, inicialização e integração precisam ser investigados para localizar a causa; esse teste inclui componentes ausentes deste experimento físico. |
| 316 warnings de lint | Classificar por arquivo e tipo antes de atribuir a origem ao CVE2, ao wrapper ou às dependências. A contagem isolada não demonstra um defeito funcional. |
| Equivalência RTL/netlist | `Yosys.EQY` foi pulado; é uma lacuna de verificação, não um resultado de equivalência reprovado. |
| IR drop e informações de antena | A ausência de `VSRC_LOC_FILES` e de dados de antena em nove pinos de entrada limita a qualificação e a modelagem. Revisar na integração superior; o checker final de antena reportou zero violações. |

O resultado demonstra que o `core_wrap` contendo o CVE2 pôde ser implementado
fisicamente nas revisões e condições registradas. A aprovação de DRC, LVS,
antena e setup/hold não comprova por si só a correção funcional do core nem
fecha as pendências elétricas. O estado continua `CANDIDATE` (sem signoff).
As prioridades são localizar a causa do bloqueio funcional do Croc, fechar
slew/capacitância/fanout, executar equivalência e classificar os warnings de
lint.

## Registro recebido do operador

Um run LibreLane alcançou o estágio `80/80` (`Report Manufacturability`) em
2 min 04 s, com `Flow complete`. O trecho recebido reporta 316 warnings de
lint; o nome da tag, os relatórios finais e a classificação desses warnings
ainda precisam ser registrados antes de alterar o estado do experimento ou
alegar aprovação de timing, DRC, LVS ou antena.

```text
[12:24:35] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:02:04
[12:24:35] WARNING  [Checker.LintWarnings] 316 Lint warnings found.
```

O operador confirmou em seguida que os três comandos dos gates iniciais abaixo
foram concluídos. O último, `croc-sta-prepnr`, terminou em 2 min 37 s e repetiu
os mesmos 316 warnings de lint:

```text
[12:29:21] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:02:37
[12:29:21] WARNING  [Checker.LintWarnings] 316 Lint warnings found.
```

| Gate | Tag | Evidência atual | Ainda necessário |
| --- | --- | --- | --- |
| Frontend | `croc-frontend` | `Flow complete` confirmado | log de lint e classificação dos warnings |
| Síntese | `croc-synth` | `Flow complete` confirmado | área, células, latches e células não mapeadas |
| STA pré-PnR | `croc-sta-prepnr` | `Flow complete` confirmado em 2 min 37 s | setup/hold, slew, capacitância e fanout por canto |

| Item | Valor |
| --- | --- |
| Croc | `968bab17b37e88d9200a0899cb9181e42850ec87` |
| CVE2 integrado pelo Croc | `53076d64c97685b1d2f5d07cd7f5cc439cf1f351` |
| Top | `core_wrap` |
| Biblioteca | `sky130_fd_sc_hd` |
| Clock inicial | 20 MHz (50 ns) |

As constraints de I/O são iniciais e didáticas. Resultado de saída zero não
equivale a signoff: setup, hold, slew, capacitância, DRC, LVS, antena, IR drop
e equivalência RTL/netlist devem ser analisados explicitamente.

## Preparar fontes

No contêiner UNIC-CASS, na raiz de `mini-SoC`:

```bash
make -C pipe-clean librelane-croc-prepare
```

O comando verifica a revisão do Croc, baixa Bender 0.32.1 em diretório
temporário com checksum fixado e gera `flow/croc-src/`. As fontes ficam
ordenadas conforme Bender e os includes ficam separados por pacote. O diretório
gerado é ignorado pelo Git e pode ser recriado; nenhum clone upstream é alterado.

## Roteiro incremental

Defina o executável uma vez no contêiner. Cada `--run-tag` preserva uma
evidência em `runs/<tag>/`; não reutilize a tag depois de alterar a configuração
ou as constraints.

```bash
LL=/home/designer/shared/bin/librelane-local

"$LL" --run-tag croc-frontend --to Yosys.JSONHeader \
  experiments/librelane-croc/config.yaml

"$LL" --run-tag croc-synth --to Yosys.Synthesis \
  experiments/librelane-croc/config.yaml

"$LL" --run-tag croc-sta-prepnr --to OpenROAD.STAPrePNR \
  experiments/librelane-croc/config.yaml
```

Use uma tag nova a cada tentativa. Os resultados vão para `runs/<tag>/`, que
não pertence ao Git. Só avance para floorplan, PDN e roteamento depois de
registrar os warnings de frontend e as métricas de síntese/STA.

### Evidências dos gates 1–4

| Gate | O que registrar no run | Estado |
| --- | --- | --- |
| Preparar fontes | revisão, checksum Bender e contagem de fontes/includes | concluído: 168 fontes e 5 includes |
| Frontend | `warning.log`, `error.log`, `flow.log` e classificação de warnings | `Flow complete`; 316 warnings pendentes |
| Síntese | área/células, FFs, memórias, latches, células não mapeadas e check | `Flow complete`; métricas pendentes |
| STA pré-PnR | setup/hold, slew, capacitância, fanout e ports sem constraint por canto | `Flow complete`; métricas pendentes |
| Floorplan | área de core, utilização, rows, pinos e warnings OpenROAD | 8.957 células, 118.392 µm², 22,07% e 267 rows; 316 warnings de lint pendentes; correção de `ORD-0032` confirmada no PDN |
| PDN | continuidade de alimentação, tapcells, endcaps e erros da grade | `Flow complete` em 2 min 23 s; só 316 warnings de lint no resumo final |
| Placement | utilização, congestionamento, buffers/reparos e limites elétricos | `Flow complete` em 3 min 01 s; warnings de fanout de clock, Liberty repetida e duas redes flutuantes aguardam análise |
| CTS | buffers/inversores de clock, skew e alertas de placement | `Flow complete` em 3 min 19 s; métricas de clock pendentes |
| STA pós-CTS | setup/hold e limites elétricos após reparos | `Flow complete` em 4 min 06 s; métricas multicorner pendentes |
| Roteamento global | overflow e uso de recursos | `Flow complete` em 4 min 12 s; métricas pendentes |
| Roteamento detalhado | DRC interno, antena, fios e vias | `Flow complete` em 12 min 56 s; `GRT-0243` e `DRT-0349` aguardam verificação final |
| Fluxo completo | GDSII, STA pós-layout, DRC, LVS e antena | GDSII gerado em 19 min 59 s; DRC/LVS/antena e setup/hold aprovados; slew e capacitância reprovados |

### 5. Floorplan — concluído, métricas pendentes

```bash
"$LL" --run-tag croc-floorplan --to OpenROAD.Floorplan \
  experiments/librelane-croc/config.yaml
```

O die inicial é 750 x 750 µm, apenas um ponto de partida. Registrar área de
core, utilização, rows e posição dos pinos antes de mudar o die.

Estado: `Flow complete` registrado em 2 min 24 s. O run emitiu os mesmos 316
warnings de lint e `ORD-0032` (`Invalid thread number`) no Floorplan. Como o
fluxo terminou, o aviso não bloqueou este gate, mas a configuração de threads
foi corrigida com `OPENROAD_THREADS: 8` em `config.yaml`. Uma nova tag deve
confirmar a ausência do warning; o run já registrado mantém esse aviso. Ainda
faltam as métricas de posição de pinos.

Métricas extraídas de `final/metrics.json`: 8.957 células standard, área de
instâncias de 118.392 µm², die de 562.500 µm², core de 536.517 µm², utilização
de 22,07% e 267 rows. O gate reportou zero erro e três warnings internos: um
`ORD-0032` e dois `ODB-0220` sobre sintaxe LEF obsoleta do PDK.

```text
[12:46:41] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:02:24
[12:46:41] WARNING  [Checker.LintWarnings] 316 Lint warnings found.
[12:46:41] WARNING  [OpenROAD.Floorplan] [ORD-0032] Invalid thread number
```

### 6. PDN — concluído, métricas pendentes

```bash
"$LL" --run-tag croc-pdn --to OpenROAD.GeneratePDN \
  experiments/librelane-croc/config.yaml
```

Registrar continuidade de `VPWR`/`VGND`, tapcells, endcaps e erros da grade.
Esse gate não qualifica IR drop sem fontes físicas de alimentação.

Estado: `Flow complete` registrado em 2 min 23 s. O resumo final repetiu apenas
os 316 warnings de lint; `ORD-0032` não reapareceu, confirmando a correção com
`OPENROAD_THREADS: 8`. Ainda faltam os relatórios de continuidade de
alimentação, tapcells/endcaps e erros da grade.

```text
[13:38:08] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:02:23
[13:38:08] WARNING  [Checker.LintWarnings] 316 Lint warnings found.
```

### 7. Placement — concluído, métricas pendentes

```bash
"$LL" --run-tag croc-placement --to OpenROAD.DetailedPlacement \
  experiments/librelane-croc/config.yaml
```

Registrar utilização, congestionamento, reparos/buffers inseridos, overflow e
violações de slew, capacitância ou fanout após legalização.

Estado: `Flow complete` registrado em 3 min 01 s. Além dos 316 warnings de
lint, o run reportou fanout alto de `clk_i` (1.792 destinos), carregamento
repetido da Liberty `sky130_fd_sc_hd__tt_025C_1v80` (`STA-1140`) e duas redes
flutuantes (`RSZ-0020`). O fanout do clock é esperado antes da CTS e deve ser
reavaliado depois dela. `STA-1140` aparenta ser aviso de infraestrutura; as
redes flutuantes devem ser identificadas nos relatórios antes de qualquer
correção. Ainda faltam utilização, congestionamento e reparos inseridos.

```text
[13:47:03] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:03:01
[13:47:03] WARNING  [Checker.LintWarnings] 316 Lint warnings found.
[13:47:03] WARNING  [OpenROAD.GlobalPlacement] [GRT-0281] Net clk_i has a large fanout of 1792 terminals.
[13:47:03] WARNING  [OpenROAD.RepairDesignPostGPL] [STA-1140] library sky130_fd_sc_hd__tt_025C_1v80 already exists.
[13:47:03] WARNING  [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.
```

### 8. CTS e STA pós-CTS — concluídos, métricas pendentes

```bash
"$LL" --run-tag croc-cts --to OpenROAD.CTS \
  experiments/librelane-croc/config.yaml

"$LL" --run-tag croc-postcts --to OpenROAD.STAMidPNR-2 \
  experiments/librelane-croc/config.yaml
```

O sufixo `-2` segue a sequência observada no LibreLane do Ibex; confirmar o
nome do estágio no log caso a versão do fluxo seja diferente. Registrar buffers
de clock, skew, setup/hold e limites elétricos por canto depois dos reparos.

Estado: os dois comandos concluíram. CTS terminou em 3 min 19 s e STA pós-CTS
em 4 min 06 s. Ambos repetiram os 316 warnings de lint, o fanout de 1.792
destinos em `clk_i`, `STA-1140` e duas redes flutuantes. O número de avisos
`STA-1140` aumentou de 11 no CTS para 17 na STA pós-CTS; isso continua sendo
tratado como carregamento repetido de biblioteca, não como duplicação de RTL.
Ainda faltam buffers/inversores de clock, skew, setup/hold, slew, capacitância
e fanout por canto para avaliar este passo.

```text
# CTS
[14:25:21] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:03:19
[14:25:21] WARNING  [Checker.LintWarnings] 316 Lint warnings found.
[14:25:21] WARNING  [OpenROAD.GlobalPlacement] [GRT-0281] Net clk_i has a large fanout of 1792 terminals.
[14:25:21] WARNING  [OpenROAD.RepairDesignPostGPL] [STA-1140] library sky130_fd_sc_hd__tt_025C_1v80 already exists.
[14:25:21] WARNING  [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.

# STA pós-CTS
[14:32:57] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:04:06
[14:32:57] WARNING  [Checker.LintWarnings] 316 Lint warnings found.
[14:32:57] WARNING  [OpenROAD.GlobalPlacement] [GRT-0281] Net clk_i has a large fanout of 1792 terminals.
[14:32:57] WARNING  [OpenROAD.RepairDesignPostGPL] [STA-1140] library sky130_fd_sc_hd__tt_025C_1v80 already exists.
[14:32:57] WARNING  [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.
```

### 9. Roteamento — concluído, métricas pendentes

```bash
"$LL" --run-tag croc-global-routing --to OpenROAD.GlobalRouting \
  experiments/librelane-croc/config.yaml

"$LL" --run-tag croc-detailed-routing --to OpenROAD.DetailedRouting \
  experiments/librelane-croc/config.yaml
```

No global routing, registrar overflow e uso de recursos. No detailed routing,
registrar DRC interno, antena, comprimento de fios e vias; esses resultados não
substituem a verificação independente do layout final.

Estado: global routing terminou em 4 min 12 s e detailed routing em 12 min
56 s. Ambos repetiram os warnings já observados de lint, fanout de `clk_i`,
`STA-1140` e `RSZ-0020`. O detailed routing também reportou `GRT-0243`, sem
reparo de antena para uma rede com diodos, e `DRT-0349`, que pula a regra
`LEF58_ENCLOSURE` sem `CUTCLASS` na camada `mcon`. Esses avisos não provam DRC
ou antena aprovados; o passo 10 precisa confirmar Magic/KLayout e o checker de
antena. Ainda faltam overflow, recursos, fios e vias dos relatórios.

```text
# Global routing
[14:42:11] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:04:12
[14:42:11] WARNING  [Checker.LintWarnings] 316 Lint warnings found.
[14:42:11] WARNING  [OpenROAD.GlobalPlacement] [GRT-0281] Net clk_i has a large fanout of 1792 terminals.
[14:42:11] WARNING  [OpenROAD.RepairDesignPostGPL] [STA-1140] library sky130_fd_sc_hd__tt_025C_1v80 already exists.
[14:42:11] WARNING  [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.

# Detailed routing
[14:55:53] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:12:56
[14:55:53] WARNING  [Checker.LintWarnings] 316 Lint warnings found.
[14:55:53] WARNING  [OpenROAD.GlobalPlacement] [GRT-0281] Net clk_i has a large fanout of 1792 terminals.
[14:55:53] WARNING  [OpenROAD.RepairDesignPostGPL] [STA-1140] library sky130_fd_sc_hd__tt_025C_1v80 already exists.
[14:55:53] WARNING  [OpenROAD.RepairDesignPostGPL] [RSZ-0020] found 2 floating nets.
[14:55:53] WARNING  [OpenROAD.DiodeInsertion] [GRT-0243] Unable to repair antennas on net with diodes.
[14:55:53] WARNING  [OpenROAD.DetailedRouting] [DRT-0349] LEF58_ENCLOSURE with no CUTCLASS is not supported for mcon.
```

### 10. Fluxo completo e verificações finais — concluído, sem signoff

```bash
"$LL" --run-tag croc-full \
  experiments/librelane-croc/config.yaml
```

O run `croc-full` terminou em 19 min 59 s e gerou
`final/gds/core_wrap.gds`. Os resultados verificados em `final/metrics.json` e
nos checkers são:

| Verificação | Resultado |
| --- | --- |
| Setup / hold | zero violação nos nove cantos analisados; pior setup slack +6,498 ns e hold +0,109 ns |
| Slew | reprovado nos nove cantos; maior contagem: 5.104 no `max_ss_100C_1v60` |
| Capacitância | reprovado em seis cantos; maior contagem: 66 no `max_ss_100C_1v60` |
| Fanout | seis violações reportadas; requer análise das redes antes de signoff |
| Roteamento | DRC interno final zero; reparo de antena inseriu 51 diodos, apesar do warning `GRT-0243` intermediário |
| Antena | zero redes e pinos violadores no checker final |
| DRC | Magic e KLayout: zero erro |
| LVS | zero diferenças/erros de dispositivo, rede, propriedade ou pino |
| Equivalência RTL/netlist | não executada: `Yosys.EQY` foi pulado |

O resumo final também mantém 316 warnings de lint, o fanout alto de `clk_i`,
`STA-1140`, duas redes flutuantes, `DRT-0349`, checker de wire length sem
limiar, `VSRC_LOC_FILES` ausente e nove pinos de entrada sem informação de
antena de gate. `VSRC_LOC_FILES` ausente impede considerar IR drop como
qualificado. DRC/LVS/antena aprovados não anulam as violações elétricas nem
substituem equivalência RTL/netlist.

```text
[15:26:17] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:19:59
[15:26:17] WARNING  [Checker.MaxSlewViolations] Max Slew violations found in all nine analyzed corners.
[15:26:17] WARNING  [Checker.MaxCapViolations] Max Cap violations found in six analyzed corners.
```

## Como enviar evidências

Para cada novo gate, envie comando/tag, trecho `Flow complete` ou erro, warnings
finais e as métricas pedidas pela etapa. O registro separará fatos confirmados,
pendências e correções justificadas pela evidência.
