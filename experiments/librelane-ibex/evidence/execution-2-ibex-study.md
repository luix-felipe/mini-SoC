# Execução 2 — reexecução didática do Ibex

Data de início: 2026-09-20  
Origem: execução incremental pelo operador no ambiente UNIC-CASS.  
Status: **CANDIDATE; pipe-clean funcional e físico concluído, sem signoff
elétrico**.

## Objetivo

Reproduzir a qualificação funcional e o fluxo RTL até GDSII do Ibex isolado,
preservando prints dos logs e evidências próprias. Esta execução usa tags novas
para não sobrescrever os runs anteriores.

## Baseline confirmada no passo 1

- Ibex esperado: commit `8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2`;
- top físico: `chipus_ibex_wrapper`;
- configuração do core: `small`;
- PDK/biblioteca: `sky130A` / `sky130_fd_sc_hd`;
- clock: 50 ns (20 MHz);
- configuração LibreLane: `experiments/librelane-ibex/config.yaml`;
- tag final reservada: `ibex-study2-full`.

## Convenção para as capturas

Em cada passo, guardar uma captura que mostre o comando, `Flow complete` ou a
mensagem `PASS`, warnings relevantes e o código de saída. Nos passos medidos,
incluir também `Elapsed`, `Maximum resident set size`, `Swaps` e `Exit status`.
Os runs completos permanecem em `runs/` e não são versionados; este arquivo
preserva o resumo textual reproduzível.

## Roteiro e registro

| Passo | Título | Comando/ação principal | Estado |
| ---: | --- | --- | --- |
| 1 | Identificação do ambiente | `make -C pipe-clean show` e versões | PASS |
| 2 | Compilação do core | `make -C pipe-clean ibex-core` | PASS |
| 3 | Smoke funcional | `make -C pipe-clean ibex-smoke` | PASS |
| 4 | Elaboração do wrapper | `make -C pipe-clean ibex-wrapper` | PASS |
| 5 | Preparação das fontes | `make -C pipe-clean librelane-prepare` | PASS |
| 6 | Frontend e lint | até `Yosys.JSONHeader` | PASS |
| 7 | Síntese | até `Yosys.Synthesis` | PASS |
| 8 | STA pré-PnR | até `OpenROAD.STAPrePNR` | PASS (execução) |
| 9 | Floorplan | até `OpenROAD.Floorplan` | PASS (execução) |
| 10 | Rede de alimentação | até `OpenROAD.GeneratePDN` | PASS (execução) |
| 11 | Placement global | até `OpenROAD.GlobalPlacement` | PASS (com warning) |
| 12 | Placement detalhado | até `OpenROAD.DetailedPlacement` | PASS (com warnings) |
| 13 | Árvore de clock | até `OpenROAD.CTS` | PASS (com warnings) |
| 14 | STA pós-CTS | até `OpenROAD.STAMidPNR-2` | PASS (execução) |
| 15 | Roteamento global | até `OpenROAD.GlobalRouting` | PASS (execução) |
| 16 | Roteamento detalhado | até `OpenROAD.DetailedRouting` | PASS (com warnings) |
| 17 | Fluxo completo | run `ibex-study2-full` | PASS de fluxo; sem signoff |
| 18 | Inspeção no KLayout | abrir o GDSII final | PASS |
| 19 | Inventário final | listar vistas de `final/` | PASS |
| 20 | Métricas e checkers | consolidar DRC/LVS/antena e recursos | PASS |
| 21 | Setup final | localizar cantos e caminhos críticos | FAIL em 2 cantos |
| 22 | Hold final | localizar cantos e caminhos críticos | PASS em 9 cantos |
| 23 | Slew/cap/fanout | contar e classificar violações | FAIL |
| 24 | Rastreio físico | relacionar redes, drivers e células | concluído |
| 25 | Fechamento do pipe-clean | conclusão, limitações e atualização do plano | PASS |

### Passo 1 — Identificação do ambiente

