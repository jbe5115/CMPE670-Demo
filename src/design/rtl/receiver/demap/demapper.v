// demapper.v
// CMPE 670 Project Fall 2023
// Author(s):
//   John Evans
module demapper (
    // clock and control
    input        i_clk,
    input        i_rst,
    // client interface (tx axis fifo)
    output [7:0] o_pyld_data,
    output       o_pyld_data_valid,
    // line interface (serial receiver)
    input  [7:0] i_frame_data,
    input        i_frame_data_valid,
    input        i_frame_data_fas,
    output       o_crc_err,
    // hardware interface
    output       o_crc_val
);

    // FPC signals
    wire [1:0]  c_fpc_row_cnt;
    wire [10:0] c_fpc_col_cnt;
    reg  [1:0]  r_fpc_row_cnt;
    reg  [10:0] r_fpc_col_cnt;
    
    // crc calculator output
    wire [7:0] crc_calc_frame_data;
    wire       crc_calc_frame_data_valid;
    wire       crc_calc_frame_data_fas;
    
    always @(posedge i_clk) begin
        // fpc row & col cnt registers
        r_fpc_row_cnt <= c_fpc_row_cnt;
        r_fpc_col_cnt <= c_fpc_col_cnt;
    end
    
    // Frame position counter
    fpc fpc_map_inst (
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_valid            (i_pyld_data_valid & data_req), // FIXME
        .i_line_retrans_req (1'b0),
        
        .o_row_cnt          (c_fpc_row_cnt),
        .o_col_cnt          (c_fpc_col_cnt)
    );
    
    // Data write enable (AKA: Frame controller for demapper)
    data_wren data_wren_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_row_cnt          (r_fpc_row_cnt),
        .i_col_cnt          (r_fpc_col_cnt),
        // line interface
        .i_frame_data       (crc_calc_frame_data),
        .i_frame_data_valid (crc_calc_frame_data_valid),
        .i_frame_data_fas   (crc_calc_frame_data_fas),
        // client interface
        .o_pyld_data        (o_pyld_data),
        .o_pyld_data_valid  (o_pyld_data_valid)
    );
      
    // CRC Calculator & Check
    crc_calc #(
        .MAP_MODE           (0)
    ) crc_calc_map_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_row_cnt          (c_fpc_row_cnt),
        .i_col_cnt          (c_fpc_col_cnt),
        // line interface in
        .i_frame_data       (i_frame_data),
        .i_frame_data_valid (i_frame_data_valid),
        .i_frame_data_fas   (i_frame_data_fas),
        // line interface out
        .o_frame_data       (crc_calc_frame_data),
        .o_frame_data_valid (crc_calc_frame_data_valid),
        .o_frame_data_fas   (crc_calc_frame_data_fas),
        // hardware interface
        .o_crc_val          (o_crc_val),
        // DEMAP only
        .o_crc_err          (o_crc_err)
    );

endmodule