# Experimentos de arquitetura

Este diretório guarda testes reproduzíveis de qualificação. Um `SMOKE-PASS`
comprova somente o caminho exercitado, não a integração final do SoC.

| Experimento | Estado | Resultado comprovado |
| --- | --- | --- |
| [`riscv-core-qualification`](riscv-core-qualification/README.md) | Ibex `SMOKE-PASS`; Croc `BLOCKED` | compila o `ibex_top`, executa o Simple System e reproduz separadamente o build/smoke do Croc com criterios objetivos de passe |