Executar na raiz de `mini-SoC`, dentro do UNIC-CASS:

```bash
make -C pipe-clean show
echo "PDK=$PDK"
echo "PDK_ROOT=$PDK_ROOT"
ls -ld "$PDK_ROOT/$PDK"
LL=/home/designer/shared/bin/librelane-local
"$LL" --version
yosys -V
openroad -version
verilator --version
```

Objetivo: provar caminhos, revisões e versões antes de qualquer compilação. O
passo só passa se os clones Ibex/Croc forem encontrados, o commit do Ibex for
identificado e `PDK=sky130A` apontar para um PDK acessível.

Resultado recebido:

```text
Ibex commit: 8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2
Croc commit: 968bab17b37e88d9200a0899cb9181e42850ec87
PDK=sky130A
PDK_ROOT=/opt/pdks
/opt/pdks/sky130A ->
  volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/
LibreLane v3.0.0rc1
Yosys 0.44 (git sha1 80ba43d26)
OpenROAD v2.0-25787-gee9759486
Verilator 5.026 2024-06-15 rev v5.026
```

Conclusão: **PASS**. Os clones foram localizados, a revisão esperada do Ibex foi
confirmada e o link `sky130A` aponta para uma instalação Volare identificável.
As quatro ferramentas responderam corretamente. A versão exibida por `yosys -V`
é a encontrada no terminal; o fluxo LibreLane ainda pode usar outra versão em
seu ambiente interno.

### Passos 2 a 5 — qualificação e preparação

Serão executados um por vez, após a confirmação do passo anterior:

```bash
make -C pipe-clean ibex-core
make -C pipe-clean ibex-smoke
make -C pipe-clean ibex-wrapper
make -C pipe-clean librelane-prepare
```

Eles verificam, respectivamente: elaboração do core; execução de firmware até
o halt; elaboração do wrapper físico; e geração da lista ordenada de fontes.
Nenhum deles produz layout.

#### Resultado do passo 2

```text
Verilator 5.026
Built from 74.928 MB sources in 144 modules
Walltime: 0.411 s
[PASS] IBEX_RTL_COMPILE: ibex_top elaborado com Verilator
Ibex revision: 8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2
FuseSoC version: 2.4.3
```

Conclusão: **PASS**. O FuseSoC resolveu a hierarquia e o Verilator elaborou o
`ibex_top` sem erro. Isso prova integridade de fontes, dependências, parâmetros
e conexões necessárias à elaboração; não executa instruções nem prova
funcionalidade. O backend antigo do Edalize emitiu aviso de depreciação, que é
uma pendência de infraestrutura e não um erro do RTL.

#### Tentativa do passo 3 dentro do UNIC-CASS

```text
[ERRO] ibex-smoke instala toolchain e libelf no contêiner efêmero.
       Execute este alvo no terminal WSL, fora do UNIC-CASS.
Error 2
```

Classificação da tentativa: **bloqueio de ambiente, não falha do core**. O alvo
interrompeu antes da compilação do firmware e da simulação. Em seguida, o teste
foi repetido no terminal WSL, de onde o Make iniciou o contêiner efêmero.

#### Resultado do passo 3 no WSL

```text
Tool verilator present: 5.026 (mínimo 4.210)
Tool edalize present: 0.6.8 (mínimo 0.2.0)
[PASS] IBEX_SIMPLE_SYSTEM_SMOKE: firmware executado ate o halt
Terminating simulation by software request.
Executed cycles: 13268
Cycles: 477
Instructions Retired: 261
Hello simple system
```

Conclusão: **PASS**. O firmware foi compilado, executado pelo Ibex e terminou de
forma determinística por solicitação do software. `Executed cycles` é o tempo
total observado pelo modelo de simulação; `Cycles` é o contador lido/reportado
pelo programa, por isso os valores não representam a mesma janela. O aviso de
backend Edalize obsoleto permanece uma pendência de infraestrutura.

#### Resultado do passo 4

