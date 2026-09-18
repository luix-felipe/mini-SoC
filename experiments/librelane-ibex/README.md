# Laboratório LibreLane: Ibex isolado

Roteiro de aprendizado RTL -> GDSII usando `chipus_ibex_wrapper` e o Ibex
oficial, sem SRAM externa, UART ou interconnect do Mini-SoC. Registro atualizado
em 2026-09-18: **passos 1 a 15 executados; GDSII gerado**. A visualização no
KLayout (passo 16) ainda não foi confirmada pelo operador.

Estado: `CANDIDATE`, com fluxo RTL -> GDSII reproduzido e DRC/LVS/antena
aprovados. **Não está em signoff**: persistem violações de setup, slew e
capacitância. Hold passou nos nove cantos finais analisados.

## Entradas e ambiente

- Ibex: <https://github.com/lowRISC/ibex>, commit
  `8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2`;
- [wrapper](../../rtl/chipus_ibex_wrapper.sv): configuração `small`, interfaces
  nativas de instruções/dados e interrupções expostas;
- [config.yaml](config.yaml): top, fontes, frontend Slang e die de 750 x 750 µm;
- [constraints.sdc](constraints.sdc): clock de 50 ns (20 MHz), incerteza de
  0,25 ns, atrasos de I/O de 5 ns e carga de saída de 0,0334 pF;
- [pin_order.cfg](pin_order.cfg): agrupamento dos sinais nas bordas;
- `../../flow/src/`: 141 fontes RTL e 53 includes gerados pelo FuseSoC;
- `.gitignore`: exclui `runs/`, que contém os artefatos EDA.

Execução no UNIC-CASS `isaiassh/unic-cass-tools:1.1.0`, com `sky130A` e
`sky130_fd_sc_hd`. Versões observadas: LibreLane 3.0.0rc1, FuseSoC 2.4.3,
Yosys 0.62 no fluxo, Verilator 5.044 no lint LibreLane e 5.026 no teste do
wrapper. O fluxo pode usar ferramentas diferentes das encontradas diretamente
no PATH do terminal.

Dentro do container:

```bash
cd ~/shared/chipus-soc/mini-SoC
pwd                 # /home/designer/shared/chipus-soc/mini-SoC
echo "$PDK"         # sky130A, não 130A
echo "$PDK_ROOT"    # /opt/pdks
LL=/home/designer/shared/bin/librelane-local
```

`~` representa `/home/designer`. Os caminhos seguintes são relativos à raiz de
`mini-SoC`, não à raiz `chipus-soc`. Ajuste o caminho do executável em outra máquina.

## Anatomia dos comandos e segurança

```bash
/usr/bin/time -v "$LL" \
  --run-tag ibex-synth \
  --to Yosys.Synthesis \
  experiments/librelane-ibex/config.yaml
```

- `LL=...`: guarda o caminho do executável; `"$LL"` expande essa variável;
- `/usr/bin/time -v`: mede duração, CPU e pico de RSS dos processos acompanhados;
- `--run-tag`: nomeia a pasta `runs/<tag>/`; use uma tag nova para preservar evidências;
- `--to`: executa as dependências anteriores e para após o estágio indicado;
- `\`: continua o mesmo comando na linha seguinte;
- `dir::` no YAML: resolve caminhos a partir da pasta do próprio config;
- `*.sv`: seleciona as fontes; seus prefixos numéricos preservam a ordem;
- `80/80`: inclui estágios pulados por `--to`, não comprova o fluxo completo.

Cada tag abaixo inicia um run independente e repete síntese e estágios anteriores.
Isso facilita o estudo, mas aumenta o trabalho total. Execute um gate por vez,
com monitor de memória aberto; não use o config do SoC com SRAM inferida.
Interrompa com `Ctrl+C` diante de paginação intensa ou perda de resposta.

O pico medido passou de aproximadamente 864 MiB para 2,24 GiB no roteamento.
`Swaps: 0` não comprova ausência de pressão de memória no Windows/WSL inteiro.
Não repetir fluxos automaticamente; reservar recursos e monitorar a máquina.

## Etapas executadas

Os [trechos finais de terminal](evidence/terminal-final-logs.md) preservam os
logs enviados pelo operador até placement; os
[resultados dos passos 11 a 15](evidence/steps-11-15.md) registram o avanço seguinte.
Os runs guardam logs completos e configs históricos;
o config atual incorpora mudanças feitas ao longo do laboratório.

### 1. Preparar fontes

```bash
make -C pipe-clean show
make -C pipe-clean librelane-prepare
```

`-C` manda o Make entrar em `pipe-clean`. O alvo chama
`flow/prepare-sources.sh`: verifica a revisão, usa FuseSoC para resolver
dependências e copia fontes ordenadas para `flow/src/{rtl,include}`.
Não sintetiza nem altera o clone upstream. Resultado confirmado: 141 fontes,
53 includes; arquivos gerados e ignorados pelo Git.

### 2. Confirmar e elaborar o top-level

```bash
grep -nE '^module chipus_ibex_wrapper|^[[:space:]]*ibex_top #|^endmodule' \
  rtl/chipus_ibex_wrapper.sv
