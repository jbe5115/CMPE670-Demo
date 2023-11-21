// mapper.v
// CMPE 670 Project Fall 2023
// Author(s):
//   John Evans
module mapper (
    // clock and control
    input        i_clk,
    input        i_rst,
    // client interface (rx axis fifo)
    input [7:0]  i_pyld_data,
    input        i_pyld_data_valid,
    output       o_pyld_data_req,    // acts as AXIS ready
    input        i_fifo_empty,
    // line interface (serial transmitter & memory)
    output       o_frame_data,
    output       o_frame_data_valid,
    output       o_frame_data_fas,
    // hardware interface
    output       o_crc_val
);

    // quick rundown for making internal signals:
    // Use reg for a signal when it is assigned in a process
    // Use wire for a signal when it is the output of an instantiated module or is assigned concurrently.
    
    // FPC signals
    reg [0:1]  fpc_row_cnt;
    reg [0:1]  fpc_col_cnt;
    
    // frame controller output
    reg [7:0]  frm_cntrl_frame_data;
    reg        frm_cntrl_frame_data_valid;
    reg        frm_cntrl_frame_data_fas;
    
    // Some useful operators:
    // some_signal = {signal1, signal2}; // signal concatenation
    // somesignal[7:0] = {8{1'b1}};      // replication operator. Assigns 8 1's to that signal.
    // somesignal[0 +: 7]                // indexed part select. wont need to be used very often but very useful, i suggest looking into how it works
    
    // -- Basic structure for a clocked process --
    always @(posedge i_clk) begin
        // fpc row & col cnt pipeline
        fpc_row_cnt[1] <= fpc_row_cnt[0];
        fpc_col_cnt[1] <= fpc_col_cnt[0];
    end
    
    // -- Basic structure for a combinational process --
    always @(*) begin // No sensitivity list!!!! yay!!
    end
    
    // Frame position counter
    fpc fpc_map_inst (
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .i_valid    (i_pyld_data_valid),
        
        .o_row_cnt  (fpc_row_cnt[0]),
        .o_col_cnt  (fpc_col_cnt[0])
    );
    
    
    frame_controller frm_cntrl_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_row_cnt          (fpc_row_cnt[0]),
        .i_col_cnt          (fpc_col_cnt[0]),
        // client interface
        .i_pyld_data        (i_pyld_data),
        .i_pyld_data_valid  (i_pyld_data_valid),
        // line interface
        .o_frame_data       (frm_cntrl_frame_data),
        .o_frame_data_valid (frm_cntrl_frame_data_valid),
        .o_frame_data_fas   (frm_cntrl_frame_data_fas)
    );
    
    crc_calc #(
        .MAP_MODE           (1)
    ) crc_calc_map_inst (
        // clock and control
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_row_cnt          (fpc_row_cnt[1]),
        .i_col_cnt          (fpc_col_cnt[1]),
        // line interface in
        .i_frame_data       (frm_cntrl_frame_data),
        .i_frame_data_valid (frm_cntrl_frame_data_valid),
        .i_frame_data_fas   (frm_cntrl_frame_data_fas),
        // line interface out
        .o_frame_data       (o_frame_data),
        .o_frame_data_valid (),
        .o_frame_data_fas   (),
        // hardware interface
        .o_crc_val          (o_crc_val),
        // DEMAP only
        .o_crc_err          (/*open*/)
    
    );
    
    


endmodule