```text
Verilator 5.026
Built from 76.437 MB sources in 145 modules
Walltime: 0.429 s
[PASS] IBEX_RTL_COMPILE: chipus_ibex_wrapper elaborado com Verilator
Ibex revision: 8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2
FuseSoC version: 2.4.3
```

Conclusão: **PASS**. O wrapper físico, seus parâmetros e suas conexões com
`ibex_top` foram elaborados sem erro. A hierarquia contém um módulo a mais que a
compilação isolada do core (145 contra 144). O teste não sintetiza o design nem
exercita transações nas interfaces expostas pelo wrapper.

#### Resultado do passo 5

```text
[PASS] 141 fontes RTL ordenadas e 53 includes Ibex preparados em
/home/designer/shared/chipus-soc/mini-SoC/flow/src
```

Conclusão: **PASS**. O script gerou a cópia ordenada das fontes e includes que
será consumida pelo LibreLane. Esse diretório é material intermediário e não
substitui o clone upstream rastreado pelo commit. O aviso do backend Edalize
obsoleto permanece relacionado à preparação via FuseSoC.

### Passos 6 a 17 — implementação física

Antes desses passos:

```bash
LL=/home/designer/shared/bin/librelane-local
```

As tags reservadas são:

```text
ibex-study2-frontend
ibex-study2-synth
ibex-study2-sta-prepnr
ibex-study2-floorplan
ibex-study2-pdn
ibex-study2-global-placement
ibex-study2-detailed-placement
ibex-study2-cts
ibex-study2-postcts
ibex-study2-global-routing
ibex-study2-detailed-routing
ibex-study2-full
```

O formato dos passos incrementais será:

```bash
/usr/bin/time -v "$LL" \
  --run-tag TAG_NOVA \
  --to ESTAGIO_LIBRELANE \
  experiments/librelane-ibex/config.yaml
```

No passo 17, omitir `--to` para executar até os checkers finais. Os comandos
exatos serão apresentados um por vez para reduzir risco de pressão de memória.

#### Resultado do passo 6

```text
Tag: ibex-study2-frontend
Destino: Yosys.JSONHeader
Flow complete: 3 s
Lint warnings: 134
Tempo de parede: 0:04.66
CPU: 122%
Pico RSS: 123064 KiB
Swaps: 0
Exit status: 0
```

Conclusão: **PASS**. O frontend leu e elaborou o conjunto de fontes e produziu
o JSON inicial sem erro. A contagem de 134 warnings reproduz a execução 1, mas
warnings ainda precisam ser classificados; saída zero não os converte em prova
de qualidade funcional. A indicação `80/80` inclui etapas puladas por `--to` e
não representa conclusão do fluxo físico.

#### Resultado do passo 7

```text
Tag: ibex-study2-synth
Destino: Yosys.Synthesis
Flow complete: 1 min 57 s
Lint warnings: 134
Tempo de parede: 1:57.92
CPU: 105%
Pico RSS: 883884 KiB
Swaps: 0
Exit status: 0
```

Conclusão: **PASS**. A síntese terminou sem erro e sem swap. Isso demonstra que
o RTL foi aceito e mapeado pelo fluxo, mas o trecho final recebido não contém as
contagens de células/área; esses valores serão obtidos dos artefatos da própria
tag no passo 20. Ainda não há prova de timing ou roteabilidade.

#### Resultado do passo 8

```text
Tag: ibex-study2-sta-prepnr
Destino: OpenROAD.STAPrePNR
Flow complete: 2 min 21 s
Lint warnings: 134
Tempo de parede: 2:22.35
CPU: 150%
Pico RSS: 883956 KiB
Swaps: 0
Exit status: 0
```

Conclusão da execução: **PASS**. A STA pré-PnR terminou sem erro de ferramenta.
O resumo recebido não exibe os slacks nem as contagens de slew, capacitância e
fanout; portanto, este registro ainda não afirma fechamento de timing. Esses
dados serão extraídos dos relatórios próprios do run nos passos 20 a 23.

