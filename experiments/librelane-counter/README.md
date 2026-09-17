# Laboratório LibreLane: contador de 8 bits

Experimento pequeno para aprender o fluxo RTL -> GDSII sem o custo de executar
Ibex, SRAM ou o Mini-SoC completo. O circuito é um contador de 8 bits com
`enable`, clock de 20 MHz (`50 ns`) e reset assíncrono ativo em nível baixo.

Execute os comandos dentro do ambiente UNIC-CASS, a partir da raiz de
`mini-SoC`.

## Arquivos de entrada

- `rtl/librelane_counter8.sv`: comportamento RTL sintetizável;
- `config.yaml`: módulo de topo, clock, área do die e opções do fluxo;
- `constraints.sdc`: clock, atrasos de I/O, carga e limites elétricos;
- `pin_order.cfg`: lados do die em que os pinos externos serão posicionados.

O PDK é selecionado pelo ambiente:

```bash
echo "$PDK"       # esperado: sky130A
echo "$PDK_ROOT"  # esperado no UNIC-CASS: /opt/pdks
```

Defina um nome curto para o executável usado nos comandos seguintes:

```bash
LL=/home/designer/shared/bin/librelane-local
```

`LL` é apenas uma variável do shell. Ao escrever `$LL`, o shell substitui esse
texto pelo caminho completo do executável. Ajuste o caminho se o wrapper estiver
instalado em outro local.

## Anatomia de um comando

```bash
$LL \
  --run-tag counter-synth \
  --to Yosys.Synthesis \
  experiments/librelane-counter/config.yaml
```

- `$LL`: inicia o LibreLane;
- `--run-tag counter-synth`: nomeia a execução e sua pasta de resultados;
- `--to Yosys.Synthesis`: para depois desse estágio;
- `config.yaml`: fornece todas as entradas e configurações do projeto;
- `\`: continua o mesmo comando na linha seguinte; não é uma nova execução.

Cada comando abaixo cria um run independente e refaz as etapas anteriores. Isso
consome um pouco mais de tempo, mas mantém evidências separadas para estudo. Com
`--to`, o indicador pode chegar a `80/80` porque o LibreLane conta também os
estágios posteriores que foram deliberadamente pulados.

## Execução incremental

### 1. Síntese

```bash
$LL --run-tag counter-synth \
  --to Yosys.Synthesis \
  experiments/librelane-counter/config.yaml
```

O Yosys converte o RTL em uma netlist de células `sky130_fd_sc_hd`. Verifique
quantidade e área das células, latches inferidos, células não mapeadas e erros de
síntese. Neste experimento foram obtidas 26 células mapeadas, sem latches ou
células não mapeadas.

### 2. Floorplan

```bash
$LL --run-tag counter-floorplan \
  --to OpenROAD.Floorplan \
  experiments/librelane-counter/config.yaml
```

Cria die, área interna, linhas para standard cells e trilhas metálicas. Ainda
não posiciona definitivamente as células. Confira área, utilização, rows e se
o clock foi reconhecido.

### 3. Rede de alimentação

```bash
$LL --run-tag counter-pdn \
  --to OpenROAD.GeneratePDN \
  experiments/librelane-counter/config.yaml
```

Insere tapcells, endcaps e a Power Distribution Network de `VPWR` e `VGND`.
O resultado esperado é zero violação da grade e todas as formas de alimentação
conectadas.

### 4. Placement

```bash
$LL --run-tag counter-placement \
  --to OpenROAD.DetailedPlacement \
  experiments/librelane-counter/config.yaml
```

Escolhe posições legais para células e pinos e repara problemas elétricos
iniciais. Observe utilização, comprimento estimado dos fios, buffers inseridos,
overlap e violações de slew, capacitância ou fanout.

### 5. Clock Tree Synthesis

```bash
$LL --run-tag counter-cts \
  --to OpenROAD.CTS \
  experiments/librelane-counter/config.yaml
```

Transforma o clock ideal em uma árvore física balanceada. Foram encontrados 8
destinos e inseridos 3 buffers de clock. Após o CTS, o fluxo pode adicionar
buffers de atraso para corrigir caminhos de hold rápidos demais.

### 6. Roteamento global

```bash
$LL --run-tag counter-global-routing \
  --to OpenROAD.GlobalRouting \
  experiments/librelane-counter/config.yaml
```

Planeja regiões e camadas para os fios, ainda sem fechar cada geometria. Confira
uso dos recursos, congestionamento e `overflow`. O run observado usou 2,27% dos
recursos e terminou com overflow zero.

### 7. Roteamento detalhado

```bash
$LL --run-tag counter-detailed-routing \
  --to OpenROAD.DetailedRouting \
  experiments/librelane-counter/config.yaml
