// rec_tran.v
// CMPE 670 Project Fall 2023
// Author(s):
//  John Evans
module rec_tran (
    // clock and control
    input        i_clk,
    input        i_rst,
    input        i_sclk_en_16_x_baud,
    input        i_crc_err,
    input        i_crc_err_valid,
    // data to the demapper
    output [7:0] o_frame_data,
    output       o_frame_data_valid,
    input        i_arq_en,
    input        i_arq_en_valid,
    // input control signals
    input        i_tx_fifo_ready,
    // data in/out of the FPGA
    output [2:0] o_rt_state,
    input        i_otn_tx_data,
    output reg   o_otn_rx_ack
);

    // clock control
    reg [4:0]  scount5;
    // Baud rate enable indicator
    wire       baud_en;

    // Frame start pattern
    localparam [0:47] FRAME_START = 48'hF6F6F6282828;

    // STATE MACHINE
    localparam idle            = 3'b000;
    localparam capture_pattern = 3'b001;
    localparam reset_fifo      = 3'b010;
    localparam get_frame       = 3'b011;
    localparam check_crc       = 3'b100;
    localparam send_good_ack   = 3'b101;
    localparam send_bad_ack    = 3'b110;
    reg [2:0] c_state, r_state;
    
    // 8-bit serial register, plus two more for metastability reduction
    reg  [0:9] otn_tx_data_arr;
    // reversed version
    wire [9:0] otn_tx_data_arr_r;
    
    // capture pattern state counter, counts 1 to 7
    reg [2:0] c_cap_count, r_cap_count;
    
    // bit count, indicates when serial buffer is full and a full frame byte has been received.
    reg [2:0] c_bit_count, r_bit_count;
    
    // frame byte count for receiving entire frame
    reg [12:0] c_byte_count, r_byte_count;
    
    // fifo frame data valid
    wire m_fifo_frame_data_valid;
    wire s_fifo_frame_data_valid;
    
    // arq_en register
    reg c_arq_en, r_arq_en;
    
    // send_good_ack/send_bad_ack counter
    reg [1:0] c_ack_count, r_ack_count;
    
    // output assignments
    assign o_frame_data_valid = m_fifo_frame_data_valid && !(r_state == capture_pattern);
    // baud_en assignment
    assign baud_en  = i_sclk_en_16_x_baud && (scount5 == 5'd19);
    
    // slave inteface fifo data valid
    assign s_fifo_frame_data_valid = (r_bit_count == 3'd0) && ((r_state == capture_pattern) || (r_state == get_frame)) && baud_en;
    
    assign o_rt_state = r_state;
    
    // reverse otn_tx_data_arr bits
    generate
        genvar i;
        for (i = 0; i < 10; i = i + 1) begin
            assign otn_tx_data_arr_r[i] = otn_tx_data_arr[9 - i];
        end
    endgenerate
    
    // state combinational process
    always @(*) begin : StateCombProc
        c_state = r_state;
        if (i_rst) begin
            c_state = idle;
        end else begin
            case (r_state)
                idle : begin
                    if (otn_tx_data_arr_r[9:2] == FRAME_START[0:7]) begin
                        c_state = capture_pattern;
                    end
                end
                capture_pattern : begin
                    if ((r_bit_count == 3'd0) && baud_en) begin
                        case (r_cap_count)
                            3'b000 : if (otn_tx_data_arr_r[9:2] == FRAME_START[0:7])  begin c_state = capture_pattern; end else begin c_state = reset_fifo; end
                            3'b001 : if (otn_tx_data_arr_r[9:2] == FRAME_START[8:15])  begin c_state = capture_pattern; end else begin c_state = reset_fifo; end
                            3'b010 : if (otn_tx_data_arr_r[9:2] == FRAME_START[16:23]) begin c_state = capture_pattern; end else begin c_state = reset_fifo; end
                            3'b011 : if (otn_tx_data_arr_r[9:2] == FRAME_START[24:31]) begin c_state = capture_pattern; end else begin c_state = reset_fifo; end
                            3'b100 : if (otn_tx_data_arr_r[9:2] == FRAME_START[32:39]) begin c_state = capture_pattern; end else begin c_state = reset_fifo; end
                            default : if (otn_tx_data_arr_r[9:2] == FRAME_START[40:47]) begin c_state = get_frame;      end else begin c_state = reset_fifo; end
                        endcase
                    end
                end
                reset_fifo : begin
                    c_state = idle;
                end
                get_frame : begin
                    if ((r_byte_count == 4159) && (r_bit_count == 0) && baud_en) begin
                        c_state = (r_arq_en) ? check_crc : idle;
                    end
                end
                check_crc : begin
                    if (i_crc_err_valid) begin
                        c_state = (i_crc_err) ? send_bad_ack : send_good_ack;
                    end
                end
                send_bad_ack : begin
                    if (r_ack_count == 2'b11) begin
                        c_state = idle;
                    end
                end
                send_good_ack : begin
                    if (r_ack_count == 2'b11) begin
                        c_state = idle;
                    end
                end
            endcase
        end
    end
    
    // capture count combinational process
    always @(*) begin : CapCombProc
        c_cap_count = r_cap_count;
        if (i_rst) begin
            c_cap_count = 3'b000;
        end else begin
            if (r_state == capture_pattern) begin
                if (baud_en && (r_bit_count == 3'd7)) begin
                    c_cap_count = r_cap_count + 1;
                end
            end else begin
                c_cap_count = 3'b000;
            end
        end
    end
    
    // frame byte count combinational process
    always @(*) begin : ByteCombProc
        c_byte_count = r_byte_count;
        if (i_rst) begin
            c_byte_count = 0;
        end else begin
            if (r_state == get_frame) begin
                if (baud_en && (r_bit_count == 3'd7)) begin
                    c_byte_count = r_byte_count + 1;
                end
            end else begin
                c_byte_count = 3'b001;
            end
        end
    end
    
    // bit count process
    always @(*) begin : BitCombProc
        c_bit_count = r_bit_count;
        if (i_rst) begin
            c_bit_count = 0;
        end else if (baud_en) begin
            if ((r_state == capture_pattern) || (r_state == get_frame)) begin
                c_bit_count = r_bit_count + 1;
            end else begin
                c_bit_count = 0;
            end
        end
    end
    
    // o_otn_rx_ack process
    always @(*) begin
        if ((r_state == send_good_ack) || (r_state == send_bad_ack)) begin // output good/bad ack
            case (r_ack_count)
                2'b00 : o_otn_rx_ack = 1'b0;                       // start bit
                2'b01 : o_otn_rx_ack = (r_state == send_good_ack); // send a '1' if there was no CRC error!
                2'b10 : o_otn_rx_ack = 1'b0;                       // stop bit
                default : o_otn_rx_ack = 1'b1;                     // null case
            endcase
        end else begin // idle state
            o_otn_rx_ack = 1'b1; 
        end
    end
    
    // c_ack_count process
    always @(*) begin
        c_ack_count = r_ack_count;
        if (i_rst) begin
            c_ack_count = 2'b00;
        end else begin
            if ((r_state == send_bad_ack) || (r_state == send_good_ack)) begin
                if (baud_en) begin
                    c_ack_count = r_ack_count + 1;
                end
            end else begin
                c_ack_count = 2'b00;
            end
        end
    end
    
    // i_arq_en extraction process
    always @(*) begin
        if (i_rst) begin
            c_arq_en = 1'b0;
        end else begin
            c_arq_en = (i_arq_en_valid) ? i_arq_en : r_arq_en;
        end
    end
    
    // Internal FIFO (Takes in parallel mapped OTN data, sends it out rec_tran to demapper)
    // reset FIFO if frame start pattern was broken :(
    axis_data_fifo_rx axis_fifo_inst (
        .s_axis_aresetn  (~(i_rst || (r_state == reset_fifo))),  
        .s_axis_aclk     (i_clk),        
        .s_axis_tvalid   (s_fifo_frame_data_valid),
        .s_axis_tready   (/*(don't worry, it WILL be ready)*/),    
        .s_axis_tdata    (otn_tx_data_arr_r[9:2]),     
        .m_axis_tvalid   (m_fifo_frame_data_valid),    
        .m_axis_tready   (i_tx_fifo_ready && !( r_state == capture_pattern )), // don't send out anything until frame pattern is fully captured. 
        .m_axis_tdata    (o_frame_data),  
        .almost_empty    (/* open */)
    );
    
    // scount5 counter process
    always @(posedge i_clk) begin
        if (i_rst) begin
            scount5 <= 0;
        end else if (i_sclk_en_16_x_baud) begin
            if ((r_state == idle) || (r_state == capture_pattern) || (r_state == get_frame) || (r_state == send_good_ack) || (r_state == send_bad_ack)) begin
                scount5 <= (scount5 == 19) ? 0 : scount5 + 1;
            end else begin
                scount5 <= 0;
            end
        end
    end
    
    // register update process
    always @(posedge i_clk) begin : RegProc
        integer I;
        r_state      <= c_state;
        r_cap_count  <= c_cap_count;
        r_bit_count  <= c_bit_count;
        r_byte_count <= c_byte_count;
        r_ack_count  <= c_ack_count;
        r_arq_en     <= c_arq_en;
        // incoming data array logic
        if (i_rst) begin
            otn_tx_data_arr <= 10'd0;
        end else if (baud_en) begin
            for (I = 0; I < 10; I = I + 1) begin 
                if (I == 0) begin otn_tx_data_arr[0] <= i_otn_tx_data;        end 
                else        begin otn_tx_data_arr[I] <= otn_tx_data_arr[I-1]; end
            end
        end    
    end
    
endmodule