#### Resultado do passo 9

```text
Tag: ibex-study2-floorplan
Destino: OpenROAD.Floorplan
Flow complete: 2 min 26 s
Lint warnings: 134
Tempo de parede: 2:27.30
CPU: 149%
Pico RSS: 883964 KiB
Swaps: 0
Exit status: 0
```

Conclusão da execução: **PASS**. O banco físico inicial foi criado sem erro de
ferramenta. O trecho final não contém dimensões, utilização, rows ou sites;
esses números serão lidos dos artefatos do run no passo 20. Ainda não há
placement definitivo nem roteamento.

#### Resultado do passo 10

```text
Tag: ibex-study2-pdn
Destino: OpenROAD.GeneratePDN
Flow complete: 2 min 33 s
Lint warnings: 134
Tempo de parede: 2:33.99
CPU: 147%
Pico RSS: 884208 KiB
Swaps: 0
Exit status: 0
```

Conclusão da execução: **PASS**. A geração da rede de alimentação terminou sem
erro de ferramenta. Como o resumo recebido não mostra as mensagens de
continuidade, tapcells ou endcaps, esses detalhes serão confirmados nos logs e
métricas próprios do run. Este passo, isoladamente, não qualifica IR drop.

#### Resultado do passo 11

```text
Tag: ibex-study2-global-placement
Destino: OpenROAD.GlobalPlacement
Flow complete: 2 min 34 s
Lint warnings: 134
GRT-0281: rst_ni possui fanout de 1674 terminais; uma rede semelhante
Tempo de parede: 2:34.62
CPU: 140%
Pico RSS: 883636 KiB
Swaps: 0
Exit status: 0
```

Conclusão da execução: **PASS com warning**. As células foram distribuídas pelo
placement global. O alto fanout de `rst_ni` e de outra rede ainda não nomeada no
resumo exige buffers/tratamento físico, mas não demonstra erro funcional no
core. Congestionamento e overflow serão confirmados nos relatórios do run.

#### Resultado do passo 12

```text
Tag: ibex-study2-detailed-placement
Destino: OpenROAD.DetailedPlacement
Flow complete: 3 min 23 s
Lint warnings: 134
GRT-0281: rst_ni com fanout de 1674 terminais; uma rede semelhante
STA-1140: biblioteca Liberty já existente; 5 avisos semelhantes
RSZ-0020: 2 redes flutuantes
Tempo de parede: 3:24.10
CPU: 131%
Pico RSS: 883704 KiB
Swaps: 0
Exit status: 0
```

Conclusão da execução: **PASS com warnings**. O placement detalhado e a
legalização terminaram sem erro. `STA-1140` registra recarga da Liberty, não
duplicação do RTL. As duas redes indicadas por `RSZ-0020` ainda precisam ser
identificadas nos logs antes de serem classificadas. O trecho final não informa
quantos buffers ou redimensionamentos foram inseridos.

#### Resultado do passo 13

```text
Tag: ibex-study2-cts
Destino: OpenROAD.CTS
Flow complete: 3 min 44 s
Lint warnings: 134
GRT-0281: rst_ni com fanout de 1674 terminais; uma rede semelhante
STA-1140: biblioteca Liberty já existente; 11 avisos semelhantes
RSZ-0020: 2 redes flutuantes
Tempo de parede: 3:45.31
CPU: 126%
Pico RSS: 884172 KiB
Swaps: 0
Exit status: 0
```

Conclusão da execução: **PASS com warnings**. A árvore física de clock foi
construída sem erro de ferramenta. Sinks, buffers, inversores, latência e skew
não aparecem no resumo recebido e serão extraídos dos relatórios da tag. A
conclusão do CTS não implica fechamento de setup/hold.

#### Resultado do passo 14

