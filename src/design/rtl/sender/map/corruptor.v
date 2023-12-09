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

    integer counter = 0;

    reg [7:0] reg_lsf;

    always @(posedge i_clk) begin : LFSRProc
        if(i_rst) begin
            reg_lsf <= i_corrupt_seed;
        end else if (i_corrupt_en && i_frame_data_valid) begin
            reg_lsf <= {reg_lsf[7:0], reg_lsf[6] ^ reg_lsf[3]};
        end
    end

    always @(posedge i_clk) begin : CorruptProc
        if(i_rst == 1) begin
            o_frame_data        <= 8'b0;
            o_frame_data_valid  <= 1'b0;
            o_frame_data_fas    <= 1'b0;
        end else if(i_corrupt_en == 1) begin
            // Don't corrupt the FAS pattern or ARQ enable indicator
            if(i_row_cnt == 0 && i_col_cnt < 7 && i_frame_data_valid) begin
                o_frame_data        <= i_frame_data;
                o_frame_data_valid  <= i_frame_data_valid;
                o_frame_data_fas    <= i_frame_data_fas;
            // Otherwise, if the incoming data is valid, corrupt it on a specific LFSR condition
            end else if(i_frame_data_valid) begin
                if (reg_lsf[7:4] == 4'b0100) begin // Corrupt data with 0xFF
                    o_frame_data <= 8'hFF;
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

endmodule