// data_wren.v
// CMPE 670 Project Fall 2023
// Author(s): John Evans, Eric Falcone
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
    output reg [7:0] o_pyld_data,
    output reg       o_pyld_data_valid
);
 
    // latency should be one clock cycle.
    always @(posedge i_clk) begin
        if(i_rst == 1) begin
            o_pyld_data         <= 8'b0;
            o_pyld_data_valid   <= 1'b0;
        end else begin
            // If the current column count is 0 to 15 on any row and the incoming data is valid (it should be) then the output should be invalid.
            if(i_col_cnt < 16 && i_frame_data_valid) begin
                o_pyld_data         <= 8'b0;    // data output shouldn't matter.
                o_pyld_data_valid   <= 1'b0;
            // if the current column is 1040 on any row, output all zeros
            end else if (i_col_cnt == 1040 && i_frame_data_valid) begin
                o_pyld_data         <= 8'b0;
                o_pyld_data_valid   <= i_frame_data_valid;
            // on all other cases, if the incoming data is valid output it directly.
            end else if(i_frame_data_valid) begin
                o_pyld_data         <= i_frame_data;
                o_pyld_data_valid   <= i_frame_data_valid;
            end
        end
    end
    
    
endmodule