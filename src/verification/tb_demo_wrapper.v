module tb_demo_wrapper (
    input i_clk,
    input i_rst, 
    input i_uart_rx,
    input i_arq_en,
    input i_corrupt_en,
    output o_uart_tx
);

reg crc_val_transmit;
reg crc_val_reciever;

reg crc_val_sender      [7:0];
reg crc_val_transmit    [7:0];

wire trans_data;
wire trans_ack;


sender sender_inst (
    // PC/FPGA INTERFACE
    .i_clk          (i_clk),
    .i_rst          (i_rst),
    .i_uart_rx      (i_uart_rx),

    .i_arq_en       (i_arq_en),
    .i_corrupt_en   (i_corrupt_en),

    .o_crc_val      (crc_val_sender),
    
    // TRANSMIT INTERFACE
    .o_otn_rx_data  (trans_data),
    .i_otn_tx_ack   (trans_ack)
);




receiver reciever_inst (
    // PC/FPGA INTERFACE
    .i_clk          (i_clk),
    .i_rst          (i_rst),
    .o_uart_tx      (o_uart_tx),

    .i_arq_en       (), 

    .o_crc_val      (crc_val_transmit),
    // TRANSMIT INTERFACE
    .i_otn_tx_data  (trans_data),
    .o_otn_rx_ack   (trans_ack)
);






endmodule;