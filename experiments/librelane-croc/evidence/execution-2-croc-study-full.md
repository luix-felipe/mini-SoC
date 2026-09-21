# Execução 2 — reexecução didática Croc/CVE2 (`croc-study-full`)

Data: 2026-09-20  
Origem: reexecução incremental acompanhada localmente.  
Status: **CANDIDATE; fluxo físico completo, sem signoff elétrico**.

## Identificação

- Croc: commit `968bab17b37e88d9200a0899cb9181e42850ec87`
- CVE2 selecionado pelo Croc: commit `53076d64c97685b1d2f5d07cd7f5cc439cf1f351`
- top-level: `core_wrap`
- tecnologia: `sky130A`
- biblioteca: `sky130_fd_sc_hd`
- período de clock: 50 ns
- tag final: `croc-study-full`

## Comando final

Executado na raiz de `mini-SoC`, dentro do ambiente UNIC-CASS:

```bash
LL=/home/designer/shared/bin/librelane-local

/usr/bin/time -v "$LL" \
  --run-tag croc-study-full \
  experiments/librelane-croc/config.yaml
```

## Resultado terminal

```text
Final result: Circuits match uniquely.
Antenna: Passed
LVS: Passed
DRC: Passed
Flow complete.
Exit status: 0
Elapsed time: 28:43.86
Maximum resident set size: 1483136 KiB
Swaps: 0
```

## Resultados finais desta execução

| Item | Resultado |
| --- | ---: |
| DRC do design | 0 |
| DRC Magic / KLayout | 0 / 0 |
| Erros LVS | 0 |
| Antena — redes/pinos | 0 / 0 |
| Violações de setup/hold | 0 / 0 em 9 cantos |
| Pior slack de setup | +3,95698 ns (`max_ss`) |
| Pior slack de hold | +0,10445 ns (`min_ff`) |
| Pior contagem de slew | 5.090 (`max_ss`) |
| Pior contagem de capacitância | 60 (`max_ss`) |
| Cantos reprovados em slew/capacitância | 9 / 5 |
| Violações de fanout agregadas | 8 |
| Warnings de lint | 298, classificados durante o frontend |

Slew foi reprovado nos nove cantos. Capacitância foi reprovada em cinco:
`max_ff`, `max_ss`, `max_tt`, `min_ss` e `nom_ss`. Setup e hold tiveram
WNS/TNS iguais a zero em todos os cantos.

## Etapas incrementais desta execução

| Passo | Tag | Resultado principal |
| ---: | --- | --- |
| 1 | `croc-study-frontend-v2` | frontend aprovado; 298 warnings classificados |
| 2 | `croc-study-synth` | 9.110 células, 118.597,49 µm² e zero células não mapeadas |
| 3 | `croc-study-sta-prepnr` | setup/hold aprovados antes do PnR; limites elétricos abertos |
| 4 | `croc-study-floorplan` | die 750 × 750 µm; utilização de 22,11% |
| 5 | `croc-study-pdn` | grade gerada sem violação reportada |
| 6 | `croc-study-global-placement` | overflow zero; fanout alto de clock/reset registrado |
| 7 | `croc-study-detailed-placement` | legalização concluída; utilização de 28,08% |
| 8 | `croc-study-cts` | árvore para 1.791 sinks e 253 buffers criados |
| 9 | `croc-study-postcts` | setup/hold TT fechados após reparos |
| 10 | `croc-study-global-routing` | overflow zero; uso total de recursos de 30,50% |
| 11 | `croc-study-detailed-routing` | DRC interno e antena finais iguais a zero |
| 12 | `croc-study-full` | GDSII, DRC, LVS, antena e STA multicorner finais |
| 13 | inspeção no KLayout | `core_wrap.gds` abriu corretamente e a estrutura física foi inspecionada |

## Artefatos locais

O run fica em `runs/croc-study-full/`, ignorado pelo Git. As vistas principais
são:

```text
final/gds/core_wrap.gds
final/def/core_wrap.def
final/odb/core_wrap.odb
final/lef/core_wrap.lef
final/nl/core_wrap.nl.v
final/sdc/core_wrap.sdc
final/spice/core_wrap.spice
final/metrics.json
```

## Inspeção visual do GDSII

O operador abriu `final/gds/core_wrap.gds` no KLayout 0.30.5. A imagem recebida
mostra a célula superior `core_wrap`, o contorno retangular do die, linhas de
standard cells, malha de alimentação/roteamento e pinos externos nas bordas.
Os pinos `instr_*` visíveis são coerentes com a interface de instruções exposta
pelo wrapper. Nenhuma macro de memória foi identificada, em concordância com a
contagem de zero macros deste experimento.

