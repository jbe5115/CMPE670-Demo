module watchdog (
    input       i_clk, // 100MHz
    input       i_rst,
    inout       i_timer_en,     // start observing
    input       i_signal_obs,   // observed signal
    input       i_signal_match, // observed signal to match
    //input [1:0] i_clk_div
    output      o_timeout_event,
    output      o_signal_match_event
    
);

// counter for baud
reg [11:0] baud_counter;

reg signal_match_event;
reg timeout_event;

// clk divider
wire [19:0] clk_s; // div source
reg [19:0] clk_div; // div ff

always @(posedge i_clk) begin
    if(i_rst) begin
        clk_div[0] <= 1'b0;
    end else begin
        clk_div[0]       <= !clk_s[0];
    end
end

assign clk_s[19:1] = clk_div[19:1];

genvar i;
generate
    for (i = 1; i < 20; i=i+1) 
    begin : clk_divider
        dff dff_inst (
            .i_clk  (clk_div[i - 1]),
            .i_rst  (i_rst),
            .i_d    (!clk_s[i]),
            .o_q    (clk_div[i])
        );
    end
endgenerate

always @( posedge i_clk ) begin
   if (i_rst) begin
        baud_counter = 0;
   end else if(clk_div[19] && i_timer_en) begin // 1.5KHz
        baud_counter = baud_counter + 1;
   end
end

always @(posedge i_clk) begin
    timeout_event <= (baud_counter >= 'h2FA); // 2 seconds
    signal_match_event <= i_signal_obs == i_signal_match;
end

assign o_signal_match_event = signal_match_event;
assign o_timeout_event      = timeout_event && !signal_match_event;



endmodule