```text
Tag: ibex-study2-postcts
Destino: OpenROAD.STAMidPNR-2
Flow complete: 5 min 19 s
Lint warnings: 134
GRT-0281: rst_ni com fanout de 1674 terminais; uma rede semelhante
STA-1140: biblioteca Liberty já existente; 17 avisos semelhantes
RSZ-0020: 2 redes flutuantes
Tempo de parede: 5:20.01
CPU: 119%
Pico RSS: 884240 KiB
Swaps: 0
Exit status: 0
```

Conclusão da execução: **PASS**. A sequência de análise e reparos pós-CTS
terminou sem erro de ferramenta. O resumo não contém slacks, violações
elétricas ou quantidade de buffers de hold, portanto fechamento de timing não
é afirmado neste ponto. A validação final depende do roteamento e RCX.

#### Resultado do passo 15

```text
Tag: ibex-study2-global-routing
Destino: OpenROAD.GlobalRouting
Flow complete: 5 min 23 s
Lint warnings: 134
GRT-0281: rst_ni com fanout de 1674 terminais; uma rede semelhante
STA-1140: biblioteca Liberty já existente; 17 avisos semelhantes
RSZ-0020: 2 redes flutuantes
Tempo de parede: 5:24.35
CPU: 119%
Pico RSS: 883820 KiB
Swaps: 0
Exit status: 0
```

Conclusão da execução: **PASS**. O roteamento global terminou sem erro de
ferramenta. O resumo recebido não informa overflow, uso por camada, comprimento
de fios ou vias; esses dados serão confirmados nos relatórios da tag. Ainda não
há geometria final nem DRC independente.

#### Resultado do passo 16

```text
Tag: ibex-study2-detailed-routing
Destino: OpenROAD.DetailedRouting
Flow complete: 19 min 45 s
Lint warnings: 134
GRT-0281: rst_ni com fanout de 1674 terminais; uma rede semelhante
STA-1140: biblioteca Liberty já existente; 17 avisos semelhantes
RSZ-0020: 2 redes flutuantes
GRT-0243: falha ao reparar antena com diodos; 2 avisos semelhantes
DRT-0349: LEF58_ENCLOSURE sem CUTCLASS ignorada em mcon; 9 avisos semelhantes
Tempo de parede: 25:13.12
CPU: 218%
Pico RSS: 2294696 KiB
Swaps: 0
Exit status: 0
```

Conclusão da execução: **PASS com warnings**. A geometria detalhada foi gerada
sem erro fatal. `GRT-0243` descreve tentativas de reparo de antena que falharam
naquele ponto e não permite concluir o resultado final de antena. `DRT-0349`
registra uma regra LEF58 não suportada pelo roteador; os DRCs independentes do
run completo serão necessários. O alto uso de CPU explica a diferença entre
tempo de usuário e tempo de parede; não houve swap.

#### Resultado do passo 17

```text
Tag: ibex-study2-full
Final result: Circuits match uniquely.
Antenna: Passed
LVS: Passed
DRC: Passed
Flow complete: 28 min 03 s
Tempo de parede: 29:20.94
CPU: 234%
Pico RSS: 2278200 KiB
Swaps: 0
Exit status: 0
```

| Checker final | Resultado desta execução |
| --- | --- |
| Setup | violações em `max_ss_100C_1v60` e `nom_ss_100C_1v60` |
| Hold | nenhuma violação reportada |
| Slew máximo | violações nos nove cantos analisados |
| Capacitância máxima | violações em cinco cantos: `max_ss`, `max_tt`, `min_ss`, `nom_ss` e `nom_tt` |
| Antena | aprovado |
| LVS | aprovado; circuitos correspondem unicamente |
| DRC | aprovado |

Conclusão: **fluxo completo executado, GDSII gerado, sem signoff elétrico**.
DRC, LVS e antena passaram, mas setup, slew e capacitância permanecem abertos.
Hold passou nos nove cantos reportados. `Yosys.EQY` foi pulado, o checker de
fios longos não tinha limiar e a análise de IR drop não está qualificada sem
`VSRC_LOC_FILES`. Sete saídas do wrapper não possuem informação de difusão para
antena e podem estar sem driver. Os avisos intermediários `GRT-0243` não se
converteram em falha no checker final de antena; `DRT-0349` deve permanecer
documentado apesar da aprovação dos DRCs executados.

