// sender.v
// CMPE 670 Project Fall 2023
// Author(s):
//   John Evans
module sender (
    // PC/FPGA INTERFACE
    input          i_clk,
    input          i_rst,
    input          i_uart_rx,
    input          i_arq_en,
    input          i_corrupt_en,
    output [7:0]   o_crc_val,
    // TRANSMIT INTERFACE
    output         o_otn_rx_data,
    input          i_otn_tx_ack
);
    // UART clock control
    reg  [11:0]  scount12 = 0;
    reg          sclk_en_16_x_baud;
    
    // UART_RX -> RX FIFO
    wire [7:0]   rx_data;
    wire         rx_data_valid;
    wire         rx_data_ready;
    
    // RX FIFO -> MAPPER
    wire [7:0]   rx_pyld_data;
    wire         rx_pyld_data_valid;
    wire         rx_pyld_data_req;
    wire         rx_fifo_ae;
    
    // MAPPER -> LINE FIFO AND TRAN_REC
    wire [7:0]   map_frame_data;
    wire         map_frame_data_valid;
    wire         map_frame_data_fas;
    wire         line_fifo_ready;
    
    // TRAN REC IN/OUT
    wire [7:0]   tr_frame_data;
    wire         tr_frame_data_valid;
    wire         tr_fifo_ready;
    wire         tr_retrans_req;
    wire         tr_read_line_fifo;
    wire         tr_send_complete;
    
    // LINE FIFO OUT
    wire [7:0]   lf_frame_data;
    wire         lf_frame_data_valid;
    wire         lf_ready;
    
  
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
        .almost_empty    (/* open */) 
    );
    
    // Mapper!
    mapper mapper_inst (
        // clock and control
        .i_clk                 (i_clk),
        .i_rst                 (i_rst),
        // client interface
        .i_pyld_data           (rx_pyld_data),
        .i_pyld_data_valid     (rx_pyld_data_valid),
        .o_pyld_data_req       (rx_pyld_data_req),
        // line interface
        .o_frame_data          (map_frame_data),
        .o_frame_data_valid    (map_frame_data_valid),
        .o_frame_data_fas      (map_frame_data_fas),
        .i_line_fifo_ready     (line_fifo_ready),
        .i_tran_rec_fifo_ready (tr_fifo_ready),
        .i_line_retrans_req    (tr_retrans_req),
        // hardware interface
        .i_corrupt_en          (i_corrupt_en),
        .i_arq_en              (i_arq_en),
        .o_crc_val             (o_crc_val)
    );
    
    // LINE AXIS FIFO (Takes in MAPPED line data, sends it to tran_req when retrans is occuring!)
    // Reset FIFO when rst is enabled or a good ACK was received!
    axis_data_fifo_rx line_fifo_inst (
        .s_axis_aresetn  (~(i_rst || tr_send_complete)),
        .s_axis_aclk     (i_clk),
        // mapper -> FIFO in
        .s_axis_tvalid   (map_frame_data_valid),
        .s_axis_tready   (line_fifo_ready),
        .s_axis_tdata    (map_frame_data),
        // FIFO out -> tran_rec
        .m_axis_tvalid   (lf_frame_data_valid),
        .m_axis_tready   (lf_ready),
        .m_axis_tdata    (lf_frame_data),
        .almost_empty    (/* open*/)
    );
    
    // don't read out of line FIFO until: tran_rec FIFO is ready, retrans is occuring, and line FIFO write side is ready
    assign lf_ready = tr_fifo_ready && tr_read_line_fifo && line_fifo_ready;
    
    assign tr_frame_data       = (tr_read_line_fifo) ? lf_frame_data       : map_frame_data;
    assign tr_frame_data_valid = (tr_read_line_fifo) ? lf_frame_data_valid : map_frame_data_valid;
    
    // TODO: Instantiate tran_rec
    tran_rec tran_rec_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        // data from/to the mapper OR line FIFO
        .i_frame_data       (tr_frame_data),
        .i_frame_data_valid (tr_frame_data_valid),
        .i_frame_data_fas   (map_frame_data_fas),
        // output control signals
        .o_fifo_ready       (tr_fifo_ready),
        .o_retrans_req      (tr_retrans_req),
        .o_read_line_fifo   (tr_read_line_fifo),
        .o_send_complete    (tr_send_complete),
        // data in/out of the FPGA
        .o_otn_rx_data      (o_otn_rx_data),
        .i_otn_tx_ack       (i_otn_tx_ack),
        // FPGA switch input
        .i_arq_en           (i_arq_en)
    );
    
    
    always @(posedge i_clk, i_rst) begin
        if (i_rst) begin
            scount12 = 8'h0;
            sclk_en_16_x_baud = 1'b0;
        end else if (scount12 == 8'h36) begin
            scount12 = 8'h0;
            sclk_en_16_x_baud = 1'b1;
        end else begin
            scount12 = scount12 + 1;
            sclk_en_16_x_baud = 1'b0;
        end
    end
    
    // assign sclk_en_16_x_baud = (scount12 == 8'h36);

endmodule