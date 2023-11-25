// mapper.v
// CMPE 670 Project Fall 2023
// Author(s):
//   John Evans
module mapper (
    // clock and control
    input        i_clk,
    input        i_rst,
    // client interface (rx axis fifo)
    input [7:0]  i_pyld_data,
    input        i_pyld_data_valid,
    output       o_pyld_data_req,    // acts as AXIS ready
    input        i_fifo_empty,
    // line interface (serial transmitter & line FIFO)
    output [7:0] o_frame_data,
    output       o_frame_data_valid,
    output       o_frame_data_fas,
    input        i_line_fifo_ready,
    input        i_tran_rec_fifo_ready,
    input        i_line_retrans_req,
    // hardware interface
    output       o_crc_val
);

    // quick rundown for making internal signals:
    // Use reg for a signal when it is assigned in a process
    // Use wire for a signal when it is the output of an instantiated module or is assigned concurrently.
    
    // FPC signals
    wire [1:0]  c_fpc_row_cnt;
    wire [10:0] c_fpc_col_cnt;
    reg  [1:0]  r_fpc_row_cnt;
    reg  [10:0] r_fpc_col_cnt;
  
    // frame controller output
    wire [7:0] frm_cntrl_frame_data;
    wire       frm_cntrl_frame_data_valid;
    wire       frm_cntrl_frame_data_fas;
    
    // data req signals
    wire       data_req;
    
    // Some useful operators:
    // some_signal = {signal1, signal2}; // signal concatenation
    // somesignal[7:0] = {8{1'b1}};      // replication operator. Assigns 8 1's to that signal.
    // somesignal[0 +: 7]                // indexed part select. wont need to be used very often but very useful, i suggest looking into how it works
    
    assign o_pyld_data_req = data_req;
    
    // -- Basic structure for a clocked process --
    always @(posedge i_clk) begin
        // fpc row & col cnt registers
        r_fpc_row_cnt <= c_fpc_row_cnt;
        r_fpc_col_cnt <= c_fpc_col_cnt;
    end
    
    // -- Basic structure for a combinational process --
    always @(*) begin // No sensitivity list!!!! yay!!
    end
    
    // Frame position counter
    // TODO: FPC NEEDS TO KNOW IF RETRANS REQUEST IS OCCURING!!
    fpc fpc_map_inst (
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_valid            (i_pyld_data_valid & data_req),
        .i_line_retrans_req (i_line_retrans_req),
        
        .o_row_cnt          (c_fpc_row_cnt),
        .o_col_cnt          (c_fpc_col_cnt)
    );
    
    // Data Request
    data_request data_req_map_inst (
        // clock and control
        .i_clk                 (i_clk),
        .i_rst                 (i_rst),
        .i_row_cnt             (c_fpc_row_cnt),
        .i_col_cnt             (c_fpc_col_cnt),
        // FIFO valids/readys
        .i_pyld_data_valid     (i_pyld_data_valid),
        .i_line_fifo_ready     (i_line_fifo_ready),
        .i_tran_rec_fifo_ready (i_tran_rec_fifo_ready),
        .i_line_retrans_req    (i_line_retrans_req),
        // outputs
        .o_data_req            (data_req)
    
    );
    
    // Frame Controller
    frame_controller frm_cntrl_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_row_cnt          (c_fpc_row_cnt),
        .i_col_cnt          (c_fpc_col_cnt),
        // client interface
        .i_pyld_data        (i_pyld_data),
        .i_pyld_data_valid  (i_pyld_data_valid & data_req), // AXIS Transactions only happen when the FIFO is valid and we are ready!
        // line interface
        .o_frame_data       (frm_cntrl_frame_data),
        .o_frame_data_valid (frm_cntrl_frame_data_valid),
        .o_frame_data_fas   (frm_cntrl_frame_data_fas)
    );
    
    // CRC Calculator & Insert
    crc_calc #(
        .MAP_MODE           (1)
    ) crc_calc_map_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_row_cnt          (r_fpc_row_cnt),
        .i_col_cnt          (r_fpc_col_cnt),
        // line interface in
        .i_frame_data       (frm_cntrl_frame_data),
        .i_frame_data_valid (frm_cntrl_frame_data_valid),
        .i_frame_data_fas   (frm_cntrl_frame_data_fas),
        // line interface out
        .o_frame_data       (o_frame_data),
        .o_frame_data_valid (o_frame_data_valid),
        .o_frame_data_fas   (o_frame_data_fas),
        // hardware interface
        .o_crc_val          (o_crc_val),
        // DEMAP only
        .o_crc_err          (/*open*/)
    );

endmodule