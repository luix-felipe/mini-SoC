# Relatório de progresso e incidente LibreLane — 2026-09-14

## Resumo executivo

O top-level mínimo do CHIPUS com Ibex foi implementado e passou na simulação
com firmware real. O LibreLane também passou pelos gates de lint e iniciou a
síntese. A síntese original, porém, tentou implementar a SRAM RTL completa de
64 KiB como flip-flops e lógica combinacional. O Yosys chegou a processar cerca
de 1,67 milhão de células, elevou o consumo observado do contêiner para
4,3 GiB e o WSL reiniciou antes da conclusão.

Após o reinício não havia contêiner ou processo de síntese ativo. A máquina
apresentava 9,7 GiB de RAM total, 1,7 GiB em uso e aproximadamente 8,0 GiB
disponíveis. O fluxo foi alterado para usar uma SRAM de 1 KiB somente no gate
de síntese de infraestrutura. A simulação funcional mantém o mapa de 64 KiB.

## Trabalho realizado

- Ibex fixado em `8b8ee086aef72e0833b7f0493d9d33f1e4d3c8e2`;
- Croc fixado em `968bab17b37e88d9200a0899cb9181e42850ec87`;
- wrapper sintetizável do Ibex validado com Verilator;
- top-level `chipus_soc_top` com SRAM unificada, controle de SoC e UART TX;
- mapa mínimo baseado nas regiões do Croc:
  - controle do SoC em `0x0300_0000`;
  - UART em `0x0300_2000`;
  - SRAM/boot em `0x1000_0000`;
  - entrada de reset em `0x1000_0080`;
- firmware RV32IMC, linker, testbench e comando de regressão reproduzível;
- preparação das fontes Ibex pelo FuseSoC 2.4.3;
- configuração inicial LibreLane para SKY130A/`sky130_fd_sc_hd` a 20 MHz;
- scripts WSL/WSLg e documentação de rotina revisados para caminhos portáveis.

## Evidência funcional

Comando executado:

```bash
make -C pipe-clean chipus-soc-smoke
```

Resultado:

```text
[PASS] CHIPUS_SOC_SMOKE: reset, fetch, SRAM load/store and MMIO status
[PASS] CHIPUS_UART_SMOKE: transmitted 'O'
```

O firmware iniciou em `0x1000_0080`, gravou e releu a SRAM, transmitiu `O` pela
UART e escreveu `1` no registrador MMIO de status.

## Execução do LibreLane

Na primeira tentativa, `Verilator.Lint` falhou porque o achatamento das fontes
perdeu a ordem de compilação indicada pelo FuseSoC. O preparador foi corrigido
para separar includes e numerar as 141 fontes RTL na ordem original. Foram
preparados também 53 arquivos de include.

Na segunda tentativa:

- `Verilator.Lint`: executado;
- `Checker.LintTimingConstructs`: sem erros;
- `Checker.LintErrors`: sem erros;
- `Checker.LintWarnings`: 137 avisos não fatais;
- `Yosys.JsonHeader`: executado;
- `Yosys.Synthesis`: iniciado, mas não concluído.

## Causa do travamento

O array `sram[0:16383]`, correspondente a 16.384 palavras de 32 bits, não foi
associado a uma macro SRAM. O Yosys converteu a memória em registradores com
enable por byte e em uma grande rede de seleção. O log registrou:

```text
Computing hashes of 1678482 cells of `chipus_soc_top'.
...
Computing hashes of 1673466 cells of `chipus_soc_top'.
```

Durante a execução foram observados aproximadamente 189% de CPU e 2,24 GiB de
RAM; mais tarde, 101% de CPU e 4,29 GiB de RAM. O último ponto persistido foi o
passo `OPT_MERGE`, sem mensagem normal de término. Depois disso o WSL reiniciou,
o que encerrou o contêiner e a sessão de síntese.

Portanto, o travamento não foi causado pelo clone do Ibex/Croc, pelo firmware
ou pela simulação. Ele foi causado pela expansão física da SRAM comportamental
de 64 KiB durante a síntese.

## Correção preventiva

O parâmetro `SramWords` foi exposto no top-level. Seu valor padrão continua
sendo 16.384 palavras (64 KiB) para preservar o mapa funcional e os testes. O
`flow/config.yaml` define `SramWords=256`, ou 1 KiB, apenas para validar a
infraestrutura de síntese sem risco de nova explosão de células.

O formato de `SYNTH_PARAMETERS` foi conferido na instalação do LibreLane
3.1.0.dev3 presente na imagem. A regressão funcional após essa mudança passou,
mas a repetição da síntese reduzida não foi iniciada nesta sessão porque o bind
mount do repositório na imagem externa foi novamente bloqueado pelo controle de
execução. Portanto, a proteção está configurada, mas o novo run de síntese ainda
precisa ser concluído.

Esse resultado reduzido não serve para estimar área final. Antes de P&R e de
qualquer número de PPA ser apresentado como resultado do CHIPUS, é necessário
integrar uma macro SRAM compatível com SKY130 ou adotar uma interface de memória
externa explícita.

## Estado e próximos passos

1. Reexecutar a síntese reduzida e registrar contagem de células/área.
2. Selecionar e integrar a macro SRAM para o mapa de 64 KiB.
3. Rodar STA e P&R somente depois da macro estar modelada no LibreLane.
4. Implementar os periféricos ainda ausentes: RX/IRQ de UART, CLINT, debug e
   demais regiões que forem necessárias ao software.

Os artefatos incompletos da tentativa estão ignorados pelo Git em
`flow/runs/chipus-synth-20260914/`; eles preservam o log local do diagnóstico,
mas não constituem uma síntese aprovada.
