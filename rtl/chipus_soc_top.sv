// SPDX-License-Identifier: Apache-2.0
// First synthesizable CHIPUS top-level: Ibex, unified SRAM and minimal MMIO.
module chipus_soc_top #(
  parameter int unsigned ClockHz = 20_000_000,
  parameter int unsigned Baud    = 115_200,
  parameter string       MemFile = "",
  parameter int unsigned SramWords = chipus_addr_map_pkg::SramSizeBytes / 4
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        uart_rx_i,
  output logic        uart_tx_o,
  output logic [31:0] status_o,
  output logic        alert_o,
  output logic        core_sleep_o
);
  import chipus_addr_map_pkg::*;

  localparam logic [31:0] ImplementedSramEndAddr =
      SramBaseAddr + (SramWords * 4);
  localparam logic [7:0] ImplementedWordsPerBank64 = 8'(SramWords / 128);
  localparam logic [31:0] ImplementedSocInfo = {
    4'h1, 1'b0, 3'b000,
    3'b001, 1'b0, 4'b0000,
    3'd2, ImplementedWordsPerBank64, 5'b00000
  };

  logic [31:0] sram [0:SramWords-1];

  logic        instr_req;
  logic        instr_gnt;
  logic        instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;
  logic        instr_err;

  logic        data_req;
  logic        data_gnt;
  logic        data_rvalid;
  logic        data_we;
  logic [3:0]  data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;
  logic        data_err;

  logic alert_minor;
  logic alert_major_internal;
  logic alert_major_bus;

  logic instr_in_sram;
  logic data_in_sram;
  logic data_in_soc_ctrl;
  logic data_in_uart;
  logic uart_tx_ready;
  logic uart_tx_valid;
  logic [7:0] uart_lcr_q;
  logic [7:0] uart_dll_q;
  logic [7:0] uart_dlm_q;
  logic [7:0] uart_mcr_q;
  logic [31:0] status_q;

  wire unused_uart_rx = uart_rx_i;

  assign instr_in_sram    = in_range(instr_addr, SramBaseAddr, ImplementedSramEndAddr);
  assign data_in_sram     = in_range(data_addr, SramBaseAddr, ImplementedSramEndAddr);
  assign data_in_soc_ctrl = in_range(data_addr, SocCtrlBaseAddr, SocCtrlEndAddr);
  assign data_in_uart     = in_range(data_addr, UartBaseAddr, UartEndAddr);

  // Data has priority over instruction fetch when both access the unified SRAM.
  // MMIO writes to the transmit register wait until the UART can accept a byte.
  always_comb begin
    data_gnt = data_req;
    if (data_in_uart && data_we && (data_addr[4:2] == 3'd0) && !uart_lcr_q[7]) begin
      data_gnt = data_req && uart_tx_ready;
    end
    instr_gnt = instr_req && !data_req;
  end

  assign uart_tx_valid = data_req && data_gnt && data_we && data_in_uart &&
                         (data_addr[4:2] == 3'd0) && !uart_lcr_q[7];

  chipus_uart_tx #(
    .ClockHz (ClockHz),
    .Baud    (Baud)
  ) u_uart_tx (
    .clk_i,
    .rst_ni,
    .valid_i (uart_tx_valid),
    .data_i  (data_wdata[7:0]),
    .ready_o (uart_tx_ready),
    .tx_o    (uart_tx_o)
  );

`ifndef SYNTHESIS
  string runtime_mem_file;
  initial begin
    if ($value$plusargs("meminit=%s", runtime_mem_file)) begin
      $readmemh(runtime_mem_file, sram);
    end else if (MemFile != "") begin
      $readmemh(MemFile, sram);
    end
  end
`endif

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      instr_rvalid <= 1'b0;
      instr_rdata  <= '0;
      instr_err    <= 1'b0;
      data_rvalid  <= 1'b0;
      data_rdata   <= '0;
      data_err     <= 1'b0;
      status_q     <= '0;
      uart_lcr_q   <= 8'h03;
      uart_dll_q   <= 8'h01;
      uart_dlm_q   <= 8'h00;
      uart_mcr_q   <= 8'h00;
    end else begin
      instr_rvalid <= 1'b0;
      data_rvalid  <= 1'b0;

      if (instr_req && instr_gnt) begin
        instr_rvalid <= 1'b1;
        instr_err    <= !instr_in_sram;
        instr_rdata  <= instr_in_sram ? sram[(instr_addr - SramBaseAddr) >> 2] : 32'hbadd_cafe;
      end

      if (data_req && data_gnt) begin
        data_rvalid <= 1'b1;
        data_err    <= 1'b0;
        data_rdata  <= '0;

        if (data_in_sram) begin
          data_rdata <= sram[(data_addr - SramBaseAddr) >> 2];
          if (data_we) begin
            for (int unsigned byte_idx = 0; byte_idx < 4; byte_idx++) begin
              if (data_be[byte_idx]) begin
                sram[(data_addr - SramBaseAddr) >> 2][byte_idx*8 +: 8] <=
                  data_wdata[byte_idx*8 +: 8];
              end
            end
          end
        end else if (data_in_soc_ctrl) begin
          unique case (data_addr[11:0])
            SocCtrlBootAddrOffset: data_rdata <= BootBaseAddr;
            SocCtrlFetchEnOffset:  data_rdata <= 32'd1;
            SocCtrlStatusOffset: begin
              data_rdata <= status_q;
              if (data_we) status_q <= data_wdata;
            end
            SocCtrlInfoOffset: data_rdata <= ImplementedSocInfo;
            default: data_err <= 1'b1;
          endcase
        end else if (data_in_uart) begin
          unique case (data_addr[4:2])
            3'd0: begin
              if (uart_lcr_q[7]) begin
                data_rdata <= {24'd0, uart_dll_q};
                if (data_we) uart_dll_q <= data_wdata[7:0];
              end
            end
            3'd1: begin
              if (uart_lcr_q[7]) begin
                data_rdata <= {24'd0, uart_dlm_q};
                if (data_we) uart_dlm_q <= data_wdata[7:0];
              end
            end
            3'd3: begin
              data_rdata <= {24'd0, uart_lcr_q};
              if (data_we) uart_lcr_q <= data_wdata[7:0];
            end
            3'd4: begin
              data_rdata <= {24'd0, uart_mcr_q};
              if (data_we) uart_mcr_q <= data_wdata[7:0];
            end
            3'd5: data_rdata <= {24'd0, 1'b0, uart_tx_ready, uart_tx_ready, 5'b0};
            default: data_rdata <= '0;
          endcase
        end else begin
          data_err <= 1'b1;
          data_rdata <= 32'hbadd_cafe;
        end
      end
    end
  end

  assign status_o = status_q;
  assign alert_o  = alert_minor | alert_major_internal | alert_major_bus;

  chipus_ibex_wrapper #(
    .BootAddr (BootBaseAddr),
    .HartId   (32'd0)
  ) u_cpu (
    .clk_i,
    .rst_ni,
    .instr_req_o              (instr_req),
    .instr_gnt_i              (instr_gnt),
    .instr_rvalid_i           (instr_rvalid),
    .instr_addr_o             (instr_addr),
    .instr_rdata_i            (instr_rdata),
    .instr_err_i              (instr_err),
    .data_req_o               (data_req),
    .data_gnt_i               (data_gnt),
    .data_rvalid_i            (data_rvalid),
    .data_we_o                (data_we),
    .data_be_o                (data_be),
    .data_addr_o              (data_addr),
    .data_wdata_o             (data_wdata),
    .data_rdata_i             (data_rdata),
    .data_err_i               (data_err),
    .irq_software_i           (1'b0),
    .irq_timer_i              (1'b0),
    .irq_external_i           (1'b0),
    .irq_fast_i               ('0),
    .irq_nm_i                 (1'b0),
    .alert_minor_o            (alert_minor),
    .alert_major_internal_o   (alert_major_internal),
    .alert_major_bus_o        (alert_major_bus),
    .core_sleep_o
  );

endmodule
