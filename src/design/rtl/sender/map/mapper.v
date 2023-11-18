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
    output       o_frame_data_fas
);

    // quick rundown for making internal signals:
    // Use reg for a signal when it is assigned in a process
    // Use wire for a signal when it is the output of an instantiated module or is assigned concurrently.
    
    // Some useful operators:
    // some_signal = {signal1, signal2}; // signal concatenation
    // somesignal[7:0] = {8{1'b1}};      // replication operator. Assigns 8 1's to that signal.
    // somesignal[0 +: 7]                // indexed part select. wont need to be used very often but very useful, i suggest looking into how it works
    
    // -- Basic structure for a clocked process --
    always @(posedge i_clk) begin
    end
    
    // -- Basic structure for a combinational process --
    always @(*) begin // No sensitivity list!!!! yay!!
    end


endmodule