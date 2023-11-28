// corruptor.v
// CMPE 670 Project Fall 2023
// Author(s): John Evans, Eric Falcone
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
    output reg [7:0] o_frame_data,
    output reg       o_frame_data_valid,
    output reg       o_frame_data_fas,
    // hardware interface
    input        i_corrupt_en
);

integer random_number;

always @(posedge i_clk) begin : CorruptProc
    if(i_rst == 1) begin
        o_frame_data        <= 8'b0;
        o_frame_data_valid  <= 1'b0;
        o_frame_data_fas    <= 1'b0;
    end else if(i_corrupt_en == 1) begin
        // Don't corrupt frame start pattern or CRC value sent
        if(i_row_cnt == 3 && i_col_cnt == 1040 && i_pyld_data_valid) begin
            o_frame_data        <= i_pyld_data;
            o_frame_data_valid  <= i_pyld_data_valid;
            o_frame_data_fas    <= i_frame_data_fas;
        end else if((i_col_cnt > 15 || i_row_cnt != 0) && i_pyld_data_valid) begin
            // Corrupt data with random number
            // TODO : Not sure if there's a better way to generate a random output
            random_number = {$urandom} % 256;
            o_frame_data        <= i_pyld_data ^ random_number;
            o_frame_data_valid  <= i_pyld_data_valid;
            o_frame_data_fas    <= i_frame_data_fas;
        end else if(i_pyld_data_valid) begin
            // Pass data through if conditions above are not met (frame start pattern)
            o_frame_data        <= i_pyld_data;
            o_frame_data_valid  <= i_pyld_data_valid;
            o_frame_data_fas    <= i_frame_data_fas;
        end
    end else begin
        // Pass data through if switch is not on.
        o_frame_data        <= i_pyld_data;
        o_frame_data_valid  <= i_pyld_data_valid;
        o_frame_data_fas    <= i_frame_data_fas;
    end
end

endmodule