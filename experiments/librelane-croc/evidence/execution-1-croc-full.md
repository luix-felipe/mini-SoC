# Execução 1 — Croc/CVE2 até GDSII (`croc-full`)

Origem: execução realizada na outra máquina e registrada pelo operador.  
Status: **CANDIDATE; fluxo físico completo reportado, sem signoff elétrico**.

## Identificação

- Croc: commit `968bab17b37e88d9200a0899cb9181e42850ec87`
- CVE2 selecionado pelo Croc: commit `53076d64c97685b1d2f5d07cd7f5cc439cf1f351`
- top-level: `core_wrap`
- tecnologia: `sky130A`
- biblioteca: `sky130_fd_sc_hd`
- período de clock: 50 ns
- tag final: `croc-full`

## Comando final

Executado na raiz de `mini-SoC`, dentro do ambiente UNIC-CASS:

```bash
LL=/home/designer/shared/bin/librelane-local

"$LL" --run-tag croc-full \
  experiments/librelane-croc/config.yaml
```

## Resultado recebido

```text
[15:26:17] INFO     Flow complete.
Classic - Stage 80 - Report Manufacturability 80/80 0:19:59
[15:26:17] WARNING  [Checker.MaxSlewViolations] Max Slew violations found in all nine analyzed corners.
[15:26:17] WARNING  [Checker.MaxCapViolations] Max Cap violations found in six analyzed corners.
```

O indicador do LibreLane registrou 19 min 59 s. Como esta execução não usou
`/usr/bin/time -v`, não há medição equivalente de tempo de parede, RSS ou swap.

## Resultados finais desta execução

| Item | Resultado |
| --- | ---: |
| GDSII | gerado como `final/gds/core_wrap.gds` |
| DRC interno do roteador | 0 |
| DRC Magic / KLayout | 0 / 0 |
| Erros/diferenças LVS | 0 |
| Antena final — redes/pinos | 0 / 0 |
| Violações de setup/hold | 0 / 0 em 9 cantos |
| Pior slack de setup | +6,498 ns |
| Pior slack de hold | +0,109 ns |
| Pior contagem de slew | 5.104 (`max_ss_100C_1v60`) |
| Pior contagem de capacitância | 66 (`max_ss_100C_1v60`) |
| Cantos reprovados em slew/capacitância | 9 / 6 |
| Violações de fanout | 6 |
| Diodos de antena inseridos | 51 |
| Warnings de lint | 316 |

## Etapas incrementais registradas

| Etapa | Tag | Resultado recebido |
| --- | --- | --- |
| Frontend | `croc-frontend` | `Flow complete`; 316 warnings |
| Síntese | `croc-synth` | `Flow complete` |
| STA pré-PnR | `croc-sta-prepnr` | `Flow complete` em 2 min 37 s |
| Floorplan | `croc-floorplan` | 8.957 células, 118.392 µm² e 22,07% de utilização |
| PDN | `croc-pdn` | `Flow complete` em 2 min 23 s |
| Placement | `croc-placement` | `Flow complete` em 3 min 01 s |
| CTS | `croc-cts` | `Flow complete` em 3 min 19 s |
| STA pós-CTS | `croc-postcts` | `Flow complete` em 4 min 06 s |
| Roteamento global | `croc-global-routing` | `Flow complete` em 4 min 12 s |
| Roteamento detalhado | `croc-detailed-routing` | `Flow complete` em 12 min 56 s |
| Fluxo completo | `croc-full` | GDSII e checkers finais em 19 min 59 s |

## Avisos e limitações desta execução

- `Yosys.EQY` foi pulado; equivalência formal RTL versus netlist não foi feita.
- `VSRC_LOC_FILES` não foi definido; IR drop não foi qualificado.
- Slew, capacitância e fanout não fecharam.
- Foram reportados `STA-1140`, `RSZ-0020`, `GRT-0243` e `DRT-0349`.
- O checker de fios longos foi pulado por falta de threshold.
- Nove pinos de entrada foram reportados sem informação de gate de antena.
- Os 316 warnings de lint não foram classificados por tipo nesse run.

O diretório `runs/croc-full/` não está disponível nesta worktree, pois os runs
são ignorados pelo Git. Portanto, este relatório preserva a evidência recebida,
mas seus arquivos intermediários e `metrics.json` não podem ser reabertos aqui.

## Conclusão exclusiva da execução 1

O run reportou viabilidade RTL-to-GDSII e aprovação de DRC, LVS, antena,
setup e hold. Ele não comprova signoff elétrico, equivalência formal,
funcionamento pós-layout nem integração do SoC.