#### Resultado do passo 18

O operador abriu `final/gds/chipus_ibex_wrapper.gds` no KLayout 0.30.5. A
captura recebida confirma a célula superior `chipus_ibex_wrapper`, o contorno
retangular do die, linhas de standard cells, malha/roteamento e pinos externos
nas bordas. Estão visíveis grupos `instr_*`, `data_*` e sinais de
alerta/controle, coerentes com as interfaces expostas pelo wrapper.

Conclusão: **PASS** para abertura e inspeção visual. A imagem não permite
classificar cada geometria isoladamente e não substitui os resultados de DRC,
LVS ou antena produzidos pelas ferramentas.

#### Resultado do passo 19

O diretório `final/` contém as vistas esperadas:

| Vista | Artefato principal |
| --- | --- |
| DEF | `def/chipus_ibex_wrapper.def` |
| GDSII principal | `gds/chipus_ibex_wrapper.gds` |
| GDSII KLayout | `klayout_gds/chipus_ibex_wrapper.klayout.gds` |
| GDSII Magic | `mag_gds/chipus_ibex_wrapper.magic.gds` |
| LEF | `lef/chipus_ibex_wrapper.lef` |
| banco OpenROAD | `odb/chipus_ibex_wrapper.odb` |
| netlist lógica/física | `nl/` e `pnl/` |
| constraints finais | `sdc/chipus_ibex_wrapper.sdc` |
| SPICE | `spice/chipus_ibex_wrapper.spice` |
| métricas | `metrics.json` e `metrics.csv` |
| renderização | `render/chipus_ibex_wrapper.png` |

Conclusão: **PASS**. O run preservou os formatos necessários para inspeção,
integração hierárquica e análise física. A presença dos arquivos não prova, por
si só, que todas as verificações associadas passaram.

#### Resultado do passo 20

| Métrica | Valor |
| --- | ---: |
| instâncias totais, incluindo preenchimento | 61.791 |
| standard cells | 24.570 |
| área de standard cells | 209.193 µm² |
| macros | 0 |
| die | 750 × 750 µm |
| área do core | 536.517 µm² |
| utilização | 38,991% |
| rows / sites | 267 / 428.802 |
| comprimento roteado | 932.198 µm |
| vias | 137.387 |
| células não mapeadas | 0 |
| violações da grade de alimentação | 0 |
| DRC interno / Magic / KLayout | 0 / 0 / 0 |
| redes/pinos com violação de antena | 0 / 0 |
| erros LVS | 0 |
| diferenças XOR de layout | 0 |

Conclusão: **PASS para os checkers físicos registrados**. O bloco é composto
somente por standard cells, sem macro SRAM. A contagem total inclui células de
preenchimento; por isso não deve ser interpretada como 61.791 células lógicas.
A diferença XOR zero é uma comparação geométrica e não substitui a equivalência
formal RTL/netlist, que não foi executada.

#### Resultado do passo 21

| Canto | Pior slack | TNS | Caminhos violadores |
| --- | ---: | ---: | ---: |
| `max_ss_100C_1v60` | -1,816531 ns | -23,537308 ns | 35 |
| `nom_ss_100C_1v60` | -0,300858 ns | -0,300858 ns | 1 |
| outros sete cantos | positivo | 0 | 0 |

Conclusão: **FAIL de setup em dois dos nove cantos**. O pior canto é
`max_ss_100C_1v60`, com 35 caminhos e atraso total negativo acumulado de
23,537308 ns. `nom_ss` possui apenas um caminho violador. Os outros sete cantos
passam, mas isso não compensa as falhas nos cantos slow. Os endpoints e células
do pior caminho serão procurados no passo 24.

#### Resultado do passo 22

Todos os nove cantos apresentaram TNS igual a zero e contagem de violações de
hold igual a zero. As menores margens foram:

