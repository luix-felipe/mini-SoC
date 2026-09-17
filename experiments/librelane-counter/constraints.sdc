# Clock principal: período de 50 ns = 20 MHz
create_clock \
  -name clk_i \
  -period 50.0 \
  [get_ports clk_i]

# Margem reservada para variações e incerteza do clock
set_clock_uncertainty 0.25 [get_clocks clk_i]

# Transição esperada na entrada do clock
set_clock_transition 0.15 [get_clocks clk_i]

# enable_i pode chegar até 5 ns depois da borda externa do clock
set_input_delay 5.0 \
  -clock [get_clocks clk_i] \
  [get_ports enable_i]

# O ambiente externo precisa de 5 ns para receber count_o
set_output_delay 5.0 \
  -clock [get_clocks clk_i] \
  [get_ports {count_o[*]}]

# Carga capacitiva estimada em cada saída, em pF
set_load 0.0334 [get_ports {count_o[*]}]

# Reset assíncrono não participa dos caminhos funcionais de timing
set_false_path -from [get_ports rst_ni]

# Limites elétricos
set_max_transition 0.75 [current_design]
set_max_capacitance 0.20 [current_design]
set_max_fanout 10 [current_design]