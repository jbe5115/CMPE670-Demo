// receiver.v
// CMPE 670 Project Fall 2023
// Author(s):
//   John Evans
module receiver (
    // PC/FPGA INTERFACE
    input    i_clk,
    input    i_rst,
    output   o_uart_tx,
    input    i_arq_en,
    output   o_crc_val,
    // TRANSMIT INTERFACE
    input    i_otn_tx_data,
    input    o_otn_rx_ack
);

    // UART clock control
    reg  [11:0]  scount12;
    wire         sclk_en_16_x_baud;
    
    // TX FIFO -> UART TX
    wire [7:0]   tx_data;
    wire         tx_data_valid;
    wire         tx_data_ready;
    
    // DEMAPPER ->  TX FIFO
    wire [7:0]   demap_pyld_data;
    wire         demap_pyld_data_valid;
    wire         demap_pyld_fifo_ready; // go to rec_tran
    
    // Serial receiver & ACK Transmitter
    rec_tran rec_tran_inst ();
    
    // DEMAPPER
    demapper demapper_inst (
        // clock and control
        .i_clk                 (i_clk),
        .i_rst                 (i_rst),
        // client interface
        .o_pyld_data           (demap_pyld_data),
        .o_pyld_data_valid     (demap_pyld_data_valid),
        // line interface
        .i_frame_data          (),
        .i_frame_data_valid    (),
        .i_frame_data_fas      (),
        // hardware interface
        .o_crc_val             (o_crc_val)
    );
    
    
    // UART TX FIFO (Takes in demapped payload data, sends it to UART TX)
    axis_data_fifo_rx axis_fifo_inst (
        .s_axis_aresetn  (~i_rst),
        .s_axis_aclk     (i_clk),
        .s_axis_tvalid   (demap_pyld_data_valid),
        .s_axis_tready   (demap_pyld_fifo_ready),
        .s_axis_tdata    (demap_pyld_data),
        .m_axis_tvalid   (tx_data_valid),
        .m_axis_tready   (tx_data_ready),
        .m_axis_tdata    (tx_data),
        .almost_empty    (/* open */) 
    );    
    
    
    // UART TX TRANSMITTER WITH AXI WRAPPER TO PC
    AXIS_UART_TX axis_uart_tx_inst (
        .CLK_100MHZ         (i_clk),
        .RESET              (i_rst),
        .clk_en_16_x_baud   (sclk_en_16_x_baud),
        .data_in            (tx_data),
        .UART_TX            (o_uart_tx),
        .valid              (tx_data_valid),
        .ready              (tx_data_ready)
    );
    
    always @(posedge i_clk) begin
        if (scount12 == 8'h36) begin
            scount12 = 8'h0;
        end else begin
            scount12 = scount12 + 1;
        end
    end
    
    assign sclk_en_16_x_baud = (scount12 == 8'h36);
    

endmodule