| Canto | Pior slack de hold |
| --- | ---: |
| `min_ff_n40C_1v95` | +0,106761 ns |
| `nom_ff_n40C_1v95` | +0,108926 ns |
| `max_ff_n40C_1v95` | +0,111626 ns |

Conclusão: **PASS de hold nos nove cantos**. O canto mais crítico é
`min_ff_n40C_1v95`, mas permanece com margem positiva. Esse resultado não anula
as falhas independentes de setup e limites elétricos.

#### Resultado do passo 23

| Verificação | Resultado |
| --- | --- |
| slew máximo | falhou nos 9 cantos; de 271 a 6.981 ocorrências |
| capacitância máxima | falhou em 5 cantos; de 1 a 71 ocorrências |
| fanout máximo | 18 ocorrências em cada um dos 9 cantos |

O pior canto para slew e capacitância é `max_ss_100C_1v60`, com 6.981 e 71
ocorrências. Capacitância também falha em `nom_tt` (1), `nom_ss` (53), `min_ss`
(38) e `max_tt` (1). Os quatro cantos FF/min-TT têm zero ocorrência de
capacitância, mas todos os cantos permanecem com slew e fanout.

Conclusão: **FAIL de limites elétricos**. As contagens mostram abrangência, não
o excesso individual de cada rede. O fato de o mesmo fanout aparecer nos nove
cantos sugere uma restrição estrutural comum, que precisa ser rastreada antes
de qualquer alteração de parâmetros ou células.

#### Resultado parcial do passo 24

O `violator_list.rpt` do canto `max_ss_100C_1v60` contém 35 caminhos de setup,
todos com o mesmo ponto de partida `_21619_/Q`. Os endpoints variam entre
`_21123_/D`, `_21140_/D`, `_21143_/D`, outros registradores `_211xx`, `_216xx`
e `_198xx`. O pior caminho é:

```text
[setup reg-reg] _21619_/Q -> _21123_/D : -1.816531 ns
```

Isso concentra a investigação em uma origem lógica comum e em sua distribuição
combinacional. Ainda falta mapear os nomes sintetizados para sinais hierárquicos
do Ibex e identificar as células/redes do caminho.

O mapeamento na netlist física mostrou:

| Ponto | Célula | Sinal hierárquico |
| --- | --- | --- |
| origem `_21619_/Q` | `sky130_fd_sc_hd__dfxtp_2` | `u_ibex_top.gen_regfile_ff.register_file_i.raddr_a_i[1]` |
| destino `_21123_/D` | `sky130_fd_sc_hd__dfrtp_2` | entrada do registrador cuja saída é `u_ibex_top.crash_dump_o[32]` |

O endpoint recebe `net2989` e usa uma célula com reset; a origem é um flip-flop
sem reset. O caminho crítico está dentro da lógica do Ibex e relaciona o endereço
de leitura do regfile ao estado exportado no crash dump. A sequência seguinte
rastreou o driver de `net2989` e as células intermediárias, sem atribuir a falha
a uma única célula.

O driver imediato de `net2989` é:

```text
sky130_fd_sc_hd__dlygate4sd3_1 hold2989
    .A(_01343_)
    .X(net2989)
```

`hold2989` é uma célula de atraso inserida no reparo de hold. Ela aumenta o
atraso antes do endpoint e, portanto, também consome margem de setup. Isso expõe
uma interação entre reparo de hold e setup, mas não prova que a célula isolada
seja a causa completa: o restante da lógica que produz `_01343_` ainda precisa
ser examinado.

A rede `_01343_` é produzida por:

```text
sky130_fd_sc_hd__a22o_2 _18008_
    .A1(net2988)
    .A2(net1143)
    .B1(net319)
    .B2(u_ibex_top.crash_dump_o[32])
    .X(_01343_)
```

