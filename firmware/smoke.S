/* SPDX-License-Identifier: Apache-2.0 */
.section .text.start
.globl _start

.equ SRAM_TEST_ADDR, 0x10000100
.equ SOC_CTRL_BASE,  0x03000000
.equ UART_BASE,      0x03002000
.equ STATUS_OFFSET,  0x08
.equ UART_LSR,       0x14

_start:
  li sp, 0x10010000

  li t0, SRAM_TEST_ADDR
  li t1, 0x5a
  sw t1, 0(t0)
  lw t2, 0(t0)
  bne t1, t2, fail

uart_wait:
  li t0, UART_BASE
  lbu t1, UART_LSR(t0)
  andi t1, t1, 0x20
  beqz t1, uart_wait
  li t1, 'O'
  sb t1, 0(t0)

  li t0, SOC_CTRL_BASE
  li t1, 1
  sw t1, STATUS_OFFSET(t0)

done:
  wfi
  j done

fail:
  li t0, SOC_CTRL_BASE
  li t1, 0xdead
  sw t1, STATUS_OFFSET(t0)
  j done