Como a captura mantém muitas camadas e textos simultaneamente visíveis, ela não
permite classificar isoladamente cada geometria nem serve como prova de DRC.
Essa evidência visual complementa, mas não substitui, os checkers automáticos.

## Inventário das vistas finais

| Arquivo/diretório | Uso |
| --- | --- |
| `def/` | geometria física em formato DEF |
| `gds/` | GDSII final principal |
| `json_h/` | interface/top elaborados pelo frontend Yosys |
| `klayout_gds/` | GDS gerado pela trilha do KLayout |
| `lef/` | abstração física para integração hierárquica |
| `mag/` e `mag_gds/` | banco Magic e seu GDS |
| `metrics.csv` e `metrics.json` | métricas tabulares e estruturadas |
| `nl/` | netlist Verilog sem power pins explícitos |
| `odb/` | banco físico completo do OpenROAD |
| `pnl/` | netlist Verilog com `VPWR`/`VGND` |
| `render/` | visualização PNG |
| `sdc/` | constraints finais de timing |
| `spice/` | conectividade SPICE para verificação física |
| `vh/` | abstração Verilog da interface externa |

O inventário confirmou 16 arquivos finais. O cabeçalho `core_wrap.vh` expõe
clock/reset, interrupções, debug, fetch, interfaces OBI de instrução/dados e
`core_busy_o`. O SDC entregue preserva o clock de 50 ns e as constraints de
interface usadas pelo experimento.

## Análise do pior canto elétrico

O relatório `55-openroad-stapostpnr/max_ss_100C_1v60/checks.rpt` confirmou:

| Checagem | Limite | Pior valor | Slack | Violações |
| --- | ---: | ---: | ---: | ---: |
| Slew | 0,750 ns | 2,301 ns | -1,551 ns | 5.090 |
| Fanout | 10 | 12 | -2 | 8 |
| Capacitância | 0,094309 | 0,146654 | -0,052345 | 60 |

Os piores registros incluem buffers `fanout*` criados pelo fluxo. O buffer
`fanout1632` dirige `net1632`, que alimenta células da multiplexação de leitura
de `i_core.register_file_i.rf_reg[...]`. Dois dos oito excessos de fanout são
folhas da árvore de clock; os demais são redes funcionais ou buffers de reparo.
Portanto, a falha elétrica não está restrita ao clock e não deve ser atribuída
automaticamente a um defeito lógico do CVE2.

O relatório também informou zero drivers parcialmente sem anotação. Nenhuma
correção foi aplicada: ainda é necessário avaliar sizing/buffering, constraints
e a implementação FF do register file antes de decidir mudanças.

## Rastreamento de uma rede infratora

`fanout1632` foi localizado na netlist `core_wrap.pnl.v` como uma célula
`sky130_fd_sc_hd__clkdlybuf4s25_1`: sua entrada recebe `_02146_` e sua saída
dirige `net1632`. A rede alimenta sete entradas `A2` de lógica associada a
`i_core.register_file_i.rf_reg[...]` e os buffers de ramificação `fanout1630`
e `fanout1631`.

As nove cargas diretas ficam abaixo do limite de fanout 10, mas a saída ainda
viola capacitância/slew. Isso comprova que contar cargas não substitui calcular
a carga elétrica e o efeito do roteamento. Os índices acima de 31 em `rf_reg`
são bits de um array achatado, não registradores arquiteturais RISC-V.

O driver anterior também foi localizado: a célula `_07427_`, do tipo
`sky130_fd_sc_hd__and2b_2`, produz `_02146_` pela função
`(~net1908) & net1892`. Portanto, a ramificação nasce de lógica combinacional
de decodificação. Os sinais anteriores aos buffers ainda precisam ser
rastreados para recuperar seus nomes funcionais.

Os drivers de `net1908` e `net1892` são, respectivamente, `fanout1908` e
`fanout1892`, ambos buffers não inversores `clkdlybuf4s25_1`. Suas entradas são
`net1911` e `net1900`. Assim, esse nível pertence à árvore de buffering criada
pelo fluxo e não introduz nova função lógica. `fanout1894` é uma ramificação
paralela de `net1900`, não o driver de `net1892`.

No nível anterior, `fanout1911` recebe `net1915`, enquanto `wire1900`, uma
célula `clkbuf_4` de reparo de interconexão, recebe `net1899`. Ambos preservam
a polaridade. A função que chega ao decoder permanece equivalente a
`(~net1915) & net1899` nesse ponto do rastreamento.

