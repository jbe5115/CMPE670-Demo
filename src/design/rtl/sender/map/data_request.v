// frame_controller.v
// CMPE 670 Project Fall 2023
// Author(s):
//  John Evans
module data_request (
    // clock and control
    input        i_clk,
    input        i_rst,
    input [1:0]  i_row_cnt,
    input [10:0] i_col_cnt,
    // FIFO valids/readys
    input        i_pyld_data_valid,
    input        i_line_fifo_ready,
    input        i_tran_rec_fifo_ready,
    input        i_line_retrans_req,
    // outputs
    output       o_data_req
);
    // combinational internal signal, registered internal signal
    reg    c_data_req, r_data_req;
    
    assign o_data_req = r_data_req;
    
    always @(*) begin
        // latch prevention (only needed if there are unresolved cases)
        c_data_req = 1'b0;
        if (i_rst) begin
            // reset to zero
            c_data_req = 1'b0;
        end else begin
            // we can ONLY map data if the line FIFO & tran_rec FIFO are ready (they always should be XD), and no retrans req!!!
            if (i_line_fifo_ready && i_tran_rec_fifo_ready && !i_line_retrans_req) begin
                // FIRST CASE: Overhead
                if (i_col_cnt < 16) begin
                    // we don't want new data on this cycle.
                    c_data_req = 1'b0;
                // SECOND CASE: End of row zero padding
                end else if (i_col_cnt == 1040) begin
                    // we don't want new data on this cycle.
                    c_data_req = 1'b0;
                // THIRD CASE: Everything else (payload)
                end else begin
                    if (i_pyld_data_valid) begin // FIFO has valid data, assert ready! (request)
                        c_data_req = 1'b1;
                    end else begin // FIFO doesn't have valid data, so we can't assert ready. (request)
                        c_data_req = 1'b0;
                    end
                end
            end
        end
    end
    
    always @(posedge i_clk) begin
        r_data_req <= c_data_req;
    end

endmodule