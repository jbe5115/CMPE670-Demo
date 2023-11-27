// data_wren.v
// CMPE 670 Project Fall 2023
// Author(s):
//  
module data_wren (
    // clock and control
    input        i_clk,
    input        i_rst,
    input [1:0]  i_row_cnt,
    input [10:0] i_col_cnt,
    // line interface
    input [7:0]  i_frame_data,
    input        i_frame_data_valid,
    input        i_frame_data_fas,
    // client interface
    output [7:0] o_pyld_data,
    output       o_pyld_data_valid
);

    // If the current column count is 0 to 15 on any row and the incoming data is valid (it should be) then the output should be invalid.
    // if the current column is 1040 on any row, output all zeros
    
    // on all other cases, if the incoming data is valid output it directly.
    // latency should be one clock cycle.
    
endmodule