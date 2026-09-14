// SPDX-License-Identifier: Apache-2.0
module tb_chipus_soc;
  localparam int unsigned ClockHz = 1_000_000;
  localparam int unsigned Baud = 100_000;
  localparam int unsigned ClocksPerBit = ClockHz / Baud;

  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic uart_tx;
  logic [31:0] status;
  logic alert;
  logic core_sleep;
  logic [7:0] uart_byte;

  always #5 clk = !clk;

  chipus_soc_top #(
    .ClockHz (ClockHz),
    .Baud    (Baud)
  ) dut (
    .clk_i        (clk),
    .rst_ni       (rst_n),
    .uart_rx_i    (1'b1),
    .uart_tx_o    (uart_tx),
    .status_o     (status),
    .alert_o      (alert),
    .core_sleep_o (core_sleep)
  );

  initial begin : reset_and_timeout
    repeat (8) @(posedge clk);
    rst_n = 1'b1;

    repeat (10_000) begin
      @(posedge clk);
      if (status != 0) begin
        if (status != 32'd1) $fatal(1, "firmware reported failure: 0x%08x", status);
        if (alert) $fatal(1, "Ibex alert asserted");
        $display("[PASS] CHIPUS_SOC_SMOKE: reset, fetch, SRAM load/store and MMIO status");
        wait (uart_byte == 8'h4f);
        $display("[PASS] CHIPUS_UART_SMOKE: transmitted '%c'", uart_byte);
        $finish;
      end
    end
    $fatal(1, "timeout waiting for firmware status");
  end

  initial begin : uart_monitor
    uart_byte = '0;
    @(negedge uart_tx);
    repeat (ClocksPerBit + ClocksPerBit/2) @(posedge clk);
    for (int unsigned bit_idx = 0; bit_idx < 8; bit_idx++) begin
      uart_byte[bit_idx] = uart_tx;
      repeat (ClocksPerBit) @(posedge clk);
    end
    if (!uart_tx) $fatal(1, "UART stop bit missing");
  end

endmodule
