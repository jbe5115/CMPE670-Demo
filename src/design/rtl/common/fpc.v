// fpc.v
// CMPE 670 Project Fall 2023
// Author(s): John Evans, Eric Falcone
//   
module fpc # (
    parameter    MAP_MODE = 1
)(
    // clock and control
    input         i_clk,
    input         i_rst,
    input         i_enable,
    input         i_valid,

    output wire [1:0]  o_row_cnt,
    output wire [10:0] o_col_cnt
);

    reg [1:0]  row_cnt;
    reg [10:0] col_cnt;
    
    generate
        if (MAP_MODE == 0) begin // demap mode
            always @(posedge i_clk) begin
                if(i_rst == 1) begin
                    row_cnt <= 0;
                    col_cnt <= 0;
                // Reset row and col for new frame
                end else if(row_cnt == 3 && col_cnt == 1040 && i_valid) begin
                    row_cnt <= 0;
                    col_cnt <= 0;
                // For every clock cycle where the input is valid, increase the column count by 1.
                end else if(i_valid && i_enable) begin
                    // If the current column count is 1040, next cycle it should be set to zero and the row count should increment.
                    if(col_cnt == 1040) begin
                        col_cnt = 0;
                        row_cnt = row_cnt + 1;
                    end else begin
                        col_cnt = col_cnt + 1;
                    end
                 // If i_valid is high and the current column is 0-15 or 1040, the FPC can increment.
                 // If the current column count is 1040, next cycle it should be set to zero and the row count should increment.
                end else if(i_valid && col_cnt == 1040 && i_enable) begin
                    col_cnt = 0;
                    row_cnt = row_cnt + 1;
                end else if(i_valid && col_cnt < 16 && i_enable) begin
                    col_cnt = col_cnt + 1;
                end
            end        
        
            assign o_row_cnt = row_cnt;
            assign o_col_cnt = col_cnt;
        end else if (MAP_MODE == 1) begin
            always @(posedge i_clk) begin
                if(i_rst == 1) begin
                    row_cnt <= 0;
                    col_cnt <= 0;
                // Reset row and col for new frame
                end else if(row_cnt == 3 && col_cnt == 1040 && i_valid) begin
                    row_cnt <= 0;
                    col_cnt <= 0;
                // For every clock cycle where the input is valid, increase the column count by 1.
                end else if(i_valid && i_enable) begin
                    // If the current column count is 1040, next cycle it should be set to zero and the row count should increment.
                    if(col_cnt == 1040) begin
                        col_cnt = 0;
                        row_cnt = row_cnt + 1;
                    end else begin
                        col_cnt = col_cnt + 1;
                    end
                 // If i_valid is low and the current column is 0-15 or 1040, the FPC can increment.
                 // If the current column count is 1040, next cycle it should be set to zero and the row count should increment.
                end else if(!i_valid && col_cnt == 1040 && i_enable) begin
                    col_cnt = 0;
                    row_cnt = row_cnt + 1;
                end else if(!i_valid && col_cnt < 16 && i_enable) begin
                    col_cnt = col_cnt + 1;
                end
            end
            
            assign o_row_cnt = row_cnt;
            assign o_col_cnt = col_cnt;
        end else begin // invalid param
            assign o_row_cnt = 0;
            assign o_col_cnt = 0;
        end
    endgenerate
    


endmodule