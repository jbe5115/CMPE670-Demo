// receiver.v
// CMPE 670 Project Fall 2023
// Author(s):
//   Eric Falcone, John Evans
// Used for testing on a single FPGA

module top (
    // PC/FPGA INTERFACE
    input          i_clk,
    input          i_rst,
    input          i_uart_rx,
    input          i_arq_en,
    input          i_corrupt_en,
    input  [7:0]   i_corrupt_seed, 
    // outputs
    output         o_uart_tx,
    output [7:0]   o_crc_val_sen,
    output [7:0]   o_crc_val_rec
);

wire otn_rx_data;
wire otn_tx_ack;

sender sender_inst (
    .i_clk          (i_clk),
    .i_rst          (i_rst),
    .i_uart_rx      (i_uart_rx),
    .i_arq_en       (i_arq_en),
    .o_crc_val      (o_crc_val_sen),
    .o_otn_rx_data  (otn_rx_data),
    .i_otn_tx_ack   (otn_tx_ack)
);

receiver receiver_inst (
    .i_clk          (i_clk),
    .i_rst          (i_rst),
    .i_corrupt_en   (i_corrupt_en),
    .i_corrupt_seed (i_corrupt_seed),
    .o_uart_tx      (o_uart_tx),
    .o_crc_val      (o_crc_val_rec),
    .i_otn_tx_data  (otn_rx_data),
    .o_otn_rx_ack   (otn_tx_ack)
);


endmodule
