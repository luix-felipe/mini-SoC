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
Para o pipe-clean, a prioridade agora é localizar a causa do bloqueio funcional
do Croc e preservar as evidências. Slew/capacitância/fanout, equivalência e
warnings de lint permanecem registrados como pendências; não precisam ser
corrigidos antes da comparação arquitetural dos cores.

## Relatórios das duas execuções

Os resultados não foram fundidos porque pertencem a máquinas, tags e runs
diferentes:

| Execução | Tag | Origem da evidência | Relatório |
| --- | --- | --- | --- |
| 1 — original | `croc-full` | terminal e métricas recebidos da outra máquina; artefatos do run não estão disponíveis nesta worktree | [`execution-1-croc-full.md`](evidence/execution-1-croc-full.md) |
| 2 — reexecução didática | `croc-study-full` | terminal recebido e artefatos locais, incluindo `final/metrics.json` | [`execution-2-croc-study-full.md`](evidence/execution-2-croc-study-full.md) |

As diferenças de contagem entre elas não devem ser somadas nem tratadas como
regressão sem comparar ambiente, configuração e fontes efetivamente usadas.

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

## Reexecução didática — 2026-09-20

### Preparação das fontes — pré-requisito

As fontes foram novamente preparadas na revisão registrada: 168 arquivos RTL
e 5 diretórios de include. A primeira tentativa de frontend foi rejeitada antes
da leitura do RTL porque `OPENROAD_THREADS` não pertence ao schema desta versão;
a chave foi removida e o histórico correspondente foi corrigido abaixo.

### 1 — Frontend: leitura, lint e elaboração

O frontend seguinte foi executado com uma tag nova:

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-frontend-v2 \
  --to Yosys.JSONHeader \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, nenhum erro de lint e nenhuma construção
de timing proibida. Duração total de 4,09 s, pico RSS de 109.688 KiB e zero
swap nos processos medidos. Os 298 warnings foram classificados assim:

| Tipo | Quantidade | Leitura inicial |
| --- | ---: | --- |
| `GENUNNAMED` | 115 | blocos gerados sem nome explícito; afeta rastreabilidade, não comprova erro lógico |
| `PINCONNECTEMPTY` | 102 | pinos de saída deliberadamente não conectados em instâncias |
| `UNUSEDPARAM` | 47 | parâmetros não usados na configuração elaborada |
| `UNUSEDSIGNAL` | 22 | sinais declarados e não consumidos |
| `WIDTHEXPAND` | 8 | constantes de 11 bits estendidas para offsets GPIO de 12 bits; fora do caminho do `core_wrap`, mas devem continuar registradas |
| `WIDTHTRUNC` | 1 | `UserDesign` de 5 bits usado num campo de 4 bits em `user_pkg`; fora do top isolado e merece revisão no SoC completo |
| `UNOPTFLAT` | 3 | dependências combinacionais no CVE2 (`instr_executing_spec`, `special_req` e `id_in_ready`); verificar o resultado da síntese, sem editar o upstream apenas para ocultar o lint |

A redução de 316 para 298 warnings não deve ser interpretada isoladamente como
melhoria do RTL: é um run novo após mudança de configuração/ambiente. Os logs
completos ficam em `runs/croc-study-frontend-v2/`, ignorados pelo Git.

### 2 — Síntese: mapeamento para células SKY130

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-synth \
  --to Yosys.Synthesis \
  experiments/librelane-croc/config.yaml
