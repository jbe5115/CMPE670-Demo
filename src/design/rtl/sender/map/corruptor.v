// corruptor.v
// CMPE 670 Project Fall 2023
// Author(s): 
//  
module corruptor (
    // clock and control
    input        i_clk,
    input        i_rst,
    input [1:0]  i_row_cnt,
    input [10:0] i_col_cnt,
    // TODO: Add some inputs that may help decide when to corrupt
    // line interface in
    input [7:0]  i_pyld_data,
    input        i_pyld_data_valid,
    input        i_frame_data_fas,
    // line interface out
    output [7:0] o_frame_data,
    output       o_frame_data_valid,
    output       o_frame_data_fas,
    // hardware interface
    input        i_corrupt_en
);



endmodule