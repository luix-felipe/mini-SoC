set ::env(STEP_ID) OpenROAD.TapEndcapInsertion
set ::env(TECH_LEF) /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
set ::env(MACRO_LEFS) ""
set ::env(VDD_PIN) VPWR
set ::env(GND_PIN) VGND
set ::env(TECH_LEFS) "\"nom_*\" /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef \"min_*\" /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__min.tlef \"max_*\" /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__max.tlef"
set ::env(PRIMARY_GDSII_STREAMOUT_TOOL) magic
set ::env(DEFAULT_CORNER) nom_tt_025C_1v80
set ::env(STA_CORNERS) "nom_tt_025C_1v80 nom_ss_100C_1v60 nom_ff_n40C_1v95 min_tt_025C_1v80 min_ss_100C_1v60 min_ff_n40C_1v95 max_tt_025C_1v80 max_ss_100C_1v60 max_ff_n40C_1v95"
set ::env(RT_MIN_LAYER) met1
set ::env(RT_MAX_LAYER) met5
set ::env(SCL_GROUND_PINS) "VGND VNB"
set ::env(SCL_POWER_PINS) "VPWR VPB"
set ::env(TRISTATE_CELLS) "\"sky130_fd_sc_hd__ebuf*\""
set ::env(FILL_CELLS) "\"sky130_fd_sc_hd__fill*\""
set ::env(DECAP_CELLS) "sky130_ef_sc_hd__decap_12 sky130_fd_sc_hd__decap_8 sky130_fd_sc_hd__decap_6 sky130_fd_sc_hd__decap_4 sky130_fd_sc_hd__decap_3"
set ::env(LIB) "\"*_tt_025C_1v80\" /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib \"*_ss_100C_1v60\" /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib \"*_ff_n40C_1v95\" /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95.lib"
set ::env(CELL_LEFS) "/opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_ef_sc_hd.lef /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
set ::env(CELL_GDS) /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds
set ::env(CELL_VERILOG_MODELS) "/opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
set ::env(CELL_BB_VERILOG_MODELS) "/opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd__blackbox.v /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd__blackbox_pp.v"
set ::env(CELL_SPICE_MODELS) "/opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__decap_12.spice /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__fill_12.spice /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__fill_4.spice /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__fill_8.spice /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice"
set ::env(CELL_CDLS) /opt/pdks/sky130A/libs.ref/sky130_fd_sc_hd/cdl/sky130_fd_sc_hd.cdl
set ::env(SYNTH_EXCLUDED_CELL_FILE) /opt/pdks/sky130A/libs.tech/openlane/sky130_fd_sc_hd/no_synth.cells
set ::env(PNR_EXCLUDED_CELL_FILE) /opt/pdks/sky130A/libs.tech/openlane/sky130_fd_sc_hd/drc_exclude.cells
set ::env(OUTPUT_CAP_LOAD) 33.442
set ::env(MAX_FANOUT_CONSTRAINT) 10
set ::env(MAX_TRANSITION_CONSTRAINT) 0.75
set ::env(MAX_CAPACITANCE_CONSTRAINT) 0.2
set ::env(CLOCK_UNCERTAINTY_CONSTRAINT) 0.25
set ::env(CLOCK_TRANSITION_CONSTRAINT) 0.1499999999999999944488848768742172978818416595458984375
set ::env(TIME_DERATING_CONSTRAINT) 5
set ::env(IO_DELAY_CONSTRAINT) 20
set ::env(SYNTH_DRIVING_CELL) sky130_fd_sc_hd__inv_2/Y
set ::env(SYNTH_TIEHI_CELL) sky130_fd_sc_hd__conb_1/HI
set ::env(SYNTH_TIELO_CELL) sky130_fd_sc_hd__conb_1/LO
set ::env(SYNTH_BUFFER_CELL) sky130_fd_sc_hd__buf_2/A/X
set ::env(PLACE_SITE) unithd
set ::env(CELL_PAD_EXCLUDE) "\"sky130_fd_sc_hd__tap*\" \"sky130_fd_sc_hd__decap*\" \"sky130_ef_sc_hd__decap*\" \"sky130_fd_sc_hd__fill*\""
set ::env(DIODE_CELL) sky130_fd_sc_hd__diode_2/DIODE
set ::env(WELLTAP_CELL) sky130_fd_sc_hd__tapvpwrvgnd_1
set ::env(ENDCAP_CELL) sky130_fd_sc_hd__decap_3
set ::env(DESIGN_NAME) chipus_ibex_wrapper
set ::env(CLOCK_PERIOD) 50.0
set ::env(CLOCK_PORT) clk_i
set ::env(DIE_AREA) "0 0 750 750"
set ::env(FALLBACK_SDC) /nix/store/00bhxv2bix0rv6lm4qlsyj0bva6cl0nn-python3.13-librelane-3.0.0rc1/lib/python3.13/site-packages/librelane/scripts/base.sdc
set ::env(PAD_EDGE_SPACING) 0
set ::env(SET_RC_VERBOSE) 0
set ::env(PDN_CONNECT_MACROS_TO_GRID) 1
set ::env(PDN_ENABLE_GLOBAL_CONNECTIONS) 1
set ::env(PNR_SDC_FILE) /home/designer/shared/chipus-soc/mini-SoC/experiments/librelane-ibex/constraints.sdc
set ::env(DEDUPLICATE_CORNERS) 0
set ::env(FP_TAPCELL_DIST) 13
set ::env(FP_MACRO_HORIZONTAL_HALO) 10
set ::env(FP_MACRO_VERTICAL_HALO) 10
set ::env(CURRENT_ODB) /home/designer/shared/chipus-soc/mini-SoC/experiments/librelane-ibex/runs/ibex-global-placement/18-openroad-cutrows/chipus_ibex_wrapper.odb
set ::env(SAVE_ODB) /home/designer/shared/chipus-soc/mini-SoC/experiments/librelane-ibex/runs/ibex-global-placement/19-openroad-tapendcapinsertion/chipus_ibex_wrapper.odb
set ::env(SAVE_DEF) /home/designer/shared/chipus-soc/mini-SoC/experiments/librelane-ibex/runs/ibex-global-placement/19-openroad-tapendcapinsertion/chipus_ibex_wrapper.def
set ::env(SAVE_SDC) /home/designer/shared/chipus-soc/mini-SoC/experiments/librelane-ibex/runs/ibex-global-placement/19-openroad-tapendcapinsertion/chipus_ibex_wrapper.sdc
set ::env(SAVE_NL) /home/designer/shared/chipus-soc/mini-SoC/experiments/librelane-ibex/runs/ibex-global-placement/19-openroad-tapendcapinsertion/chipus_ibex_wrapper.nl.v
set ::env(SAVE_PNL) /home/designer/shared/chipus-soc/mini-SoC/experiments/librelane-ibex/runs/ibex-global-placement/19-openroad-tapendcapinsertion/chipus_ibex_wrapper.pnl.v
