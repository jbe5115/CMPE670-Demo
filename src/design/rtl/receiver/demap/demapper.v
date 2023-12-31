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
    output       o_crc_err_valid,
    output       o_arq_en,
    output       o_arq_en_valid,
    // hardware interface
    input        i_corrupt_en,
    input  [7:0] i_corrupt_seed,
    output [7:0] o_crc_val
);

    // FPC signals
    wire [1:0]  c_fpc_row_cnt;
    wire [10:0] c_fpc_col_cnt;
    reg  [1:0]  r_fpc_row_cnt;
    reg  [10:0] r_fpc_col_cnt;
    reg  [1:0]  r_fpc_row_cnt_d1;
    reg  [10:0] r_fpc_col_cnt_d1;
    reg  [1:0]  r_fpc_row_cnt_d2;
    reg  [10:0] r_fpc_col_cnt_d2;
    
    // crc calculator output
    wire [7:0] crc_calc_frame_data;
    wire       crc_calc_frame_data_valid;
    wire       crc_calc_frame_data_fas;
    
    // corruptor output
    wire [7:0] corrupt_frame_data;
    wire       corrupt_frame_data_valid;
    wire       corrupt_frame_data_fas;    
    
    always @(posedge i_clk) begin
        // fpc row & col cnt registers
        r_fpc_row_cnt    <= c_fpc_row_cnt;
        r_fpc_col_cnt    <= c_fpc_col_cnt;
        r_fpc_row_cnt_d1 <= r_fpc_row_cnt;
        r_fpc_col_cnt_d1 <= r_fpc_col_cnt;
        r_fpc_row_cnt_d2 <= r_fpc_row_cnt_d1;
        r_fpc_col_cnt_d2 <= r_fpc_col_cnt_d1;
        
        //corrupt_frame_data       <= i_frame_data;
        //corrupt_frame_data_valid <= i_frame_data_valid;
        //corrupt_frame_data_fas   <= i_frame_data_fas;
    end
    
    // Frame position counter
    fpc #(
        .MAP_MODE           (0)
    ) fpc_demap_inst (
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_valid            (i_frame_data_valid),
        .i_enable           (1'b1),
        
        .o_row_cnt          (c_fpc_row_cnt),
        .o_col_cnt          (c_fpc_col_cnt)
    );
    
    // Data write enable (AKA: Frame controller for demapper)
    data_wren data_wren_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_row_cnt          (r_fpc_row_cnt_d2),
        .i_col_cnt          (r_fpc_col_cnt_d2),
        // line interface
        .i_frame_data       (crc_calc_frame_data),
        .i_frame_data_valid (crc_calc_frame_data_valid),
        //.i_frame_data_fas   (crc_calc_frame_data_fas),
        // client interface
        .o_pyld_data        (o_pyld_data),
        .o_pyld_data_valid  (o_pyld_data_valid),
        // demapper -> rec_tran interface
        .o_arq_en           (o_arq_en),
        .o_arq_en_valid     (o_arq_en_valid)
    );
      
    // CRC Calculator & Check
    crc_calc #(
        .MAP_MODE           (0)
    ) crc_calc_demap_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_row_cnt          (r_fpc_row_cnt_d1),
        .i_col_cnt          (r_fpc_col_cnt_d1),
        // line interface in
        .i_frame_data       (corrupt_frame_data),
        .i_frame_data_valid (corrupt_frame_data_valid),
        .i_frame_data_fas   (corrupt_frame_data_fas),
        // line interface out
        .o_frame_data       (crc_calc_frame_data),
        .o_frame_data_valid (crc_calc_frame_data_valid),
        .o_frame_data_fas   (crc_calc_frame_data_fas),
        // hardware interface
        .o_crc_val          (o_crc_val),
        // DEMAP only
        .o_crc_err          (o_crc_err),
        .o_crc_err_valid    (o_crc_err_valid)
    );
    
    
    //Corruptor Component
    corruptor corruptor_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_row_cnt          (r_fpc_row_cnt),
        .i_col_cnt          (r_fpc_col_cnt),
        // line interface in
        .i_frame_data       (i_frame_data),
        .i_frame_data_valid (i_frame_data_valid),
        .i_frame_data_fas   (i_frame_data_fas),
        // line interface out
        .o_frame_data       (corrupt_frame_data),
        .o_frame_data_valid (corrupt_frame_data_valid),
        .o_frame_data_fas   (corrupt_frame_data_fas),
        // hardware interface
        .i_corrupt_en       (i_corrupt_en),
        .i_corrupt_seed     (i_corrupt_seed)
    );

endmodule