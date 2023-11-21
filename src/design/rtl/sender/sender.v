// sender.v
// CMPE 670 Project Fall 2023
// Author(s):
//   John Evans
module sender (
    // PC/FPGA INTERFACE
    input    i_clk,
    input    i_rst,
    input    i_uart_rx,
    input    i_arq_en,
    output   o_crc_val,
    // TRANSMIT INTERFACE
    output   o_otn_rx_data,
    output   i_otn_tx_ack
);
    // UART clock control
    reg  [11:0]  scount12;
    wire         sclk_en_16_x_baud;
    
    // UART_RX -> RX FIFO
    wire [7:0]   rx_data;
    wire         rx_data_valid;
    wire         rx_data_ready;
    
    // RX FIFO -> MAPPER
    wire [7:0]   rx_pyld_data;
    wire         rx_pyld_data_valid;
    wire         rx_pyld_data_req;
    wire         rx_fifo_ae;
    

    // UART RX (Serial -> 8b parallel)
    AXIS_UART_RX axis_uart_rx_inst (
        .CLK_100MHZ       (i_clk),
        .RESET            (i_rst),
        .clk_en_16_x_baud (sclk_en_16_x_baud),
        .data_out         (rx_data),
        .UART_RX          (i_uart_rx),
        .valid            (rx_data_valid),
        .ready            (rx_data_ready),
        .almost_full      (1'b0)
    );
    
    // UART RX FIFO (Takes in UART RX data, sends it to mapper)
    axis_data_fifo_rx axis_fifo_inst (
        .s_axis_aresetn  (~i_rst),
        .s_axis_aclk     (i_clk),
        .s_axis_tvalid   (rx_data_valid),
        .s_axis_tready   (rx_data_ready),
        .s_axis_tdata    (rx_data),
        .m_axis_tvalid   (rx_pyld_data_valid),
        .m_axis_tready   (rx_pyld_data_req),
        .m_axis_tdata    (rx_pyld_data),
        .almost_empty    (rx_fifo_ae) 
    );
    
    // Mapper!
    mapper mapper_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        // client interface
        .i_pyld_data        (rx_pyld_data),
        .i_pyld_data_valid  (rx_pyld_data_valid),
        .o_pyld_data_req    (rx_pyld_data_req),
        .i_fifo_empty       (rx_fifo_ae),
        // line interface
        .o_frame_data       (),
        .o_frame_data_valid (),
        .o_frame_data_fas   ()
    );
    
    // TODO: Instantiate tran_rec
    
    
    
    always @(posedge i_clk) begin
        if (scount12 == 8'h36) begin
            scount12 = 8'h0;
        end else begin
            scount12 = scount12 + 1;
        end
    end
    
    assign sclk_en_16_x_baud = (scount12 == 8'h36);

endmodule