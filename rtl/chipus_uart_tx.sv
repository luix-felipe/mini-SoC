// SPDX-License-Identifier: Apache-2.0
module chipus_uart_tx #(
  parameter int unsigned ClockHz = 20_000_000,
  parameter int unsigned Baud    = 115_200
) (
  input  logic       clk_i,
  input  logic       rst_ni,
  input  logic       valid_i,
  input  logic [7:0] data_i,
  output logic       ready_o,
  output logic       tx_o
);
  localparam int unsigned ClocksPerBit = (ClockHz / Baud) > 0 ? (ClockHz / Baud) : 1;
  localparam int unsigned CounterWidth = ClocksPerBit > 1 ? $clog2(ClocksPerBit) : 1;

  logic [9:0] shift_q;
  logic [3:0] bit_count_q;
  logic [CounterWidth-1:0] clock_count_q;
  logic busy_q;

  assign ready_o = !busy_q;
  assign tx_o    = busy_q ? shift_q[0] : 1'b1;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      shift_q       <= 10'h3ff;
      bit_count_q   <= '0;
      clock_count_q <= '0;
      busy_q        <= 1'b0;
    end else if (valid_i && ready_o) begin
      shift_q       <= {1'b1, data_i, 1'b0};
      bit_count_q   <= '0;
      clock_count_q <= CounterWidth'(ClocksPerBit - 1);
      busy_q        <= 1'b1;
    end else if (busy_q) begin
      if (clock_count_q == '0) begin
        clock_count_q <= CounterWidth'(ClocksPerBit - 1);
        if (bit_count_q == 4'd9) begin
          busy_q <= 1'b0;
        end else begin
          shift_q     <= {1'b1, shift_q[9:1]};
          bit_count_q <= bit_count_q + 1'b1;
        end
      end else begin
        clock_count_q <= clock_count_q - 1'b1;
      end
    end
  end
endmodule
