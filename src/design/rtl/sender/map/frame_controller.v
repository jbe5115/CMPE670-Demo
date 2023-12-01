// frame_controller.v
// CMPE 670 Project Fall 2023
// Author(s): John Evans, Eric Falcone
//  
module frame_controller (
    // clock and control
    input            i_clk,
    input            i_rst,
    input [1:0]      i_row_cnt,
    input [10:0]     i_col_cnt,
    // client interface
    input [7:0]      i_pyld_data,
    input            i_pyld_data_valid,
    // line interface
    output reg [7:0] o_frame_data,
    output reg       o_frame_data_valid,
    output reg       o_frame_data_fas,
    // hardware interface
    input            i_arq_en
);
    // latency should be one clock cycle.
    always @(posedge i_clk) begin : frameConProc
        // Synchronous Reset
        if(i_rst == 1) begin
            o_frame_data        <= 8'b0;
            o_frame_data_valid  <= 1'b0; 
            o_frame_data_fas    <= 1'b0;
        end else begin
            // If the current column count is 0 to 15 (on rows 1 - 3) and the incoming data is invalid (it should be) then output all zeros.
            if(i_row_cnt > 0 && i_col_cnt < 16 && !i_pyld_data_valid) begin
                o_frame_data        <= 8'b0;
                o_frame_data_valid  <= 1'b1; 
                o_frame_data_fas    <= 1'b0;
            // if the current row is zero and the current column is is 0 to 2, output 0xF6
            end else if(i_row_cnt == 0 && i_col_cnt >= 0 && i_col_cnt <= 2 && !i_pyld_data_valid) begin
                o_frame_data        <= 8'hF6;
                o_frame_data_valid  <= 1'b1; 
                // If the current col is 0, output 1 on fas
                if(i_col_cnt == 0) begin
                    o_frame_data_fas    <= 1'b1;
                end else begin
                    o_frame_data_fas    <= 1'b0;
                end
            // if the current row is zero and current column is 3 to 5, output 0x28
            end else if(i_row_cnt == 0 && i_col_cnt >= 3 && i_col_cnt <= 5 && !i_pyld_data_valid) begin
                 o_frame_data        <= 8'h28;
                 o_frame_data_valid  <= 1'b1;
                 o_frame_data_fas    <= 1'b0;
            // if the current row is zero and current column is 6, output 0xFF if ARQ is enable, otherwise 0x00
            end else if (i_row_cnt == 0 && i_col_cnt == 6 && !i_pyld_data_valid) begin
                 o_frame_data        <= (i_arq_en) ? 8'hFF : 8'h00;
                 o_frame_data_valid  <= 1'b1; 
                 o_frame_data_fas    <= 1'b0;                
            // if the current row is zero and the column is 6 to 15, output all zeros.
            end else if(i_row_cnt == 0 && i_col_cnt >= 7 && i_col_cnt <= 15 && !i_pyld_data_valid) begin
                 o_frame_data        <= 8'b0;
                 o_frame_data_valid  <= 1'b1; 
                 o_frame_data_fas    <= 1'b0;
            // if the current column is 1040 on any row, output all zeros
            end else if(i_col_cnt == 1040 && !i_pyld_data_valid) begin
                 o_frame_data        <= 8'b0;
                 o_frame_data_valid  <= 1'b1; 
                 o_frame_data_fas    <= 1'b0;
            // on all other cases, if the incoming data is valid output it directly.
            end else if(i_pyld_data_valid) begin
                 o_frame_data        <= i_pyld_data;
                 o_frame_data_valid  <= i_pyld_data_valid; 
                 o_frame_data_fas    <= 1'b0;
            end else begin
                o_frame_data         <= i_pyld_data;
                o_frame_data_valid   <= i_pyld_data_valid;
                o_frame_data_fas     <= 1'b0;
            end
        end
     end
endmodule