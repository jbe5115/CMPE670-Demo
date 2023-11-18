// frame_controller.v
// CMPE 670 Project Fall 2023
// Author(s):
//  
module frame_controller (
    // clock and control
    input        i_clk,
    input        i_rst,
    input        i_row_cnt,
    input        i_col_cnt,
    // client interface
    input [7:0]  i_pyld_data,
    input        i_pyld_data_valid,
    // line interface
    output       o_frame_data,
    output       o_frame_data_valid,
    output       o_frame_data_fas
);


endmodule