// SPDX-License-Identifier: Apache-2.0
// Minimal CHIPUS memory map, derived from the architectural regions used by Croc.
package chipus_addr_map_pkg;
  localparam logic [31:0] BootBaseAddr    = 32'h1000_0000;
  localparam logic [31:0] BootEntryAddr   = BootBaseAddr + 32'h0000_0080;
  localparam logic [31:0] SramBaseAddr    = 32'h1000_0000;
  localparam logic [31:0] SramSizeBytes   = 32'h0001_0000;
  localparam logic [31:0] SramEndAddr     = SramBaseAddr + SramSizeBytes;

  localparam logic [31:0] SocCtrlBaseAddr = 32'h0300_0000;
  localparam logic [31:0] SocCtrlEndAddr  = 32'h0300_1000;
  localparam logic [31:0] UartBaseAddr    = 32'h0300_2000;
  localparam logic [31:0] UartEndAddr     = 32'h0300_3000;

  localparam logic [11:0] SocCtrlBootAddrOffset = 12'h000;
  localparam logic [11:0] SocCtrlFetchEnOffset  = 12'h004;
  localparam logic [11:0] SocCtrlStatusOffset   = 12'h008;
  localparam logic [11:0] SocCtrlInfoOffset     = 12'h014;

  function automatic logic in_range(
    input logic [31:0] addr,
    input logic [31:0] start_addr,
    input logic [31:0] end_addr
  );
    return (addr >= start_addr) && (addr < end_addr);
  endfunction
endpackage
