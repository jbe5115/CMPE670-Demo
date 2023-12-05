// tran_rec.v
// CMPE 670 Project Fall 2023
// Author(s):
//  John Evans
module tran_rec (
    // clock and control
    input       i_clk,
    input       i_rst,
    input       i_sclk_en_16_x_baud,
    // data from/to the mapper
    input [7:0] i_frame_data,
    input       i_frame_data_valid,
    input       i_frame_data_fas,
    // output control signals
    output      o_fifo_ready,
    output      o_retrans_req,
    output      o_read_line_fifo, 
    output      o_send_complete,  // Data was successfully and correctly sent to receiver
    // data in/out of the FPGA
    output      o_otn_rx_data,
    input       i_otn_tx_ack,
    // fpga switch input
    input       i_arq_en
);

    // clock control
    reg [4:0]  scount5;
    // Baud rate enable indicator
    wire       baud_en;

    // STATE MACHINE
    localparam idle           = 3'b000;
    localparam send_frame     = 3'b001;
    localparam ack_wait       = 3'b010;
    localparam read_ack       = 3'b011;
    localparam check_ack      = 3'b100;
    localparam trans_complete = 3'b101;
    localparam send_mem_frame = 3'b110;
    reg [2:0] c_state, r_state;
    
    // total byte count for transmission
    reg [12:0] c_byte_count, r_byte_count;
    
    // serial bit transmission counter (0 to 7)
    reg [2:0]  c_bit_count, r_bit_count;
    // serial byte register
    reg [7:0]  c_current_byte, r_current_byte;
    // o_otn_rx_data register
    reg        c_otn_rx_data, r_otn_rx_data;
    
    
    // clock domain synchronization registers for i_otn_tx_ack
    // CURRENT ACK FORMAT: i_otn_tx_ack is held high by default. Upon detection of a low bit (start bit),
    //                     the following bit is the ACK itself. IMPORTANT: '1' = GOOD RESPONSE, '0' = BAD RESPONSE
    //                     Following the ACK bit is another low bit (stop bit). This ends the ACK sequence, and i_otn_tx_ack
    //                     should go high again.
    reg [0:2] otn_tx_ack_sync_arr;
    
    // internal extracted ACK
    reg c_otn_tx_ack, r_otn_tx_ack;
    
    // Bad ACK indicator, stays high until resolved
    reg c_retrans_req, r_retrans_req;
    
    // internal slave/master FIFO ready
    wire       s_fifo_ready, m_fifo_ready;
    wire       m_fifo_data_valid;
    wire [7:0] m_fifo_data;
   
    // direct output assignments
    assign o_send_complete  = (r_state == trans_complete);
    assign o_read_line_fifo = (r_state == send_mem_frame);
    assign o_retrans_req    = r_retrans_req;
    assign o_fifo_ready     = s_fifo_ready;
    assign o_otn_rx_data    = r_otn_rx_data;
    
    assign m_fifo_ready = ((r_state == send_frame) || (r_state == send_mem_frame)) && (r_bit_count == 3'd7) && baud_en;
    assign baud_en  = i_sclk_en_16_x_baud && (scount5 == 5'd19);

    // RX FIFO (Takes in mapped OTN data, sends it out of FPGA thru state machine)
    axis_data_fifo_rx axis_fifo_inst (
        .s_axis_aresetn  (~i_rst),  
        .s_axis_aclk     (i_clk),        
        .s_axis_tvalid   (i_frame_data_valid),    
        .s_axis_tready   (s_fifo_ready),    
        .s_axis_tdata    (i_frame_data),     
        .m_axis_tvalid   (m_fifo_data_valid),    
        .m_axis_tready   (m_fifo_ready),    
        .m_axis_tdata    (m_fifo_data), 
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
                    if (r_byte_count == 4165) begin // frame is done transmitting?
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
                read_ack : begin
                    c_state = check_ack;
                end
                check_ack : begin
                    // is the ACK good or bad???
                    c_state = (r_otn_tx_ack) ? trans_complete : send_mem_frame;
                end
                trans_complete : begin
                    c_state = idle;
                end
                send_mem_frame : begin
                    if (r_byte_count == 4165) begin // mem frame is done transmitting?
                        c_state = ack_wait;
                    end
                end
                default : begin
                    c_state = idle;
                end
            endcase
        end
    end
    
    // byte count process AND byte extraction process
    always @(*) begin : CounterProc
        c_byte_count   = r_byte_count;
        c_current_byte = r_current_byte;
        if (i_rst) begin
            c_byte_count = 13'd0;
            c_current_byte = 8'b0;
        end else begin
            if ((r_state == send_frame) || (r_state == send_mem_frame)) begin // condition 1
                if (m_fifo_ready && (m_fifo_data_valid || (r_byte_count == 4164)) && (r_bit_count == 3'd7)) begin // condition 2
                    if (baud_en) begin // condition 3
                        c_byte_count   = r_byte_count + 1;
                        c_current_byte = m_fifo_data;
                    end
                end
            end else begin
                c_byte_count = 13'd0;
                c_current_byte = 8'b0;                
            end
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
    
    // retransmit request output process (to rest of system)
    always @(*) begin : RetransProc
        if (i_rst) begin
            c_retrans_req = 1'b0;
        end else begin
            case (r_state)
                idle           : c_retrans_req = 1'b0;
                send_mem_frame : c_retrans_req = 1'b1;
                default        : c_retrans_req = r_retrans_req;
            endcase
        end
    end
    
    // serializer output process for o_otn_rx_data
    always @(*) begin : SerialProc
        c_otn_rx_data = r_otn_rx_data;
        if (i_rst) begin
            c_otn_rx_data = 1'b0;
        end else begin
            if ((r_state == send_frame) || (r_state == send_mem_frame)) begin
                case (r_bit_count)
                    3'd0    : c_otn_rx_data = r_current_byte[0];
                    3'd1    : c_otn_rx_data = r_current_byte[1];
                    3'd2    : c_otn_rx_data = r_current_byte[2];
                    3'd3    : c_otn_rx_data = r_current_byte[3];
                    3'd4    : c_otn_rx_data = r_current_byte[4];
                    3'd5    : c_otn_rx_data = r_current_byte[5];
                    3'd6    : c_otn_rx_data = r_current_byte[6];
                    default : c_otn_rx_data = r_current_byte[7]; // 3'd7
                endcase
            end
        end
    end
    
    // bit count process
    always @(*) begin : BitCountProc
        c_bit_count = r_bit_count;
        if (i_rst) begin
            c_bit_count = 3'd0;
        end else if (baud_en) begin
            if ((r_state == send_frame) || (r_state == send_mem_frame)) begin
                c_bit_count = r_bit_count + 1;
            end else begin
                c_bit_count = 3'd0;
            end
        end
    end
    
    // scount5 counter process
    always @(posedge i_clk) begin
        if (i_rst) begin
            scount5 <= 0;
        end else if (i_sclk_en_16_x_baud) begin
            if ((r_state == send_frame) || (r_state == send_mem_frame)) begin
                scount5 <= (scount5 == 19) ? 0 : scount5 + 1;
            end else begin
                scount5 <= 0;
            end
        end
    end
    
    always @(posedge i_clk) begin : RegProc
        integer I;
        r_state        <= c_state;
        r_byte_count   <= c_byte_count;
        r_otn_tx_ack   <= c_otn_tx_ack;
        r_retrans_req  <= c_retrans_req;
        r_bit_count    <= c_bit_count;
        r_current_byte <= c_current_byte;
        r_otn_rx_data  <= c_otn_rx_data;
        for (I = 0; I < 3; I = I + 1) begin 
            if (I == 0) begin otn_tx_ack_sync_arr[0] <= i_otn_tx_ack;             end 
            else        begin otn_tx_ack_sync_arr[I] <= otn_tx_ack_sync_arr[I-1]; end
        end
    end

endmodule