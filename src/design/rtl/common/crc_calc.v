// crc_calc.v
// CMPE 670 Project Fall 2023
// Author(s):
//  
module crc_calc # (
    parameter    MAP_MODE = 1 // parameters are the same thing as generics in VHDL
)(
    // clock and control
    input        i_clk,
    input        i_rst,
    input        i_row_cnt,
    input        i_col_cnt,
    // line interface in
    input [7:0]  i_frame_data,
    input        i_frame_data_valid,
    input        i_frame_data_fas,
    // line interface out
    output       o_frame_data,
    output       o_frame_data_valid,
    output       o_frame_data_fas,
    // DEMAP ONLY
    output       o_crc_err
);

    // when map mode is 1, calculate the CRC and insert it into the frame.
    // when it is 0, calculate the CRC and compare it with the one in the frame.


endmodule