# ==== Clock input ====
set_property PACKAGE_PIN E3 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clk]

## ==== Push Button ====
set_property PACKAGE_PIN M18 [get_ports i_rst]
set_property IOSTANDARD LVCMOS33 [get_ports i_rst]

set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports i_corrupt_en]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports i_arq_en]

# ==== LEDs ====

# Sender CRC
set_property PACKAGE_PIN H17 [get_ports {o_crc_val_sen[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_sen[0]}]
set_property PACKAGE_PIN K15 [get_ports {o_crc_val_sen[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_sen[1]}]
set_property PACKAGE_PIN J13 [get_ports {o_crc_val_sen[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_sen[2]}]
set_property PACKAGE_PIN N14 [get_ports {o_crc_val_sen[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_sen[3]}]
set_property PACKAGE_PIN R18 [get_ports {o_crc_val_sen[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_sen[4]}]
set_property PACKAGE_PIN V17 [get_ports {o_crc_val_sen[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_sen[5]}]
set_property PACKAGE_PIN U17 [get_ports {o_crc_val_sen[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_sen[6]}]
set_property PACKAGE_PIN U16 [get_ports {o_crc_val_sen[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_sen[7]}]

# Receiver CRC
set_property PACKAGE_PIN V16 [get_ports {o_crc_val_rec[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_rec[0]}]
set_property PACKAGE_PIN T15 [get_ports {o_crc_val_rec[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_rec[1]}]
set_property PACKAGE_PIN U14 [get_ports {o_crc_val_rec[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_rec[2]}]
set_property PACKAGE_PIN T16 [get_ports {o_crc_val_rec[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_rec[3]}]
set_property PACKAGE_PIN V15 [get_ports {o_crc_val_rec[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_rec[4]}]
set_property PACKAGE_PIN V14 [get_ports {o_crc_val_rec[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_rec[5]}]
set_property PACKAGE_PIN V12 [get_ports {o_crc_val_rec[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_rec[6]}]
set_property PACKAGE_PIN V11 [get_ports {o_crc_val_rec[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_val_rec[7]}]


# ==== UART ====
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports i_uart_rx]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports o_uart_tx]