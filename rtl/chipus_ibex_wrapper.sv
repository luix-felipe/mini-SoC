// Synthesis boundary for the official Ibex core in the CHIPUS project.
// The wrapper fixes the upstream "small" configuration and leaves the native
// instruction/data handshakes exposed for the future interconnect decision.
module chipus_ibex_wrapper #(
  parameter logic [31:0] BootAddr = 32'h0000_0000,
  parameter logic [31:0] HartId   = 32'h0000_0000
) (
  input  logic        clk_i,
  input  logic        rst_ni,

  output logic        instr_req_o,
  input  logic        instr_gnt_i,
  input  logic        instr_rvalid_i,
  output logic [31:0] instr_addr_o,
  input  logic [31:0] instr_rdata_i,
  input  logic        instr_err_i,

  output logic        data_req_o,
  input  logic        data_gnt_i,
  input  logic        data_rvalid_i,
  output logic        data_we_o,
  output logic [3:0]  data_be_o,
  output logic [31:0] data_addr_o,
  output logic [31:0] data_wdata_o,
  input  logic [31:0] data_rdata_i,
  input  logic        data_err_i,

  input  logic        irq_software_i,
  input  logic        irq_timer_i,
  input  logic        irq_external_i,
  input  logic [14:0] irq_fast_i,
  input  logic        irq_nm_i,

  output logic        alert_minor_o,
  output logic        alert_major_internal_o,
  output logic        alert_major_bus_o,
  output logic        core_sleep_o
);

  ibex_top #(
    .BaseIsa              (ibex_pkg::BaseIsaRV32I),
    .RV32E                (1'b0),
    .RV32M                (ibex_pkg::RV32MFast),
    .RV32B                (ibex_pkg::RV32BNone),
    .RV32ZC               (ibex_pkg::RV32Zca),
    .RegFile              (ibex_pkg::RegFileFF),
    .BranchTargetALU      (1'b0),
    .WritebackStage       (1'b0),
    .ICache               (1'b0),
    .ICacheECC            (1'b0),
    .ICacheScramble       (1'b0),
    .ICacheTweakInfection (1'b0),
    .BranchPredictor      (1'b0),
    .DbgTriggerEn         (1'b0),
    .SecureIbex           (1'b0),
    .MemECC               (1'b0),
    .PMPEnable            (1'b0),
    .PMPGranularity       (0),
    .PMPNumRegions        (4),
    .MHPMCounterNum       (0),
    .MHPMCounterWidth     (40)
  ) u_ibex_top (
    .clk_i                     (clk_i),
    .rst_ni                    (rst_ni),
    .test_en_i                 (1'b0),
    .scan_rst_ni               (1'b1),

    .ram_cfg_icache_tag_i      ('{default: prim_ram_1p_pkg::RAM_1P_CFG_REQ_DEFAULT}),
    .ram_cfg_icache_tag_o      (),
    .ram_cfg_icache_data_i     ('{default: prim_ram_1p_pkg::RAM_1P_CFG_REQ_DEFAULT}),
    .ram_cfg_icache_data_o     (),

    .cheriot_enable_i          (ibex_pkg::IbexMuBiOff),
    .hart_id_i                 (HartId),
    .boot_addr_i               (BootAddr),

    .instr_req_o               (instr_req_o),
    .instr_gnt_i               (instr_gnt_i),
    .instr_rvalid_i            (instr_rvalid_i),
    .instr_addr_o              (instr_addr_o),
    .instr_rdata_i             (instr_rdata_i),
    .instr_rdata_intg_i        ('0),
    .instr_err_i               (instr_err_i),

    .data_req_o                (data_req_o),
    .data_gnt_i                (data_gnt_i),
    .data_rvalid_i             (data_rvalid_i),
    .data_we_o                 (data_we_o),
    .data_be_o                 (data_be_o),
    .data_addr_o               (data_addr_o),
    .data_wdata_o              (data_wdata_o),
    .data_wdata_intg_o         (),
    .data_tag_o                (),
    .data_rdata_i              (data_rdata_i),
    .data_rdata_intg_i         ('0),
    .data_tag_i                (1'b0),
    .data_err_i                (data_err_i),

    .trvk_heap_base_addr_i     ('0),
    .trvk_revbm_req_o          (),
    .trvk_revbm_gnt_i          (1'b0),
    .trvk_revbm_rvalid_i       (1'b0),
    .trvk_revbm_addr_o         (),
    .trvk_revbm_rdata_i        ('0),
    .trvk_revbm_rdata_intg_i   ('0),
    .trvk_revbm_err_i          (1'b0),

    .irq_software_i            (irq_software_i),
    .irq_timer_i               (irq_timer_i),
    .irq_external_i            (irq_external_i),
    .irq_fast_i                (irq_fast_i),
    .irq_nm_i                  (irq_nm_i),

    .scramble_key_valid_i      (1'b0),
    .scramble_key_i            ('0),
    .scramble_nonce_i          ('0),
    .scramble_req_o            (),

    .debug_req_i               (1'b0),
    .crash_dump_o              (),
    .double_fault_seen_o       (),

    .fetch_enable_i            (ibex_pkg::IbexMuBiOn),
    .mcounteren_writable_i     (ibex_pkg::IbexMuBiOn),
    .alert_minor_o             (alert_minor_o),
    .alert_major_internal_o    (alert_major_internal_o),
    .alert_major_bus_o         (alert_major_bus_o),
    .core_sleep_o              (core_sleep_o),

    .lockstep_cmp_en_o         (),
    .data_req_shadow_o         (),
    .data_we_shadow_o          (),
    .data_be_shadow_o          (),
    .data_addr_shadow_o        (),
    .data_wdata_shadow_o       (),
    .data_wdata_intg_shadow_o  (),
    .instr_req_shadow_o        (),
    .instr_addr_shadow_o       ()
  );

endmodule
