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
    // for these first few cases, the incoming data should be invalid
    // If the current column count is 0 to 15 (on rows 1 - 3) and the incoming data is invalid (it should be) then output all zeros.
    // if the current row is zero and the current column is is 0 to 2, output 0xF6
    // if the current row is zero and current column is 3 to 5, output 0x28
    // if the current row is zero and the column is 6 to 15, output all zeros.
    // if the current column is 1040 on any row, output all zeros
    
    // on all other cases, if the incoming data is valid output it directly.
    // latency should be one clock cycle.
    


endmodule