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
    input [1:0]  i_row_cnt,
    input [10:0] i_col_cnt,
    // line interface in
    input [7:0]  i_frame_data,
    input        i_frame_data_valid,
    input        i_frame_data_fas,
    // line interface out
    output reg [7:0] o_frame_data,
    output reg       o_frame_data_valid,
    output reg       o_frame_data_fas,
    // hardware interface
    output reg [7:0] o_crc_val,
    // DEMAP ONLY
    output reg       o_crc_err
);
    reg [7:0] crc_val = 8'b0;
    
    // in both cases, o_crc_val should be set to the current crc on all cycles.
    // Last 8 bit row is CRC value
    always @(posedge i_clk) begin : CRCProc
        if (i_rst) begin
            // Set output values low.
            o_frame_data        <= 8'b0;
            o_frame_data_valid  <= 1'b0;
            o_frame_data_fas    <= 1'b0;
            o_crc_val           <= 8'b0;
            o_crc_err           <= 1'b0;
            crc_val             <= 8'b0;       
        end else begin
            // when map mode is 0: same as when map mode is one, but on row 3 column 1040 check the incoming CRC with the currently calculated one.
            //                     if they dont match, set crc error. it should be reset on the next valid cycle (which is the start of a new frame).
            case(MAP_MODE)
                1'b0 : begin
                    if (i_row_cnt == 3 && i_col_cnt == 1040 && i_frame_data_valid) begin
                        // Check incoming CRC with currently calculated one
                        o_frame_data        <= crc_val;
                        o_frame_data_valid  <= i_frame_data_valid;
                        o_frame_data_fas    <= i_frame_data_fas; 
                        o_crc_val           <= crc_val; 
                        // Check CRC val and set error state if not equal
                        if(i_frame_data != crc_val) begin
                            o_crc_err       <= 1'b1;
                        end else begin
                            o_crc_err       <= 1'b0;
                        end
                    end else if(i_col_cnt >= 16 && i_col_cnt <= 1039 && i_frame_data_valid) begin
                        // Calculate CRC and pass data through.
                        o_frame_data        <= i_frame_data;
                        o_frame_data_valid  <= i_frame_data_valid;
                        o_frame_data_fas    <= i_frame_data_fas; 
                        crc_val             <= crc(crc_val, i_frame_data);      // Calculate CRC Value for this iteration
                    end else if(i_col_cnt < 16 && i_frame_data_valid) begin
                        // Pass overhead through
                        o_frame_data        <= i_frame_data;
                        o_frame_data_valid  <= i_frame_data_valid;
                        o_frame_data_fas    <= i_frame_data_fas;
                        // Reset hardware interface
                        o_crc_val           <= 8'b0;
                        o_crc_err           <= 1'b0;
                    end
                end
                // when map mode is 1: calculate the CRC on every valid clock cycle that contains payload data (column count is between 16 and 1039 on any row)
                //                     output the crc (on o_frame_data) when row is 3 and column is 1040
                1'b1 : begin                    
                    if (i_row_cnt == 3 && i_col_cnt == 1040 && i_frame_data_valid) begin
                        // Send CRC on output
                        o_frame_data        <= crc_val;
                        o_frame_data_valid  <= i_frame_data_valid;
                        o_frame_data_fas    <= i_frame_data_fas;
                        o_crc_val           <= crc_val;
                    end else if(i_col_cnt >= 16 && i_col_cnt <= 1039 && i_frame_data_valid) begin
                        // Calculate CRC and pass data through.
                        o_frame_data        <= i_frame_data;
                        o_frame_data_valid  <= i_frame_data_valid;
                        o_frame_data_fas    <= i_frame_data_fas; 
                        crc_val             <= crc(crc_val, i_frame_data);      // Calculate CRC Value for this iteration
                    end else if(i_col_cnt < 16 && i_frame_data_valid) begin
                        // Pass data through since this is overhead
                        o_frame_data        <= i_frame_data;
                        o_frame_data_valid  <= i_frame_data_valid;
                        o_frame_data_fas    <= i_frame_data_fas;
                        // Reset hardware interface
                        o_crc_val           <= 8'b0;
                        o_crc_err           <= 1'b0;
                    end
                end
                default : begin
                    // Set error states on hardware if MAP_MODE IS INVALID
                    o_crc_val <= 8'hf;
                    o_crc_err <= 1'b0;
                end
            endcase
        end
    end

    // THIS IS GENERATED VERILOG CODE.
    // https://bues.ch/h/crcgen
    // 
    // This code is Public Domain.
    // Permission to use, copy, modify, and/or distribute this software for any
    // purpose with or without fee is hereby granted.
    // 
    // THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
    // WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
    // MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
    // SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
    // RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
    // NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
    // USE OR PERFORMANCE OF THIS SOFTWARE.
    
    // CRC polynomial coefficients: x^8 + x^2 + x + 1
    //                              0x7 (hex)
    // CRC width:                   8 bits
    // CRC shift direction:         left (big endian)
    // Input word width:            8 bits
    
    function automatic [7:0] crc;
        input [7:0] crcIn;
        input [7:0] data;
    begin
        crc[0] = crcIn[0] ^ crcIn[6] ^ crcIn[7] ^ data[0] ^ data[6] ^ data[7];
        crc[1] = crcIn[0] ^ crcIn[1] ^ crcIn[6] ^ data[0] ^ data[1] ^ data[6];
        crc[2] = crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[6] ^ data[0] ^ data[1] ^ data[2] ^ data[6];
        crc[3] = crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[7] ^ data[1] ^ data[2] ^ data[3] ^ data[7];
        crc[4] = crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ data[2] ^ data[3] ^ data[4];
        crc[5] = crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ data[3] ^ data[4] ^ data[5];
        crc[6] = crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ data[4] ^ data[5] ^ data[6];
        crc[7] = crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ data[5] ^ data[6] ^ data[7];
    end
    endfunction

endmodule