make -C pipe-clean ibex-wrapper
```

O `grep -nE` busca declarações e mostra números de linha. FuseSoC organiza as
fontes e Verilator confere hierarquia, parâmetros e conexões do wrapper.
Resultado: `IBEX_RTL_COMPILE` passou. Não é simulação funcional nem síntese.

### 3. Configurar o experimento

```bash
mkdir -p experiments/librelane-ibex
ls -la experiments/librelane-ibex
sed -n '1,120p' experiments/librelane-ibex/config.yaml
```

Foram criados config, SDC, pin order e `.gitignore` neste diretório. `mkdir -p`
cria a pasta se necessário; `ls -la` inclui arquivos ocultos; `sed -n` imprime
somente o intervalo pedido. O top é o wrapper, não `ibex_simple_system` nem
`chipus_soc_top`. `USE_SLANG` habilita o frontend SystemVerilog do Yosys.

### 4. Validar frontend

```bash
"$LL" --run-tag ibex-frontend --to Yosys.JSONHeader \
  experiments/librelane-ibex/config.yaml
```

Leitura/elaboração das fontes e geração de descrição JSON: concluídas em 3 s.
Zero erro de lint; 134 warnings classificados na seção de interpretação.

### 5. Sintetizar

```bash
/usr/bin/time -v "$LL" --run-tag ibex-synth --to Yosys.Synthesis \
  experiments/librelane-ibex/config.yaml
```

Yosys/ABC converteram o RTL em células SKY130: 11.943 células,
151.308,87 µm² (0,151 mm²), 1.946 flip-flops e um latch explícito do clock gate.
Zero memória remanescente, latch inferido, célula não mapeada ou erro de check.
O latch intencional não contradiz a métrica de zero latch **inferido**.

### 6. Validar SDC e STA pré-PnR

```bash
/usr/bin/time -v "$LL" --run-tag ibex-sta-prepnr --to OpenROAD.STAPrePNR \
  experiments/librelane-ibex/config.yaml
```

OpenSTA analisou TT/25 °C/1,80 V, SS/100 °C/1,60 V e FF/-40 °C/1,95 V.
Pior setup: +12,612 ns, zero violação. Pior hold: -0,052 ns, uma violação no
clock gating no canto FF. Também foram reportadas 6.411 violações de slew,
396 de fanout e 51 de capacitância antes dos reparos físicos.

O aviso de input delay ausente em `rst_ni` foi resolvido definindo atraso zero,
mantendo o falso caminho do reset. A ausência do aviso foi confirmada no run
seguinte. Essa exceção é didática: recovery/removal de reset não estão qualificados.

### 7. Criar floorplan

```bash
/usr/bin/time -v "$LL" --run-tag ibex-floorplan --to OpenROAD.Floorplan \
  experiments/librelane-ibex/config.yaml
```

Die de 750 x 750 µm; core de 536.517 µm²; utilização inicial de 28,2%;
267 rows e 428.802 sites. O DEF possui 198 pinos; sua distribuição nas bordas
ocorre depois, no I/O placement. As violações anteriores ainda não são reparadas
neste gate.

### 8. Gerar PDN

```bash
/usr/bin/time -v "$LL" --run-tag ibex-pdn --to OpenROAD.GeneratePDN \
  experiments/librelane-ibex/config.yaml
```

Inseridas 534 endcaps e 7.666 tapcells. `VPWR` e `VGND` tiveram continuidade
confirmada e zero violação de grade. Utilização aproximada: 30%. Isso não é
validação de IR drop com fontes reais de alimentação.

### 9. Placement global e pinos

```bash
/usr/bin/time -v "$LL" --run-tag ibex-global-placement --to OpenROAD.GlobalPlacement \
  experiments/librelane-ibex/config.yaml