```

O Yosys elaborou e otimizou o RTL; o ABC mapeou a lógica combinacional para
`sky130_fd_sc_hd`. Resultado: `Flow complete`, saída zero, 1 min 55,95 s,
pico RSS de 862.524 KiB e zero swap nos processos medidos.

| Métrica | Resultado |
| --- | ---: |
| Células SKY130 | 9.110 |
| Área estimada | 118.597,49 µm² (0,1186 mm²) |
| Flip-flops | 1.791 (`dfrtp`: 1.783; `dfstp`: 8) |
| Multiplexadores | 2.141 (`mux2`: 2.046; `mux4`: 95) |
| Memórias | 0 |
| Latches inferidos | 0 |
| Células não mapeadas | 0 |
| Problemas no `check` do Yosys | 0 |

O top foi achatado (`num_submodules: 0`): a hierarquia virou uma rede de células
sob `core_wrap`. As mensagens intermediárias sobre tipos de DFF “unmapped” são
tentativas do mapeador; a métrica final igual a zero confirma que nenhum deles
permaneceu sem célula. Os três `UNOPTFLAT` do lint não produziram erro no check
final, mas isso não substitui simulação funcional nem análise de timing.

### 3 — STA pré-PnR: timing antes do layout

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-sta-prepnr \
  --to OpenROAD.STAPrePNR \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, 2 min 12,94 s, pico RSS de
862.892 KiB e zero swap nos processos medidos. A análise usou clock ideal:
`clk_i` aparece como não propagado porque a árvore física só será criada na CTS.

| Canto | Setup: pior slack | Hold: pior slack | Slew | Fanout | Capacitância |
| --- | ---: | ---: | ---: | ---: | ---: |
| TT / 25 °C / 1,80 V | +32,748 ns | +0,240 ns | 4.104 | 308 | 21 |
| SS / 100 °C / 1,60 V | +15,134 ns | +0,718 ns | 6.126 | 308 | 48 |
| FF / -40 °C / 1,95 V | +36,243 ns | +0,066 ns | 3.101 | 308 | 16 |

Setup e hold passaram nos três cantos, com WNS/TNS zero. O canto SS foi o pior
para setup e limites elétricos; o FF teve a menor margem de hold. As contagens
de slew/fanout/capacitância são violações do netlist ainda sem fios e buffers
físicos. Placement, reparos e CTS devem reduzi-las; não estão aprovadas e serão
medidas novamente. Esta STA não substitui a análise pós-CTS/pós-extração.

### 4 — Floorplan: geometria inicial

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-floorplan \
  --to OpenROAD.Floorplan \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, 2 min 11,79 s, pico RSS de
862.864 KiB e zero swap nos processos medidos.

| Métrica | Resultado |
| --- | ---: |
| Die | 750 × 750 µm (562.500 µm²) |
| Região do core | `(5,52; 10,88)` a `(744,28; 737,12)` µm |
| Área da região do core | 536.517 µm² |
| Área inicial das células | 118.597 µm² |
| Utilização inicial | 22,11% |
| Rows | 267 |
| Sites disponíveis | 428.802 |
| Bits de I/O | 229 |
| Macros/padcells | 0 / 0 |

O floorplan criou a área e as rows, mas ainda não posicionou definitivamente
as células. A distribuição dos 229 bits de I/O nas bordas ocorrerá no estágio
de I/O placement. O antigo `ORD-0032` não reapareceu. Os dois warnings internos
`ODB-0220` indicam uma instrução LEF obsoleta no PDK, sem erro de floorplan.

### 5 — PDN: distribuição de alimentação

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-pdn \
  --to OpenROAD.GeneratePDN \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, 2 min 17,50 s, pico RSS de
862.372 KiB e zero swap nos processos medidos.

| Verificação | Resultado |
| --- | ---: |
| Tapcells inseridas | 7.666 |
| Fill/endcap cells reportadas | 534 |
| Conexões globais realizadas | 17.468 |
| Conflitos de conexão | 0 |
| Violações de grade em `VPWR` | 0 |
| Violações de grade em `VGND` | 0 |
| Utilização reportada após tapcells | 23,89% |

O OpenROAD confirmou que todas as formas metálicas de `VPWR` e `VGND` estão
conectadas; os dois relatórios `*-grid-errors.rpt` ficaram vazios. Isso comprova
construção e continuidade da grade, não IR drop. `ORD-0039` apareceu apenas
porque `.openroad` é ignorado no modo Python e não gerou erro no estágio.

Próximo passo desta reexecução: **6 — Placement global**. O placement detalhado
será registrado separadamente como passo 7 para deixar as funções explícitas.

### 6 — Placement global: distribuição aproximada

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-global-placement \
  --to OpenROAD.GlobalPlacement \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, 2 min 20,19 s, pico RSS de
862.736 KiB e zero swap nos processos medidos.

| Métrica | Resultado |
| --- | ---: |
| Densidade-alvo | 0,3389 |
| HPWL estimado final | 421.378 µm |
| Congestionamento ponderado final | 0,9303 |
| Área artificial adicionada para roteabilidade | +1,05% |
| Fanout de `clk_i` | 1.792 destinos |
| Fanout de `rst_ni` | 1.792 destinos |

A otimização encontrou congestionamento localizado nas tentativas iniciais,
inflou temporariamente algumas células e terminou abaixo do alvo de 1,0100.
Isso indica uma hipótese roteável, não overflow final zero: somente o global
routing validará a capacidade das trilhas. Clock e reset de alto fanout são
esperados antes dos reparos/CTS e devem ser reavaliados depois.

O I/O placement distribuiu 229 sinais: 55 ao norte, 105 a leste, 68 a oeste e
1 ao sul, conforme o `pin_order.cfg`. As posições das células ainda são
aproximadas e serão legalizadas no próximo passo.

Próximo passo desta reexecução: **7 — Reparos e placement detalhado**.

### 7 — Reparos e placement detalhado: legalização

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-detailed-placement \
  --to OpenROAD.DetailedPlacement \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, 3 min 01,53 s, pico RSS de
862.668 KiB e zero swap nos processos medidos.

| Operação/métrica | Resultado |
| --- | ---: |
| Células redimensionadas | 57 |
| Buffers para 399 redes reparadas | 2.262 |
| Buffers de entrada | 115 |
| Buffers de saída | 100 |
| Total de timing repair buffers | 2.477 |
| Tie cells inseridas | 4 |
| Utilização após reparos | 28,08% |
| Deslocamento médio para legalização | 1,6 µm |
| Deslocamento máximo | 17,6 µm |
| HPWL após legalização/orientação | 665.096 µm |

O reparador zerou sua fila de 9.454 alvos e o detailed placement encaixou as
células nas rows, espelhando 3.957 instâncias para melhorar o HPWL. Uma STA
dedicada ainda não foi executada após esses reparos; as métricas do passo 3 não
devem ser tratadas como resultado atual.

`RSZ-0020` identificou `VPWR` e `VGND` como duas redes flutuantes durante o
resizer. Elas são redes especiais da PDN, não sinais funcionais soltos; a etapa
anterior confirmou continuidade e zero erro de grade. `STA-1140` registra o
carregamento repetido das bibliotecas Liberty e não indica duplicação do RTL.

Próximo passo desta reexecução: **8 — CTS**.

### 8 — CTS: construção da árvore de clock

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-cts \
  --to OpenROAD.CTS \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, 3 min 18,41 s, pico RSS de
862.580 KiB e zero swap nos processos medidos.

| Métrica CTS | Resultado |
| --- | ---: |
| Raízes de clock | 1 |
| Sinks | 1.791 |
| Buffers criados pela árvore | 253 |
| Sub-redes de clock | 253 |
| Buffers por caminho (mín./máx.) | 4 / 4 |
| Nível máximo da árvore | 5 |
| Leaf buffers | 216 |
| Clock buffers finais classificados | 386 |
| Clock inverters finais classificados | 31 |
| Utilização após CTS | 29,09% |

O `cts.rpt` lista ainda 164 células auxiliares usadas durante a construção e
reparo da árvore; por isso os 253 buffers diretamente criados pelo TritonCTS não
são a mesma métrica que as 417 células finais classificadas como clock
buffer/inverter. Foram feitas 1.668 conexões globais sem conflito.

No canto TT, o pior skew reportado foi +0,722 ns para setup e -0,706 ns para
hold. Os números SS/FF presentes no agregado ainda são herdados do clock ideal
da análise anterior; não representam nova STA física nesses cantos. CTS não
comprova fechamento de setup/hold: isso será medido após os reparos seguintes.

Próximo passo desta reexecução: **9 — STA e reparos pós-CTS**.

### 9 — STA e reparos pós-CTS

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-postcts \
  --to OpenROAD.STAMidPNR-2 \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, 4 min 29,94 s, pico RSS de
862.264 KiB e zero swap nos processos medidos.

O resizer não encontrou violação de setup. Antes do reparo de hold, encontrou
1.439 endpoints violadores e inseriu 1.437 buffers, elevando o total acumulado
de timing repair buffers para 3.914. Depois legalizou novamente as células.

| Métrica recalculada — TT/25 °C/1,80 V | Resultado |
| --- | ---: |
| Pior slack de setup | +30,992 ns |
| Violações de setup | 0 |
| Pior slack de hold | +0,305 ns |
| Violações de hold | 0 |
| WNS/TNS de setup e hold | 0 / 0 |
| Pior skew (magnitude) | 0,289 ns |
| Violações de slew | 11 |
| Violações de fanout | 2 |
| Violações de capacitância | 0 |
| Utilização após reparos | 31,77% |

Os reparos fecharam setup/hold no canto TT e reduziram o skew, mas slew e
fanout ainda não estão zerados. Os valores SS/FF presentes no agregado continuam
herdados do passo 3; este gate não os recalculou após CTS. Somente as análises
multicorner finais pós-extração poderão sustentar uma conclusão de timing.

Próximo passo desta reexecução: **10 — Roteamento global**.

### 10 — Roteamento global: planejamento dos fios

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-global-routing \
  --to OpenROAD.GlobalRouting \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, 4 min 34,74 s, pico RSS de
862.720 KiB e zero swap nos processos medidos.

| Camada | Uso | Overflow H / V / total |
| --- | ---: | ---: |
| `met1` | 41,10% | 0 / 0 / 0 |
| `met2` | 41,97% | 0 / 0 / 0 |
| `met3` | 14,76% | 0 / 0 / 0 |
| `met4` | 13,60% | 0 / 0 / 0 |
| `met5` | 0,87% | 0 / 0 / 0 |
| Total | 30,50% | 0 / 0 / 0 |

Foram planejadas 13.393 redes, 1.044.666 µm de fios e 107.310 vias. O
roteador precisou de iterações extras, mas terminou com overflow zero em todas
as camadas. Isso comprova capacidade global; ainda não define geometria exata
nem substitui DRC.

Próximo passo desta reexecução: **11 — Roteamento detalhado**.

### 11 — Roteamento detalhado: geometria exata

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-detailed-routing \
  --to OpenROAD.DetailedRouting \
  experiments/librelane-croc/config.yaml
```

