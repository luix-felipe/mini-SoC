# Top-level mínimo do CHIPUS

O primeiro top-level integra o Ibex fixado na revisão `8b8ee086`, uma SRAM
unificada de 64 KiB, um registrador de status e uma UART TX mínima. O mapa usa
as mesmas regiões arquiteturais do Croc sem depender dos seus pacotes RTL.

## Mapa de endereços

| Região | Início | Fim exclusivo | Estado |
| --- | --- | --- | --- |
| SoC Control | `0x0300_0000` | `0x0300_1000` | mínimo implementado |
| UART | `0x0300_2000` | `0x0300_3000` | TX e registros mínimos |
| SRAM | `0x1000_0000` | `0x1001_0000` | 64 KiB unificados |

O Ibex forma o PC de reset como `{BootAddr[31:8], 8'h80}`. Portanto,
`BootAddr=0x1000_0000` produz a entrada `0x1000_0080`; o linker reserva esse
deslocamento explicitamente.

## SoC Control

| Offset | Acesso | Conteúdo |
| --- | --- | --- |
| `0x00` | leitura | base de boot |
| `0x04` | leitura | fetch habilitado |
| `0x08` | leitura/escrita | status do firmware |
| `0x14` | leitura | versão, core Ibex e organização lógica da SRAM |

O firmware smoke escreve `1` em `STATUS`; `0xDEAD` indica falha no teste de
SRAM.

## Limites atuais

- instruções e dados arbitram uma única SRAM, com prioridade para dados;
- UART implementa somente transmissão 8N1 e o subconjunto de registradores
  necessário para polling; RX e interrupções ainda não estão implementados;
- CLINT, debug, GPIO, DMA e região de aceleradores permanecem reservados;
- a SRAM é memória RTL inferida. A simulação usa 64 KiB, enquanto o gate
  LibreLane reduz `SramWords` para 256 palavras (1 KiB), evitando esgotar o
  WSL. Antes do fechamento físico, substituir por uma macro SRAM SKY130 ou
  definir uma estratégia explícita de memória;
- o `config.yaml` é uma infraestrutura inicial. Resultados físicos só passam a
  ser evidência depois de síntese, STA e implementação concluírem na imagem
  UNIC-CASS.

## Regressão

Na raiz que contém `mini-SoC/` e `ip-candidates/`:

```bash
make -C pipe-clean chipus-soc-smoke
```

O gate compila firmware RV32IMC, elabora o Ibex e o top-level e comprova reset,
fetch, load/store, status MMIO e transmissão UART.
