// receiver.v
// CMPE 670 Project Fall 2023
// Author(s):
//   John Evans
module receiver (
    // PC/FPGA INTERFACE
    input         i_clk,
    input         i_rst,
    output        o_uart_tx,
    output [7:0]  o_crc_val,
    // TRANSMIT INTERFACE
    input         i_otn_tx_data,
    output        o_otn_rx_ack
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
    reg          c_uart_tx_enable, r_uart_tx_enable;
    
    // REC_TRAN -> DEMAPPER
    wire [7:0]   rec_tran_frame_data;
    wire         rec_tran_frame_data_valid;
    
    // CRC ERROR
    wire         demap_crc_err;
    wire         demap_crc_err_valid;
    
    // ARQ EN
    wire         demap_arq_en;
    wire         demap_arq_en_valid;
    
    // Serial receiver & ACK Transmitter
    rec_tran rec_tran_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_crc_err          (demap_crc_err),
        .i_crc_err_valid    (demap_crc_err_valid),
        // data to the demapper
        .o_frame_data       (rec_tran_frame_data),
        .o_frame_data_valid (rec_tran_frame_data_valid),
        // input control signals
        .i_tx_fifo_ready    (demap_pyld_fifo_ready),
        .i_arq_en           (demap_arq_en),
        .i_arq_en_valid     (demap_arq_en_valid),
        // data in/out of the FPGA
        .i_otn_tx_data      (i_otn_tx_data),
        .o_otn_rx_ack       (o_otn_rx_ack)
    );
    
    // DEMAPPER
    demapper demapper_inst (
        // clock and control
        .i_clk                 (i_clk),
        .i_rst                 (i_rst),
        // client interface
        .o_pyld_data           (demap_pyld_data),
        .o_pyld_data_valid     (demap_pyld_data_valid),
        // line interface
        .i_frame_data          (rec_tran_frame_data),
        .i_frame_data_valid    (rec_tran_frame_data_valid),
        .i_frame_data_fas      (),
        .o_crc_err             (demap_crc_err),
        .o_crc_err_valid       (demap_crc_err_valid),
        .o_arq_en              (demap_arq_en),
        .o_arq_en_valid        (demap_arq_en_valid),
        // hardware interface
        .o_crc_val             (o_crc_val)
    );
    
    
    // UART TX FIFO (Takes in demapped payload data, sends it to UART TX)
    // this FIFO must reset when a CRC error is detected.
    axis_data_fifo_rx axis_fifo_inst (
        .s_axis_aresetn  (~(i_rst || demap_crc_err)),
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
        .enable             (r_uart_tx_enable),
        .data_in            (tx_data),
        .UART_TX            (o_uart_tx),
        .valid              (tx_data_valid),
        .ready              (tx_data_ready)
    );
    
    // c_uart_tx_enable assignment process
    always @(*) begin
        if (i_rst) begin
            c_uart_tx_enable = 1'b0;
        end else begin
            c_uart_tx_enable = (demap_crc_err_valid) ? ~demap_crc_err : r_uart_tx_enable;
        end
    end
    
    // register update process
    always @(posedge i_clk) begin
        r_uart_tx_enable <= c_uart_tx_enable;
    end
    
    always @(posedge i_clk) begin
        if (scount12 == 8'h36) begin
            scount12 = 8'h0;
        end else begin
            scount12 = scount12 + 1;
        end
    end
    
    assign sclk_en_16_x_baud = (scount12 == 8'h36);
    

endmodule