Resultado: `Flow complete`, saída zero, 14 min 42,63 s, pico RSS de
1.475.824 KiB e zero swap nos processos medidos.

| Métrica final | Resultado |
| --- | ---: |
| Redes roteadas | 13.402 + 2 especiais |
| Comprimento de fios | 800.174 µm |
| Vias | 109.338 |
| DRC interno do roteador | 0 |
| Violações finais de antena — redes/pinos | 0 / 0 |
| Antenna cells finais | 84 |
| Utilização | 31,81% |

A primeira checagem encontrou 122 redes e 149 pinos com antena. O reparador
inseriu 242 jumpers e 36 diodos nas primeiras rodadas; o detailed routing fez
novos reparos, chegando a 84 antenna cells no banco final. O `GRT-0243` ocorreu
quando uma tentativa intermediária não resolveu uma rede com diodo, mas as
checagens posteriores terminaram em zero. Violações internas de roteamento
caíram de 9.682 para zero ao longo das iterações.

`DRT-0349` informa que o roteador pulou regras `LEF58_ENCLOSURE` sem `CUTCLASS`
para `mcon` e outras camadas. Portanto, zero DRC interno não basta: Magic e
KLayout precisam verificar o GDS final de forma independente.

Próximo passo desta reexecução: **12 — Fluxo completo, GDSII e signoff checks**.

