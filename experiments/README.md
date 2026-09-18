# Experimentos de arquitetura

Este diretório guarda testes reproduzíveis de qualificação. Um `SMOKE-PASS`
comprova somente o caminho exercitado, não a integração final do SoC.

| Experimento | Estado | Resultado comprovado |
| --- | --- | --- |
| [`librelane-counter`](librelane-counter/README.md) | `SMOKE-PASS` | RTL até GDSII em SKY130A, SDC próprio, STA/DRC/LVS/antena sem violações finais |
| [`librelane-ibex`](librelane-ibex/README.md) | `CANDIDATE` (sem signoff) | Passos 1–15 executados até GDSII em SKY130A; DRC/LVS/antena aprovados; setup/slew/capacitância pendentes; visualização ainda não confirmada |
| [`riscv-core-qualification`](riscv-core-qualification/README.md) | Ibex `SMOKE-PASS`; Croc `BLOCKED` | compila o `ibex_top`, executa o Simple System e reproduz separadamente o build/smoke do Croc com criterios objetivos de passe |
