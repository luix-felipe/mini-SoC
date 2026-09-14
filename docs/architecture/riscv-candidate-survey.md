# Candidatos RISC-V

**Revisão:** 2026-09-10. **Decisão de CPU e interconexão:** aberta.

## Parecer atual

| Candidato | Vantagem | Limitação | Estado local |
| --- | --- | --- | --- |
| Croc/CVE2 | SoC com OBI, SRAM, decode e periféricos integrados | fluxo físico e SRAM de referência são IHP; smoke não termina | `BLOCKED` |
| Ibex oficial (`small`) | core maduro, configurável e com boa infraestrutura de DV | não fornece o SoC pretendido; fabric e periféricos são externos | `SMOKE-PASS` |

Croc/CVE2 continua como candidato principal; Ibex é fallback funcional. O
protocolo de interconexão ainda não foi congelado.

## Evidência local

Ambiente: `isaiassh/unic-cass-tools:1.1.0`, Verilator 5.026.

| Gate | Resultado |
| --- | --- |
| `ibex_top` | elaborado com 144 módulos (`PASS`) |
| Ibex Simple System | `Hello simple system`, halt por software, 261 instruções (`SMOKE-PASS`) |
| Croc RTL | modelo completo compilado com 211 módulos (`PASS`) |
| Croc funcional | JTAG/SRAM e UART exercitados; instrução ilegal repetida e sem término (`BLOCKED`) |
| Síntese/STA SKY130 | não executada |

Comandos e logs resumidos: [qualificação dos cores](../../experiments/riscv-core-qualification/README.md).

## Interfaces relevantes

Ibex e CVE2 expõem portas separadas de instruções e dados com handshake de
requisição, concessão e resposta. O Croc adapta o CVE2 para OBI e já fornece
arbitragem, decode, error slave, SRAM e periféricos.

O Croc de referência possui 4 KiB de SRAM em dois bancos; a meta lógica do
CHIPUS é 64 KiB e exigirá novo mapa, linker e macro/wrapper SKY130.

## Direção de integração

1. qualificar primeiro o Croc/CVE2 com seu caminho OBI nativo;
2. manter o Ibex como alternativa atrás de um wrapper;
3. definir o interconnect somente depois de entender interfaces, decode,
   arbitragem e periféricos do Croc.

## Próximos gates

1. reproduzir o Croc com toolchain suportada e obter término determinístico;
2. rodar `print_config` e testes de periféricos do Croc;
3. criar um top-level com wrapper de CPU, sem fixar barramento prematuramente;
4. comparar Ibex e CVE2 com ISA, memória, clock e constraints equivalentes;
5. sintetizar ambos com `sky130_fd_sc_hd` antes de congelar a CPU.

Revisões e licenças: [manifesto de IPs](../ip-manifest.md). Plano de testes:
[cores RISC-V](../verification/riscv-core-test-plan.md).