### 12 — Fluxo completo: GDSII e verificações finais

```bash
/usr/bin/time -v "$LL" \
  --run-tag croc-study-full \
  experiments/librelane-croc/config.yaml
```

Sem `--to`, o LibreLane executa o fluxo inteiro até a geração das vistas finais
e os checkers de manufaturabilidade. Resultado: `Flow complete`, saída zero,
28 min 43,86 s de tempo de parede, pico RSS de 1.483.136 KiB e zero swap nos
processos medidos.

| Verificação final | Resultado |
| --- | --- |
| GDSII | gerado (`final/gds/core_wrap.gds`) |
| Comparação LVS | `Circuits match uniquely` |
| DRC Magic / KLayout | 0 / 0 violações |
| Antena final | 0 redes e 0 pinos violadores |
| Setup — 9 cantos | aprovado; WNS/TNS = 0 / 0 |
| Hold — 9 cantos | aprovado; WNS/TNS = 0 / 0 |
| Pior slack de setup | +3,957 ns (`max_ss`) |
| Pior slack de hold | +0,104 ns (`min_ff`) |
| Slew | reprovado nos 9 cantos; pior contagem = 5.090 |
| Capacitância | reprovada em 5 cantos; pior contagem = 60 |
| Fanout | 8 violações no agregado final |

As vistas finais também incluem DEF, ODB, LEF, netlists, SDC, SPICE e uma
renderização PNG. O check de equivalência formal `Yosys.EQY` foi pulado porque
o gate correspondente está desabilitado na configuração; LVS não substitui
essa comparação lógica entre RTL e netlist sintetizada.

Os avisos `RSZ-0020` referem-se a `VPWR` e `VGND` tratados como special nets,
não a sinais funcionais comprovadamente desconectados. O `GRT-0243` ocorreu
durante uma tentativa intermediária de reparo de antena, mas os checkers finais
terminaram em zero. O `DRT-0349` registra uma limitação de interpretação de
regras LEF58 pelo roteador; por isso os resultados independentes de Magic e
KLayout são a evidência física final deste run.

O relatório de IR drop não é conclusivo porque `VSRC_LOC_FILES` não foi
definido. Também faltam informações de gate de antena para alguns pinos da
biblioteca, e o checker de fios longos foi pulado por ausência de threshold.

**Conclusão do experimento:** o CVE2/Croc isolado é **CANDIDATE** para o fluxo
SKY130A: o RTL foi sintetizado, colocado, roteado e convertido em GDSII, com
DRC, LVS, antena, setup e hold aprovados neste ensaio. Ainda não deve ser
chamado de IP em signoff, pois slew, capacitância e fanout não fecharam e a
análise de IR drop não foi qualificada. O resumo reproduzível está em
[`evidence/execution-2-croc-study-full.md`](evidence/execution-2-croc-study-full.md).

Próximo passo didático: **13 — inspecionar as vistas e os relatórios finais**.

```bash
klayout experiments/librelane-croc/runs/croc-study-full/final/gds/core_wrap.gds
```

O comando abre o GDSII no KLayout; ele não refaz o fluxo. Conferir o contorno
do die, anel/straps de alimentação, distribuição das células, pinos, árvore de
clock e roteamento. Depois, comparar visualmente com o DEF e consultar
`final/metrics.json` para não inferir qualidade elétrica apenas pela imagem.

Resultado da inspeção recebida: o arquivo abriu como célula superior
`core_wrap`. A vista mostra die retangular, linhas de standard cells, malha de
alimentação/roteamento e os pinos externos distribuídos nas bordas. Os nomes
`instr_*` visíveis nas laterais correspondem à interface de instruções exposta
pelo wrapper. Não há macros de memória, coerente com a métrica de zero macros
e com o escopo de core isolado.

A região central com cores sobrepostas não deve ser interpretada como macro ou
erro apenas pela imagem: todas as camadas e textos estão visíveis ao mesmo
tempo. No painel `Layers`, ocultar temporariamente textos e camadas inferiores
e habilitar uma camada metálica por vez ajuda a distinguir células, straps da
PDN, vias e sinais. A inspeção visual confirma que a vista é legível, mas não
substitui os resultados de DRC, LVS, antena ou STA.

Estado do passo 13: **concluído para a execução 2 (`croc-study-full`)**.
Próximo passo didático: **14 — relacionar as vistas finais e o propósito de
cada arquivo**.