O rastreamento terminou em sinais do RTL: a primeira árvore nasce de
`i_core.id_stage_i.controller_i.instr_i[20]` e a segunda de `instr_i[21]`.
Assim, `_02146_ = (~instr_i[20]) & instr_i[21]`. O código do decoder confirma
`instr_rs2 = instr[24:20]` e `rf_raddr_b_o = instr_rs2`; os dois bits são parte
do endereço de leitura `rs2` do register file. A árvore de buffers distribui
esse termo de seleção pelo mux do banco implementado em flip-flops.

Essa origem explica a alta distribuição de uma parte das redes, mas não prova
defeito funcional nem deve ser generalizada automaticamente para todas as
5.090 violações de slew.

## Distribuição das violações de slew

A classificação inicial por prefixo de instância encontrou 928 violações em
`fanout*`, 24 em `input*`, nenhuma em instâncias nomeadas `clkbuf*` e 4.138 em
lógica/células comuns. As classes somam as 5.090 violações do pior canto.

Logo, somente 18,23% aparecem diretamente sob nomes `fanout*`, enquanto 81,3%
estão em instâncias lógicas genéricas. Como nomes não determinam o tipo físico
da célula, a próxima classificação deve usar os masters SKY130 presentes na
netlist antes de propor uma correção.

A correlação com os masters SKY130 mostrou 955 ocorrências em
`clkdlybuf4s25_1`, 690 em `mux2_1`, 610 em `a22o_2` e 414 em `a221o_2`. Esses
quatro tipos representam 52,44% das violações; os vinte tipos mais frequentes
representam 88,07%. Apenas 61 ocorrências são de `dfrtp_2`.

Esse resultado reforça a presença de buffers e lógica de seleção, mas não
identifica sozinho os drivers: o checker conta pinos de entrada e de saída. Uma
violação em `A2`, por exemplo, caracteriza a transição recebida pela carga, não
necessariamente uma falha da célula `a22o` que possui esse pino.

A classificação por nome de pino encontrou 633 ocorrências nas saídas comuns
`X`, `Y` e `Q` (12,44%) e 4.457 em entradas/demais pinos (87,56%), distribuídas
por 3.977 instâncias únicas. Assim, as 5.090 ocorrências incluem múltiplas
observações da mesma transição nas cargas e não equivalem a 5.090 drivers
independentes.

Entre as 633 saídas, 508 (80,25%) pertencem ao master
`sky130_fd_sc_hd__clkdlybuf4s25_1`. A netlist contém 1.564 instâncias desse
master: 1.368 `fanout*`, 95 `input*`, 100 `output*` e uma `wire*`. Os 1.437
buffers de hold usam outro master, `dlygate4sd3_1`; portanto, as saídas lentas
estão relacionadas principalmente às árvores de fanout/interface, não aos
buffers de hold.

O próximo experimento deve alterar opções suportadas do fluxo e comparar as
métricas; não deve editar manualmente a netlist gerada.

## Baseline de configuração resolvida

O `resolved.json` confirmou fanout máximo 10, transição máxima 0,75 ns,
capacitância global 0,2, `SYNTH_BUFFER_CELL=buf_2/A/X` e placement timing-driven
desabilitado. As margens de repair de slew/cap são 20% pós-placement e 10%
pós-global-routing.

O limite efetivo de capacitância 0,094309 observado em algumas saídas vem da
caracterização Liberty e é mais restritivo que o valor global. O buffer de
síntese `buf_2` também não impede que o resizer físico selecione
`clkdlybuf4s25_1` em reparos posteriores. A baseline foi apenas analisada;
nenhum parâmetro foi alterado neste relatório.

## Encerramento do escopo

Esta execução encerra o pipe-clean físico como `CANDIDATE`. As análises das
violações servem para caracterizar a situação atual; nenhuma tentativa de
timing closure faz parte deste relatório. A próxima prioridade do Croc é o
smoke funcional bloqueado por ausência de término determinístico.

## Avisos e limitações desta execução

- `Yosys.EQY` foi pulado; equivalência formal RTL versus netlist não foi feita.
- `VSRC_LOC_FILES` não foi definido; o relatório de IR drop não é qualificável.
- Há violações de slew, capacitância e fanout a corrigir.
- O checker de fios longos foi pulado por falta de threshold.
- O PDK não fornece informação de gate de antena para todos os pinos citados.
- `DRT-0349` registra suporte incompleto a regras LEF58 sem `CUTCLASS`.

## Conclusão exclusiva da execução 2

O run comprova viabilidade RTL-to-GDSII do core isolado nessa configuração. Não
comprova integração do SoC, funcionamento por simulação pós-layout nem signoff
elétrico para fabricação.
