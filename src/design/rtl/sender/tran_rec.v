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
    // output control signals
    output  o_fifo_ready,
    output  o_retrans_req,
    // data in/out of the FPGA
    output  o_otn_rx_data,
    input   i_otn_tx_ack,
    // fpga switch input
    input   i_arq_en
);

    // STATE MACHINE
    localparam idle           = 3'b000;
    localparam send_frame     = 3'b001;
    localparam ack_wait       = 3'b010;
    localparam read_ack       = 3'b011;
    localparam check_ack      = 3'b100;
    localparam send_mem_frame = 3'b101;
    reg [1:0] c_state, r_state;
    
    // byte count for transmission
    reg [12:0] c_byte_count, r_byte_count;
    
    // clock domain synchronization registers for i_otn_tx_ack
    // CURRENT ACK FORMAT: i_otn_tx_ack is held high by default. Upon detection of a low bit (start bit),
    //                     the following bit is the ACK itself. IMPORTANT: '1' = GOOD RESPONSE, '0' = BAD RESPONSE
    //                     Following the ACK bit is another low bit (stop bit). This ends the ACK sequence, and i_otn_tx_ack
    //                     should go high again.
    reg [0:2] otn_tx_ack_sync_arr;
    
    // internal extracted ACK
    reg c_otn_tx_ack, r_otn_tx_ack;
    
    // Bad ACK indicator, stays high until resolved
    reg c_ack_bad, r_ack_bad;

    // RX FIFO (Takes in mapped OTN data, sends it out of FPGA thru state machine)
    axis_data_fifo_rx axis_fifo_inst (
        .s_axis_aresetn  (~i_rst),  
        .s_axis_aclk     (i_clk),        
        .s_axis_tvalid   (i_frame_data_valid),    
        .s_axis_tready   (o_fifo_ready),    
        .s_axis_tdata    (i_frame_data),     
        .m_axis_tvalid   (),    
        .m_axis_tready   (),    
        .m_axis_tdata    (), 
        .almost_empty    ()
    );
    
    
    always @(*) begin : StateProc
        c_state = r_state;
        if (i_rst) begin
            c_state = idle;
        end else begin
            case (r_state)
                idle : begin
                    if (i_frame_data_fas) begin
                        c_state = send_frame;
                    end
                end
                send_frame : begin
                    if (r_byte_count == 4164) begin // frame is done transmitting?
                        if (i_arq_en) begin// is ARQ enabled??
                            c_state = ack_wait;
                        end else begin
                            c_state = idle;
                        end
                    end
                end
                ack_wait : begin
                    if (!otn_tx_ack_sync_arr[2]) begin // ACK start bit detected
                        c_state = read_ack;
                    end
                end
                read_ack : c_state <= check_ack;
                check_ack : begin
                    // is the ACK good or bad???
                    c_state = (r_otn_tx_ack) ? idle : send_mem_frame;
                end
                send_mem_frame : begin
                    if (r_byte_count == 4164) begin // mem frame is done transmitting?
                        c_state = ack_wait;
                    end
                end
                default : c_state = idle;
            endcase
        end
    end
    
    // byte count process
    always @(*) begin : CounterProc
        if (i_rst) begin
            c_byte_count = 0;
        end else begin
            case (r_state)
                send_frame     : c_byte_count = r_byte_count + 1;
                send_mem_frame : c_byte_count = r_byte_count + 1;
                default        : c_byte_count = 0;
            endcase
        end
    end
    
    // ACK extraction process
    always @(*) begin : AckProc
        if (i_rst) begin
            c_otn_tx_ack = 1'b0;
        end else begin
            if (r_state == read_ack) begin
                c_otn_tx_ack = otn_tx_ack_sync_arr[2];
            end else begin
                c_otn_tx_ack = r_otn_tx_ack;
            end
        end
    end
    
    // TODO: retransmit request output process (to rest of system)
    
    // serializer process (TODO)
    always @(*) begin : SerialProc
    end
    
    always @(posedge i_clk) begin : RegProc
        integer I;
        r_state      <= c_state;
        r_byte_count <= c_byte_count;
        r_otn_tx_ack <= c_otn_tx_ack;
        for (I = 0; I < 3; I = I + 1) begin 
            if (I == 0) begin otn_tx_ack_sync_arr[0] <= i_otn_tx_ack;             end 
            else        begin otn_tx_ack_sync_arr[I] <= otn_tx_ack_sync_arr[I-1]; end
        end
    end

endmodule