No trecho final do relatório STA, o sinal passa por lógica `a2111oi`, `or3`,
`or2`, `nor2`, `a211o`, inversor e `a22o`, além de seis buffers
`clkdlybuf4s25_1` (`fanout451`, `450`, `383`, `382`, `320` e `319`). Esses
buffers apresentam transições próximas ou superiores a 1 ns e atrasos de cerca
de 1,17 a 1,55 ns nesse canto. `hold2989` acrescenta aproximadamente 1,13 ns.
O trecho observado vai de 38,855 ns a 53,906 ns de chegada dos dados.

Conclusão do passo 24: a falha combina profundidade lógica, distribuição de
fanout e atraso acrescentado pelo reparo de hold. Ela não deve ser atribuída
somente ao RTL, ao buffer de hold ou a uma única célula sem uma análise de
otimização controlada. Este pipe-clean identifica a situação; não a corrige.

## Recursos medidos

Cada tag repetiu seus estágios predecessores. Portanto, os tempos não são o
custo isolado de cada etapa.

| Tag | Tempo de parede | Pico RSS (KiB) | Swaps |
| --- | ---: | ---: | ---: |
| `ibex-study2-frontend` | 0:04,66 | 123.064 | 0 |
| `ibex-study2-synth` | 1:57,92 | 883.884 | 0 |
| `ibex-study2-sta-prepnr` | 2:22,35 | 883.956 | 0 |
| `ibex-study2-floorplan` | 2:27,30 | 883.964 | 0 |
| `ibex-study2-pdn` | 2:33,99 | 884.208 | 0 |
| `ibex-study2-global-placement` | 2:34,62 | 883.636 | 0 |
| `ibex-study2-detailed-placement` | 3:24,10 | 883.704 | 0 |
| `ibex-study2-cts` | 3:45,31 | 884.172 | 0 |
| `ibex-study2-postcts` | 5:20,01 | 884.240 | 0 |
| `ibex-study2-global-routing` | 5:24,35 | 883.820 | 0 |
| `ibex-study2-detailed-routing` | 25:13,12 | 2.294.696 | 0 |
| `ibex-study2-full` | 29:20,94 | 2.278.200 | 0 |

### Passos 18 a 25 — inspeção e diagnóstico

Esses passos usaram somente o run final da execução 2. As consultas foram
definidas a partir dos arquivos realmente gerados, sem copiar caminhos ou nomes
de cantos da primeira execução. Nenhuma correção de RTL, constraints ou PnR fez
parte deste pipe-clean: o objetivo foi registrar a situação reproduzida e
identificar as pendências.

## Resultado consolidado

### Passo 25 — conclusão do pipe-clean

| Gate | Resultado |
| --- | --- |
| revisão e ambiente | `PASS`, rastreáveis |
| compilação do core/wrapper | `PASS` |
| firmware mínimo | `SMOKE-PASS`; 261 instruções e halt determinístico |
| RTL para GDSII SKY130 | `PASS` de execução |
| DRC / LVS / antena | `PASS` |
| hold multicorner | `PASS` em 9 cantos |
| setup multicorner | `FAIL` em 2 cantos; 36 ocorrências agregadas |
| slew / capacitância / fanout | `FAIL`; máximos de 6.981 / 71 / 18 |
| equivalência formal RTL/netlist | não executada; `Yosys.EQY` pulado |
| IR drop | não qualificado sem fontes reais em `VSRC_LOC_FILES` |
| conformidade ISA e cobertura | não executadas |

Classificação final: **CANDIDATE**. O Ibex oficial e seu wrapper são
reprodutivelmente compiláveis, executam o smoke funcional e percorrem o fluxo
SKY130 até GDSII com DRC, LVS e antena aprovados. O bloco não está em signoff e
não deve ser descrito como fisicamente fechado enquanto setup, slew,
capacitância e fanout permanecerem abertos.

Próximos testes recomendados: classificar os 134 warnings de lint; executar
equivalência RTL/netlist; adicionar testes funcionais de exceções, interrupções
e erros de barramento; revisar constraints com PD; e somente então executar uma
otimização controlada do caminho crítico e dos buffers de fanout/hold.
