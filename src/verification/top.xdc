# ==== Clock input ====
set_property PACKAGE_PIN E3 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clk]

## ==== Push Button ====
set_property PACKAGE_PIN M18 [get_ports i_rst]
set_property IOSTANDARD LVCMOS33 [get_ports i_rst]

set_property PACKAGE_PIN M17 [get_ports i_retrans_en]
set_property IOSTANDARD LVCMOS33 [get_ports i_retrans_en]

## ==== Switches ====

set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports i_corrupt_en]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports i_arq_en]

set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {i_corrupt_seed[7]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {i_corrupt_seed[6]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {i_corrupt_seed[5]}]
set_property -dict {PACKAGE_PIN H6  IOSTANDARD LVCMOS33} [get_ports {i_corrupt_seed[4]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {i_corrupt_seed[3]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {i_corrupt_seed[2]}]
set_property -dict {PACKAGE_PIN U8  IOSTANDARD LVCMOS33} [get_ports {i_corrupt_seed[1]}]
set_property -dict {PACKAGE_PIN T8  IOSTANDARD LVCMOS33} [get_ports {i_corrupt_seed[0]}]

# ==== LEDs ====

# RGB LEDs
set_property PACKAGE_PIN G14 [get_ports {o_retrans_wait}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_retrans_wait}]

set_property PACKAGE_PIN N15 [get_ports {o_crc_err}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_crc_err}]

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

# These next few properties ASSURE that the system works properly :)))
set_property PACKAGE_PIN D14 [get_ports {o_rt_state[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_rt_state[0]}]
set_property PACKAGE_PIN F16 [get_ports {o_rt_state[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_rt_state[1]}]
set_property PACKAGE_PIN G16 [get_ports {o_rt_state[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_rt_state[2]}]

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

# These next few properties ASSURE that the system works properly :)))
set_property PACKAGE_PIN C17 [get_ports {o_tr_state[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_tr_state[0]}]
set_property PACKAGE_PIN D18 [get_ports {o_tr_state[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_tr_state[1]}]
set_property PACKAGE_PIN E18 [get_ports {o_tr_state[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_tr_state[2]}]




# ==== UART ====
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports i_uart_rx]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports o_uart_tx]