```

Desenha fios e vias obedecendo às regras do PDK. O roteador encontrou 5
violações na primeira iteração e corrigiu todas na segunda, terminando com 965
micrômetros de fios, 282 vias e zero erro interno de roteamento.

### 8. Validação das constraints

O `config.yaml` aponta `PNR_SDC_FILE` e `SIGNOFF_SDC_FILE` para
`constraints.sdc`. Esse arquivo define:

- clock de 50 ns e incerteza de 0,25 ns;
- atraso de entrada de 5 ns para `enable_i`;
- atraso de saída de 5 ns para `count_o`;
- carga capacitiva das saídas;
- falso caminho a partir do reset assíncrono;
- limites de transição, capacitância e fanout.

Antes de repetir o layout, valide somente a leitura das constraints e a STA
pré-PnR:

```bash
$LL --run-tag counter-custom-sdc \
  --to OpenROAD.STAPrePNR \
  experiments/librelane-counter/config.yaml
```

O resultado observado foi zero violação e slack de setup de `42,9996 ns`. Os
avisos de fallback de `PNR_SDC_FILE` e `SIGNOFF_SDC_FILE` desapareceram.

## Fluxo completo até GDSII

Sem `--to`, o LibreLane executa todos os estágios configurados:

```bash
$LL --run-tag counter-full-sdc \
  experiments/librelane-counter/config.yaml
```

O caminho simplificado é:

```text
RTL -> lint -> síntese -> floorplan -> PDN -> placement -> CTS
    -> routing -> extração parasitária -> STA -> GDSII -> DRC/LVS/antena
```

Resultado reproduzido em `counter-full-sdc`:

- fluxo completo em 50 segundos;
- GDSII gerado;
- DRC Magic e KLayout: zero erro;
- LVS: zero diferença;
- antena: zero violação;
- pior slack de setup: `42,530 ns`;
- pior slack de hold: `0,125 ns`.

Em relação ao primeiro run com SDC genérico, o slack de setup aumentou cerca de
5 ns porque o atraso reservado para I/O foi reduzido de 10 ns para 5 ns. O
layout não mudou: as constraints continuaram folgadas e não exigiram novas
otimizações físicas.

## Como interpretar

- `ERROR` ou código de saída diferente de zero: etapa não concluída;
- `WARNING`: exige análise, mas não significa reprovação automaticamente;
- slack positivo: requisito de timing atendido;
- slack negativo: violação de timing;
- `WNS = 0` e `TNS = 0`: nenhuma violação negativa acumulada;
- overflow zero: há capacidade de roteamento suficiente;
- DRC zero: nenhuma violação geométrica encontrada pelo verificador indicado;
- LVS pass: layout e netlist representam o mesmo circuito;
- antena pass: não foram detectadas conexões vulneráveis ao processo de plasma.

Violações intermediárias podem ser corrigidas automaticamente. O resultado
final e os relatórios mostram se o reparo realmente funcionou.

## Resultados e visualização

Os artefatos ficam em:

```text
experiments/librelane-counter/runs/<run-tag>/
```

Arquivos finais importantes de `counter-full-sdc/final/`:

- `gds/librelane_counter8.gds`: layout GDSII;
- `render/librelane_counter8.png`: imagem rápida do layout;
- `nl/librelane_counter8.nl.v`: netlist Verilog final;
- `spef/`: parasitas RC extraídos;
- `sdf/`: atrasos para simulação pós-layout;
- `spice/librelane_counter8.spice`: netlist extraída;
- `metrics.csv` e `metrics.json`: métricas consolidadas.

Para abrir o layout:

```bash
klayout \
  experiments/librelane-counter/runs/counter-full-sdc/final/gds/librelane_counter8.gds
```

## Limitações e próximo exercício

O experimento comprova que LibreLane, OpenROAD, Yosys, Magic, Netgen, KLayout e
o PDK SKY130A estão operacionais no ambiente. Ele não qualifica o Ibex nem o
Mini-SoC e não equivale ao signoff de um chip para fabricação.

As constraints deste laboratório são didáticas e não representam ainda o
ambiente externo de um produto real. A análise de IR drop também é apenas
indicativa enquanto `VSRC_LOC_FILES` não representar fontes físicas de potência.
O próximo passo é aplicar o fluxo ao Ibex isolado, inicialmente sem SRAM, com
constraints adequadas ao novo módulo de topo.
