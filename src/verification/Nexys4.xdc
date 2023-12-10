# ==== Clock input ====
set_property PACKAGE_PIN E3 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clk]

## ==== Push Button ====
set_property PACKAGE_PIN M18 [get_ports i_rst]
set_property IOSTANDARD LVCMOS33 [get_ports i_rst]

set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports i_arq_en]

# ==== LEDs ====
set_property PACKAGE_PIN H17 [get_ports {o_crc_val[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val[0]}]
set_property PACKAGE_PIN K15 [get_ports {o_crc_val[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val[1]}]
set_property PACKAGE_PIN J13 [get_ports {o_crc_val[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val[2]}]
set_property PACKAGE_PIN N14 [get_ports {o_crc_val[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val[3]}]
set_property PACKAGE_PIN R18 [get_ports {o_crc_val[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val[4]}]
set_property PACKAGE_PIN V17 [get_ports {o_crc_val[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val[5]}]
set_property PACKAGE_PIN U17 [get_ports {o_crc_val[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val[6]}]
set_property PACKAGE_PIN U16 [get_ports {o_crc_val[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val[7]}]

# ==== UART ====
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports i_uart_rx]

# ==== I/O Transmission ====
#JA2
set_property PACKAGE_PIN D18 [get_ports i_otn_tx_ack]
set_property IOSTANDARD LVCMOS33 [get_ports i_otn_tx_ack]
#JA1
set_property PACKAGE_PIN C17 [get_ports o_otn_rx_data]
set_property IOSTANDARD LVCMOS33 [get_ports o_otn_rx_data]