### 14 — Inventário e função das vistas finais

```bash
find experiments/librelane-croc/runs/croc-study-full/final \
  -maxdepth 2 -type f | sort
```

Resultado: foram encontradas 16 vistas/relatórios finais. Cada representação
serve a uma etapa diferente; não existe um único arquivo que substitua todos
os demais.

| Vista | Função principal |
| --- | --- |
| `def/core_wrap.def` | descrição física textual: die, componentes colocados, pinos e rotas |
| `gds/core_wrap.gds` | layout final principal entregue para fabricação/integração |
| `json_h/core_wrap.h.json` | cabeçalho estrutural do frontend Yosys: top, portas, direções e larguras |
| `klayout_gds/core_wrap.klayout.gds` | GDS stream-out pela trilha do KLayout, usado em verificação cruzada |
| `lef/core_wrap.lef` | vista física abstrata para instanciar o core como macro em um nível superior |
| `mag/core_wrap.mag` | banco de layout editável/lido pelo Magic |
| `mag_gds/core_wrap.magic.gds` | GDS stream-out pela trilha do Magic |
| `metrics.csv` | métricas em formato tabular |
| `metrics.json` | métricas estruturadas para scripts e auditoria por canto |
| `nl/core_wrap.nl.v` | netlist Verilog física/lógica sem pinos explícitos de alimentação |
| `odb/core_wrap.odb` | banco completo do OpenROAD para depuração ou continuação do PnR |
| `pnl/core_wrap.pnl.v` | netlist Verilog com `VPWR` e `VGND`, usada no caminho de LVS/power-aware |
| `render/core_wrap.png` | imagem automática de consulta rápida; não é dado de fabricação |
| `sdc/core_wrap.sdc` | constraints finais de timing, incluindo clock propagado e delays de I/O |
| `spice/core_wrap.spice` | netlist SPICE de conectividade usada na verificação física/LVS |
| `vh/core_wrap.vh` | modelo abstrato Verilog da interface externa, com power pins condicionais |

O `core_wrap.vh` confirmou a interface entregue: clock/reset, interrupções,
debug, controle de fetch, duas interfaces OBI (`instr_*` e `data_*`) e
`core_busy_o`. O SDC final contém clock de 50 ns, transição de 0,15 ns,
incerteza de 0,25 ns e delays de I/O de 5 ns.

Estado do passo 14: **concluído para a execução 2**. Próximo passo didático:
**15 — localizar nos relatórios as redes que violam slew, capacitância e
fanout**, em vez de trabalhar somente com as contagens agregadas.

### 15 — Análise das violações elétricas

Foi analisado o relatório do pior canto, `max_ss_100C_1v60`. Em cada tabela,
`Slack = Limit - valor medido`; portanto, slack negativo representa violação.

| Checagem | Limite | Pior valor | Pior slack | Total |
| --- | ---: | ---: | ---: | ---: |
| Slew | 0,750 ns | 2,301 ns | -1,551 ns | 5.090 |
| Fanout | 10 cargas | 12 cargas | -2 cargas | 8 |
| Capacitância | 0,094309 | 0,146654 | -0,052345 | 60 |

Slew é o tempo de subida/descida do sinal; capacitância é a carga elétrica
vista pelo driver; fanout é a quantidade de entradas alimentadas por ele. Eles
são limites elétricos locais e continuam válidos mesmo com clock lento de
20 MHz. Por isso setup e hold podem passar enquanto essas três checagens falham.

Os maiores problemas de slew e capacitância incluem buffers inseridos pelo
fluxo com nomes `fanout*`. O caminho de `fanout1632` foi rastreado na netlist:
ele é uma célula `sky130_fd_sc_hd__clkdlybuf4s25_1`, recebe `_02146_` e dirige
`net1632`. Entre suas cargas estão células ligadas a
`i_core.register_file_i.rf_reg[...]`. Assim, os piores pontos observados
envolvem a rede de leitura/multiplexação do register file implementado em
flip-flops; não são exclusivamente a árvore de clock.

Na checagem de fanout, dois dos oito drivers são folhas da CTS
(`clkbuf_leaf_112_clk_i` e `clkbuf_leaf_17_clk_i`); os demais pertencem a redes
funcionais ou buffers de reparo. `Found 0 partially unannotated drivers` indica
que o relatório não encontrou drivers apenas parcialmente anotados com os
parasitismos considerados.

Essa análise ainda não autoriza alterar o RTL do CVE2 nem relaxar os limites da
biblioteca. O próximo diagnóstico deve separar register file, clock e demais
redes, verificar a estratégia de buffering/sizing e validar se as constraints
de interface representam a futura integração.

Estado do passo 15: **concluído para a execução 2; causa física parcialmente
localizada, correção ainda não aplicada**.

### 16 — Rastreamento de `net1632` na netlist

A netlist com power pins mostrou a seguinte cadeia:

```text
_02146_ -> fanout1632/A
fanout1632/X -> net1632
net1632 -> entradas A2 de lógica do register file
        -> fanout1630/A e fanout1631/A
```