```

Distribuição: norte 21 pinos, oeste 68, leste 105 e sul 4. Placement concluído;
congestionamento ponderado final de 0,9765. Houve congestionamento localizado e
tentativas de otimização, portanto roteabilidade definitiva ainda não comprovada.
Redes de alto fanout: reset com 1.674 destinos e clock interno com 1.946.

### 10. Reparos e placement detalhado

```bash
/usr/bin/time -v "$LL" --run-tag ibex-detailed-placement --to OpenROAD.DetailedPlacement \
  experiments/librelane-ibex/config.yaml
```

Foram redimensionadas 85 células; inseridos 2.507 buffers em 549 redes, mais
90 buffers de entrada e 100 de saída. Total: 2.697 buffers de reparo.
Utilização: 34,6%. As posições foram legalizadas e houve otimização de orientação.

O gate concluiu, mas não contém uma nova STA dedicada após o reparo. Métricas de
timing herdadas do estágio anterior não comprovam fechamento. A violação do
clock gate e os limites elétricos precisam ser reavaliados após CTS/reparos.

### 11. CTS

```bash
/usr/bin/time -v "$LL" --run-tag ibex-cts --to OpenROAD.CTS \
  experiments/librelane-ibex/config.yaml
```

Constrói buffers e ramificações para distribuir o clock aos registradores e
controlar diferenças de chegada (skew). Execução concluída com saída zero;
o run pós-CTS seguinte contém 391 clock buffers e 31 clock inverters.
CTS concluído não significa timing fechado.

### 12. STA e reparos pós-CTS

```bash
/usr/bin/time -v "$LL" --run-tag ibex-postcts --to OpenROAD.STAMidPNR-2 \
  experiments/librelane-ibex/config.yaml
```

Nesta versão, a segunda instância `STAMidPNR-2` vem após
`ResizerTimingPostCTS`. Executa STA pós-CTS, reparos de setup/hold e nova STA.
Foram inseridos 1.723 buffers de hold. Na nova STA do canto TT/25 °C/1,80 V:
setup +18,157 ns; hold +0,301 ns; zero violação de setup/hold, slew ou
capacitância; 13 violações de fanout. Esse resultado não valida os demais cantos.
O nome da instância deve ser revisto se mudar a versão.

### 13. Roteamento global

```bash
/usr/bin/time -v "$LL" --run-tag ibex-global-routing --to OpenROAD.GlobalRouting \
  experiments/librelane-ibex/config.yaml
```

Cria guias de caminhos e camadas para as conexões. Resultado: 16.721 redes,
overflow final zero em todas as camadas; uso agregado dos recursos de 35,70%;
1.229.959 µm de fios e 134.863 vias planejadas. Não é DRC nem timing final.

### 14. Roteamento detalhado

```bash
/usr/bin/time -v "$LL" --run-tag ibex-detailed-routing --to OpenROAD.DetailedRouting \
  experiments/librelane-ibex/config.yaml
```

Define a geometria e posição dos fios/vias. Resultado final: zero DRC interno
do roteador e zero violação de antena em redes/pinos; 932.198 µm de fios,
137.387 vias e 119 células de antena. O aviso `GRT-0243` ocorreu numa tentativa
intermediária; os reparos posteriores chegaram a zero. O DRC interno do roteador
não substitui Magic/KLayout.

### 15. Extração, STA final, GDSII e verificação

```bash
/usr/bin/time -v "$LL" --run-tag ibex-full \
  experiments/librelane-ibex/config.yaml
