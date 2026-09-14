# Manifesto de IPs avaliados

Este arquivo registra origem, revisão e estado; não significa aprovação para
importação. Clones ficam em `$WORKSPACE/ip-candidates/`, fora do Git do
`mini-SoC`.

| Item | Revisão | Licença observada | Estado/uso |
| --- | --- | --- | --- |
| [Croc](https://github.com/pulp-platform/croc) | `968bab17` | SHL-0.51 no hardware | candidato principal; `BLOCKED` no smoke |
| [CVE2](https://github.com/openhwgroup/cve2) do Croc | `53076d64` | Apache-2.0 | herda avaliação do Croc |
| [Ibex](https://github.com/lowRISC/ibex) | `8b8ee086` | Apache-2.0 + `NOTICE` | fallback; `SMOKE-PASS` |

Antes de importar um IP: confirmar licença, fixar revisão, obter smoke pass,
preservar cabeçalhos, registrar patches e criar teste pelo caminho real do SoC.

Dependências principais do Ibex: FuseSoC 2.4.3, Verilator, toolchain RISC-V,
`libelf` e `srecord`. O Croc usa Bender e dependências vendorizadas registradas
no próprio `Bender.yml`.