`fanout1632` é uma célula `sky130_fd_sc_hd__clkdlybuf4s25_1` inserida pelo
fluxo. Apesar de o nome da célula conter `clk`, essa instância não pertence
automaticamente à árvore de clock: aqui ela conduz uma rede funcional. As
cargas diretamente mostradas incluem sete portas `A2` das células `_08713_`,
`_08902_`, `_08961_`, `_09028_`, `_09211_`, `_09276_` e `_09335_`, além dos
dois buffers de ramificação `fanout1630` e `fanout1631`.

Isso também demonstra por que fanout e capacitância não são equivalentes. A
rede tem nove cargas diretas — abaixo do limite de fanout 10 — mas
`fanout1632/X` ainda viola capacitância e slew por causa da soma das
capacitâncias de entrada e da interconexão física.

Os nomes `i_core.register_file_i.rf_reg[85]`, `[88]` etc. são índices de bits
do array do register file depois do achatamento da hierarquia. Eles não
representam registradores arquiteturais RISC-V `x85`, que não existe em RV32.
As células `a22o`/`a221o` combinam esses bits para formar a leitura do banco.

Estado do passo 16: **concluído para a execução 2; uma ramificação crítica do
register file foi rastreada do buffer às cargas**. O próximo passo é rastrear
o driver lógico `_02146_` e suas entradas para completar o caminho a montante.

### 17 — Driver lógico de `_02146_`

A netlist mostrou que `_02146_` é produzido por `_07427_`, uma célula
`sky130_fd_sc_hd__and2b_2`:

```text
_02146_ = (~net1908) & net1892
```

O sufixo `b` e a porta `A_N` indicam que a primeira entrada é invertida; a
segunda entra diretamente. A célula seguinte `_07428_` aparece no trecho
apenas porque é vizinha no arquivo: ela não dirige `_02146_`.

Esse resultado mostra que `fanout1632` recebe um termo de decodificação
combinacional, não clock. Ainda é necessário rastrear os drivers de `net1908`
e `net1892` para recuperar os sinais funcionais anteriores aos buffers
inseridos pelo fluxo.

Estado do passo 17: **concluído para a execução 2**.

### 18 — Primeira camada das árvores de buffer

Os drivers encontrados foram:

```text
net1911 -> fanout1908 -> net1908
net1900 -> fanout1892 -> net1892
```

As duas instâncias são `sky130_fd_sc_hd__clkdlybuf4s25_1`, buffers não
inversores inseridos pelo fluxo para distribuir carga. Logo, a função booleana
vista por `_07427_` continua equivalente a `(~net1911) & net1900`; os buffers
alteram características elétricas e atraso, não o valor lógico.

`fanout1911`, mostrado logo depois no arquivo, é o provável estágio anterior
da primeira árvore. `fanout1894` compartilha `net1900` como entrada e cria outra
ramificação; ele não é o driver de `net1892`. Os nomes `fanout*` e `net*` foram
gerados durante síntese/PnR e não são nomes originais do RTL.

Estado do passo 18: **concluído para a execução 2; ainda dentro de buffers
físicos, sem alcançar os sinais funcionais de origem**.

### 19 — Segunda camada das árvores de buffer

O rastreamento avançou para:

```text
net1915 -> fanout1911 -> net1911 -> fanout1908 -> net1908
net1899 -> wire1900   -> net1900 -> fanout1892 -> net1892
```

`fanout1911` é outro `clkdlybuf4s25_1`. `wire1900` é um `clkbuf_4` inserido
como reparo de interconexão; o prefixo `wire` indica o propósito atribuído pelo
fluxo, não um sinal originalmente chamado assim no RTL. Ambos são não
inversores.

Consequentemente, a função continua equivalente a
`(~net1915) & net1899`. A primeira ramificação ainda passa por `fanout1915` e
a segunda já aponta para `net1899`; o próximo rastreamento deve alcançar os
sinais hierárquicos originais.

Estado do passo 19: **concluído para a execução 2**.

### 20 — Origem funcional recuperada no RTL

O fim das duas árvores revelou:

```text
instr_i[20] -> fanout1918 -> net1918 -> fanout1915 -> net1915
             -> fanout1911 -> net1911 -> fanout1908 -> net1908

instr_i[21] -> fanout1899 -> net1899 -> wire1900 -> net1900
             -> fanout1892 -> net1892
```

Como todos os elementos intermediários são não inversores, a equação de
`_07427_` pode finalmente ser escrita em termos do RTL:

```text
_02146_ = (~instr_i[20]) & instr_i[21]
```

No decoder do CVE2, `instr_rs2 = instr[24:20]` e esse campo alimenta o endereço
da porta B do register file. Portanto, `instr_i[20]` e `[21]` são os dois bits
menos significativos de `rs2`; o termo rastreado participa da seleção dos dados
lidos do segundo registrador-fonte. Ele não representa uma função criada
acidentalmente pelo PnR.

O grande espalhamento desse campo por um register file implementado em
flip-flops/multiplexadores explica por que o fluxo criou vários níveis de
buffers. A evidência localiza uma origem arquitetural plausível para parte das
violações, mas não demonstra erro funcional no CVE2 e não explica sozinha as
5.090 violações de slew.