```

Sem `--to`, executa todo o fluxo: células de preenchimento, RCX/SPEF, STA
pós-layout multicorner, GDSII, DRC Magic/KLayout, extração SPICE e LVS Netgen.
Resultado: GDSII gerado, DRC Magic/KLayout, LVS e antena aprovados; Netgen
reportou `Circuits match uniquely`. A execução terminou com saída zero, mas
os checkers reportaram violações como warnings, não como falha do processo.

| Verificação final | Resultado |
| --- | --- |
| Setup | Falhou em `max_ss_100C_1v60` (-1,817 ns) e `nom_ss_100C_1v60` (-0,301 ns) |
| Hold | Zero violação nos nove cantos analisados |
| Slew | Violações nos nove cantos; maior contagem: 6.981 no canto `max_ss` |
| Capacitância | Violações em cinco cantos; maior contagem: 71 no canto `max_ss` |
| DRC / LVS / antena | Aprovados |

`min/nom/max` identificam cantos de parasitas; TT/SS/FF identificam cantos de
células. A STA pós-extração não é equivalente à análise típica pós-CTS do passo 12.
Slew é o tempo de transição do sinal; capacitância é a carga elétrica na rede.
Essas pendências impedem declarar signoff ou `SMOKE-PASS` completo do bloco.

Equivalência RTL/netlist (`Yosys.EQY`) foi pulada: LVS compara o circuito extraído
do layout com a netlist, não comprova equivalência com o RTL. IR drop sem
`VSRC_LOC_FILES`, reset excluído da STA e sete saídas sem informação de difusão
de antena continuam limitações a revisar. Não relaxar constraints para ocultar
violações; primeiro identificar os caminhos/redes responsáveis.

## Recursos medidos pelo operador

Todos os tempos incluem repetição dos estágios anteriores, não apenas o estágio-alvo.

| Run | Tempo real (`time`) | Pico RSS (KiB) | Swaps | Saída |
| --- | ---: | ---: | ---: | ---: |
| `ibex-synth` | 1:51,54 | 884.056 | 0 | 0 |
| `ibex-sta-prepnr` | 2:15,25 | 884.612 | 0 | 0 |
| `ibex-floorplan` | 2:18,71 | 884.528 | 0 | 0 |
| `ibex-pdn` | 2:20,03 | 884.436 | 0 | 0 |
| `ibex-global-placement` | 2:26,74 | 883.808 | 0 | 0 |
| `ibex-detailed-placement` | 3:20,61 | 883.632 | 0 | 0 |
| `ibex-cts` | 3:52,72 | 884.260 | 0 | 0 |
| `ibex-postcts` | 5:24,35 | 884.420 | 0 | 0 |
| `ibex-global-routing` | 5:23,26 | 884.016 | 0 | 0 |
| `ibex-detailed-routing` | 26:20,44 | 2.344.556 | 0 | 0 |
| `ibex-full` | 29:49,31 | 2.313.336 | 0 | 0 |

## Interpretação dos avisos e resultados

- 83 `PINCONNECTEMPTY`: saídas deixadas abertas, incluindo recursos desativados;
- 48 `UNUSEDPARAM`: parâmetros não usados nesta configuração;
- 3 `UNOPTFLAT`: dependências internas conhecidas, com waivers no upstream
  `examples/simple_system/lint/verilator_waiver.vlt`; não editar o core para ocultá-las;
- backend Edalize deprecated: aviso de infraestrutura, não erro RTL;
- `GRT-0281`: muitos destinos de clock/reset; exigir distribuição física adequada;
- `STA-1140`: carregamento repetido de Liberty, não duplicação de células RTL;
- `RSZ-0020`: redes especiais `VPWR`/`VGND`; continuidade da PDN foi verificada;
- `DRT-0349`: regra LEF58 de enclosure não suportada foi pulada pelo roteador;
  a aprovação do DRC independente não transforma esse aviso em validação universal;
- checker de comprimento de fios pulado: limiar não configurado;
- `Flow complete`/saída zero: execução concluída, não significa zero violação;
- slack negativo: requisito não atendido; WNS/TNS zero significam ausência de
  violações negativas reportadas, não cobertura completa das constraints;
- no log final, as linhas `VERBOSE No ... violations found` não anulam os
  warnings por canto nem as violações presentes nas métricas.

## Roteiro pendente — não executado

### 16. Visualizar e relatar

```bash
klayout experiments/librelane-ibex/runs/ibex-full/final/gds/chipus_ibex_wrapper.gds
```

Abrir somente quando o arquivo existir. Guardar resumo de métricas, comandos,
versões e screenshots. Em `runs/<tag>/`: logs por estágio e `final/metrics.json`;
o run completo já contém GDS, DEF/ODB, netlist, SPEF/SDF e SPICE.
Manter binários e bases geradas fora do Git; versionar apenas fontes/configs,
este roteiro e evidências textuais pequenas.

Após a visualização: estudar caminhos de setup e redes com slew/capacitância
fora do limite, revisar as constraints com PD e planejar uma correção controlada.
Essa investigação e novos runs ainda não foram executados neste registro.
