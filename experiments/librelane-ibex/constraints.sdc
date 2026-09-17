create_clock \
  -name clk_i \
  -period 50.0 \
  [get_ports clk_i]

set_clock_uncertainty 0.25 [get_clocks clk_i]
set_clock_transition 0.15 [get_clocks clk_i]

set input_ports [get_ports {
  instr_gnt_i
  instr_rvalid_i
  instr_rdata_i[*]
  instr_err_i
  data_gnt_i
  data_rvalid_i
  data_rdata_i[*]
  data_err_i
  irq_software_i
  irq_timer_i
  irq_external_i
  irq_fast_i[*]
  irq_nm_i
}]

set_input_delay 5.0 \
  -clock [get_clocks clk_i] \
  $input_ports

set_input_transition 0.15 $input_ports

set_output_delay 5.0 \
  -clock [get_clocks clk_i] \
  [all_outputs]

set_load 0.0334 [all_outputs]

set_input_delay 0.0 \
  -clock [get_clocks clk_i] \
  [get_ports rst_ni]

# Simplificação didática: exclui o reset assíncrono da STA funcional.
set_false_path -from [get_ports rst_ni]

set_max_transition 0.75 [current_design]
set_max_capacitance 0.20 [current_design]
set_max_fanout 10 [current_design]