Estado do passo 20: **concluído para a execução 2; caminho rastreado do RTL às
cargas físicas**. O próximo trabalho deve deixar de seguir essa rede e passar a
avaliar correções de implementação física controladas.

### 21 — Distribuição das violações de slew por classe de instância

As 5.090 violações do canto `max_ss_100C_1v60` foram agrupadas pelo prefixo do
nome da instância:

| Classe aproximada | Violações | Participação |
| --- | ---: | ---: |
| Buffers `fanout*` | 928 | 18,23% |
| Buffers `clkbuf*` | 0 | 0,00% |
| Buffers `input*` | 24 | 0,47% |
| Lógica/células comuns | 4.138 | 81,30% |
| Total | 5.090 | 100,00% |

A classificação por prefixo é apenas uma primeira aproximação: uma célula do
tipo clock buffer pode ter sido nomeada `fanout*` ou `wire*` quando empregada
como buffer funcional. Mesmo assim, o resultado mostra que o problema não pode
ser resolvido olhando apenas para os 928 buffers `fanout*`; 81,3% dos pinos
violadores pertencem a instâncias de lógica com nomes genéricos.

O próximo diagnóstico deve correlacionar cada instância com seu **tipo de
célula SKY130**. Isso permitirá separar multiplexadores, portas complexas,
flip-flops e diferentes buffers antes de escolher sizing ou buffering.

Estado do passo 21: **concluído para a execução 2; slew identificado como
problema distribuído na lógica mapeada**.

### 22 — Distribuição por tipo de célula SKY130

Os vinte tipos mais frequentes concentram 4.483 das 5.090 ocorrências
(88,07%). Os quatro primeiros, sozinhos, somam 2.669 (52,44%):

| Tipo de célula | Ocorrências | Participação |
| --- | ---: | ---: |
| `clkdlybuf4s25_1` | 955 | 18,76% |
| `mux2_1` | 690 | 13,56% |
| `a22o_2` | 610 | 11,98% |
| `a221o_2` | 414 | 8,13% |

Depois aparecem outras portas AND-OR/OR-AND, multiplexadores e lógica básica.
Somente 61 ocorrências pertencem a `dfrtp_2`, indicando que flip-flops não são
o grupo dominante na lista. A combinação de `mux2`, `mux4`, `a22o` e `a221o`
é coerente com redes de seleção como as observadas no register file, embora
essas células também possam existir em outras partes do core.

As 955 ocorrências de `clkdlybuf4s25_1` serem maiores que as 928 instâncias
nomeadas `fanout*` confirmam que nome da instância e tipo de célula são
classificações diferentes: esse master também aparece sob nomes `input*`,
`wire*` ou outros.

Uma ocorrência nessa tabela significa que um **pino** daquela célula violou
slew. Se o pino for uma entrada, a transição lenta veio da rede/driver anterior;
isso não prova que trocar a célula de carga resolveria o problema. O próximo
passo deve agrupar as violações pelo nome do pino (`A`, `S`, `X`, `Y`, etc.)
para distinguir cargas de saídas que efetivamente dirigem redes.

Estado do passo 22: **concluído para a execução 2; concentração em buffers e
lógica de seleção confirmada, mas os drivers ainda precisam ser isolados**.

### 23 — Pinos de carga versus pinos de saída

A distribuição pelos nomes dos pinos somou novamente as 5.090 ocorrências. Os
mais frequentes foram `A` (968), `A1` (692), `A2` (688), `X` (585), `B1`
(480), `S` (434) e `B` (276).

Considerando `X`, `Y` e `Q` como saídas nos masters presentes:

| Classe de pino | Ocorrências | Participação |
| --- | ---: | ---: |
| Saídas `X`/`Y`/`Q` | 633 | 12,44% |
| Entradas e demais pinos de carga | 4.457 | 87,56% |
| Total | 5.090 | 100,00% |

Foram afetadas 3.977 instâncias distintas. Portanto, 5.090 não significa
5.090 drivers ou redes independentes: a mesma transição lenta pode ser
reportada na saída do driver e em várias entradas receptoras ao longo da rede.

Esse resultado muda o foco do diagnóstico. Multiplexadores e portas complexas
aparecem muito porque seus pinos de entrada recebem sinais lentos; não se deve
redimensionar todas essas cargas sem antes classificar as 633 saídas
violadoras. O próximo passo correlacionará somente `X`/`Y`/`Q` com os masters
SKY130 que efetivamente dirigem as redes.

Estado do passo 23: **concluído para a execução 2; a maior parte da contagem
foi identificada como observações em cargas, não como drivers distintos**.

### 24 — Tipos das células que efetivamente dirigem redes lentas

Das 633 ocorrências em saídas `X`/`Y`/`Q`, 508 pertencem a
`sky130_fd_sc_hd__clkdlybuf4s25_1`: **80,25% dos drivers listados**. Os 125
restantes estão dispersos entre portas combinacionais e sete flip-flops.

Uma inspeção completa da netlist encontrou 1.564 instâncias desse master:

