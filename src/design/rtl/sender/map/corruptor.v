// corruptor.v
// CMPE 670 Project Fall 2023
// Author(s): John Evans, Eric Falcone
//  
module corruptor (
    // clock and control
    input            i_clk,
    input            i_rst,
    input [1:0]      i_row_cnt,
    input [10:0]     i_col_cnt,
    // line interface in
    input [7:0]      i_frame_data,
    input            i_frame_data_valid,
    input            i_frame_data_fas,
    // line interface out
    output reg [7:0] o_frame_data,
    output reg       o_frame_data_valid,
    output reg       o_frame_data_fas,
    // hardware interface
    input            i_corrupt_en,
    input [7:0]      i_corrupt_seed
);

    reg [7:0] reg_lsf;

    always @(posedge i_clk) begin : LFSRProc
        if(i_rst) begin
            reg_lsf <= i_corrupt_seed;
        end else if (i_corrupt_en && i_frame_data_valid) begin
            //reg_lsf <= {reg_lsf[7:0], reg_lsf[6] ^ reg_lsf[3]};
            reg_lsf <= crc(reg_lsf, i_frame_data);
        end
    end

    always @(posedge i_clk) begin : CorruptProc
        if (i_rst) begin
            o_frame_data        <= 8'b0;
            o_frame_data_valid  <= 1'b0;
            o_frame_data_fas    <= 1'b0;
        end else if (i_corrupt_en) begin
            // Don't corrupt the FAS pattern or ARQ enable indicator
            if((i_row_cnt == 0) && (i_col_cnt < 7) && i_frame_data_valid) begin
                o_frame_data        <= i_frame_data;
                o_frame_data_valid  <= i_frame_data_valid;
                o_frame_data_fas    <= i_frame_data_fas;
            // Otherwise, if the incoming data is valid, corrupt it on a specific LFSR condition
            end else if(i_frame_data_valid) begin
                if (reg_lsf[7:4] == 4'b0100) begin // Corrupt data with 0xFF
                    o_frame_data <= 8'h00;
                end else begin
                    o_frame_data <= i_frame_data;
                end
                o_frame_data_valid  <= i_frame_data_valid;
                o_frame_data_fas    <= i_frame_data_fas;
            // For all other cases, pass the data through.
            end else begin
                o_frame_data         <= i_frame_data;
                o_frame_data_valid   <= i_frame_data_valid;
                o_frame_data_fas     <= i_frame_data_fas;
            end
        end else begin
            // Pass data through if switch is not on.
            o_frame_data        <= i_frame_data;
            o_frame_data_valid  <= i_frame_data_valid;
            o_frame_data_fas    <= i_frame_data_fas;
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