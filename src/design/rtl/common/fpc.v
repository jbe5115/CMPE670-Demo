// fpc.v
// CMPE 670 Project Fall 2023
// Author(s):
//   
module fpc (
    // clock and control
    input         i_clk,
    input         i_rst,

    input         i_valid,
    input         i_data_req,

    output [1:0]  o_row_cnt,
    output [10:0] o_col_cnt
);

    // For every clock cycle where the input is valid, increase the column count by 1.
    // If the current column count is 1040, next cycle it should be set to zero and the row count should increment.
    // Make a synchronous reset to reset row and col count to zero.


endmodule