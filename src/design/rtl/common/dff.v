module dff(
    input  i_clk,
    input  i_rst,
    input  i_d,
    output o_q
);

always @(posedge i_clk) begin
    if (i_rst) begin
        o_q <= 1'b0;
    end else begin
        o_q <= i_d;
    end
end

endmodule