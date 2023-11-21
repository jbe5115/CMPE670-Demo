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
    // hardware interface
    output       o_crc_val,
    // DEMAP ONLY
    output       o_crc_err
);

    // when map mode is 1: calculate the CRC on every valid clock cycle that contains payload data (column count is between 16 and 1039 on any row)
    //                     output the crc (on o_frame_data) when row is 3 and column is 1040
    
    // when map mode is 0: same as when map mode is one, but on row 3 column 1040 check the incoming CRC with the currently calculated one.
    //                     if they dont match, set crc error. it should be reset on the next valid cycle (which is the start of a new frame).
    
    // in both cases, o_crc_val should be set to the current crc on all cycles.
    


endmodule