| Prefixo atribuído pelo fluxo | Quantidade |
| --- | ---: |
| `fanout*` | 1.368 |
| `input*` | 95 |
| `output*` | 100 |
| `wire*` | 1 |
| Total | 1.564 |

Isso associa a maioria desses buffers a reparos de fanout e interface. Eles não
são os 1.437 buffers de hold observados no passo 9: os buffers de hold usam o
master separado `sky130_fd_sc_hd__dlygate4sd3_1`. Portanto, substituir ou
redimensionar células de hold não é a hipótese principal para essas 508 saídas.

A evidência aponta a seleção/uso de `clkdlybuf4s25_1` nas árvores de dados como
o primeiro alvo de investigação física. Ainda não se deve substituir células
manualmente na netlist: é preciso verificar as opções resolvidas de repair,
buffering, slew e capacitância e então criar um run comparativo reproduzível.

Estado do passo 24: **concluído para a execução 2; 80,25% dos drivers de slew
foram concentrados em um único master de buffer**.

### 25 — Configuração efetivamente resolvida pelo LibreLane

O `resolved.json` registrou os valores realmente usados, incluindo defaults do
PDK e do fluxo:

| Variável | Valor | Interpretação |
| --- | ---: | --- |
| `MAX_FANOUT_CONSTRAINT` | 10 | coincide com o limite visto no relatório |
| `MAX_TRANSITION_CONSTRAINT` | 0,75 ns | coincide com o limite global de slew |
| `MAX_CAPACITANCE_CONSTRAINT` | 0,2 | limite global para síntese/CTS; saídas podem ter limite Liberty mais restritivo |
| `SYNTH_BUFFER_CELL` | `buf_2/A/X` | buffer da síntese, não obriga os reparos de PnR a usar somente esse master |
| `PL_TIMING_DRIVEN` | `false` | placement global priorizou roteabilidade, não timing |
| `DESIGN_REPAIR_MAX_SLEW_PCT` | 20 | margem de slew do repair pós-placement |
| `DESIGN_REPAIR_MAX_CAP_PCT` | 20 | margem de capacitância do repair pós-placement |
| `GRT_DESIGN_REPAIR_MAX_SLEW_PCT` | 10 | margem de slew do repair pós-global-routing |
| `GRT_DESIGN_REPAIR_MAX_CAP_PCT` | 10 | margem de capacitância do repair pós-global-routing |

O limite de capacitância de 0,094309 visto em `fanout1632/X` não contradiz o
valor global 0,2: a caracterização Liberty da célula/saída pode impor um limite
efetivo menor. Também fica demonstrado que alterar apenas
`SYNTH_BUFFER_CELL` não explica nem controla os 1.564 `clkdlybuf4s25_1`, pois
eles foram introduzidos/selecionados em estágios físicos posteriores.

A documentação oficial do LibreLane define os percentuais acima como margens
dos reparos e recomenda aumentá-los como uma das alternativas para max
slew/cap. `PL_TIMING_DRIVEN` habilita placement orientado por timing. Essas
opções devem ser avaliadas em runs separados para que seja possível atribuir o
efeito de cada mudança:

`https://librelane.readthedocs.io/en/latest/reference/step_config_vars.html`

Estado do passo 25: **concluído para a execução 2; baseline resolvida e
hipóteses de tuning identificadas, sem alteração da configuração principal**.

### Encerramento do pipe-clean físico

O estudo para neste ponto. Os passos 15 a 25 investigaram as violações para que
elas pudessem ser relatadas com causa provável, não para transformar este
laboratório em uma atividade de timing closure. A variante de margem sugerida
durante a exploração **não faz parte do pipe-clean e não deve ser executada
agora**.

Resultado a preservar: `core_wrap` é `CANDIDATE` no fluxo físico SKY130A, com
GDSII, DRC, LVS, antena, setup e hold aprovados; slew, capacitância, fanout,
IR drop e equivalência continuam abertos. A qualificação funcional do Croc
permanece `BLOCKED` pelo smoke sem término determinístico. A próxima atividade
de qualificação deve retornar ao smoke funcional, não otimizar o layout.

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

Estado histórico: `Flow complete` registrado em 2 min 24 s. O run emitiu os
mesmos 316 warnings de lint e `ORD-0032` (`Invalid thread number`) no Floorplan.
Como o fluxo terminou, o aviso não bloqueou esse gate. Uma tentativa posterior
de correção adicionou `OPENROAD_THREADS: 8`, mas esta chave não pertence ao
schema da instalação atual e impediu o carregamento do YAML; ela foi removida.
Se `ORD-0032` reaparecer, a correção deverá usar somente uma variável suportada
pelo estágio e pela versão em execução. Ainda faltam as métricas de posição de
pinos.

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

Estado histórico: `Flow complete` registrado em 2 min 23 s. O resumo final
repetiu apenas os 316 warnings de lint e `ORD-0032` não reapareceu. Isso não
comprova que a chave inválida `OPENROAD_THREADS` tenha causado a mudança; essa
atribuição anterior foi retirada. Ainda faltam os relatórios de continuidade
de alimentação, tapcells/endcaps e erros da grade.

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
