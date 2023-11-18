// tran_rec.v
// CMPE 670 Project Fall 2023
// Author(s):
//  John Evans
module tran_rec (
    // clock and control
    input   i_clk,
    input   i_rst,
    // data from/to the mapper
    input   i_frame_data,
    input   i_frame_data_valid,
    input   i_frame_data_fas,
    output  o_fifo_rdy,
    output  o_retrans_req,
    // data in/out of the FPGA
    output  o_otn_rx_data,
    output  i_otn_tx_ack,
    // fpga switch input
    input   i_arq_en
);

    // RX FIFO (Takes in mapped OTN data, sends it out of FPGA thru state machine)
    axis_data_fifo_rx axis_fifo_inst (
        .s_axis_aresetn  (~i_rst),  
        .s_axis_aclk     (i_clk),        
        .s_axis_tvalid   (i_frame_data_valid),    
        .s_axis_tready   (o_fifo_rdy),    
        .s_axis_tdata    (i_frame_data),     
        .m_axis_tvalid   (),    
        .m_axis_tready   (),    
        .m_axis_tdata    (), 
        .almost_empty    ()
    );

endmodule