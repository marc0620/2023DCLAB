module keyboard_decoder (
    input  i_clk_100k,   //
    inout  PS2_CLK, // 10~16.7 kHz
    input  i_rst_n,
    inout  PS2_DAT,
    output [31:0] o_key,
    output [2:0] o_state,
    output [2:0] o_state_next
);

//tristate control

localparam INIT = 0;
localparam IDLE = 1;
localparam ACTIVE = 2;

localparam INIT_WAITING = 1;
localparam INIT_ACTIVE = 0;
localparam INIT_RESP=2;
localparam INIT_STAB=3;

logic [2:0] state_r, state_w;
logic [2:0] init_state_r, init_state_w;
logic [31:0] o_key_w, o_key_r;
logic init_w, init_r;
logic de, ce,ps2_clk_out , ps2_dat_out,ps2_clk_in, ps2_dat_in;
logic ps2_clk_syn0, ps2_clk_syn1, ps2_dat_syn0, ps2_dat_syn1;
logic [5:0] receive_cnt_r, receive_cnt_w;
logic [5:0] init_pdn_count_r, init_pdn_count_w, init_send_count_r, init_send_count_w, init_cmd_count_r, init_cmd_count_w,init_resp_count_r,init_resp_count_w;
logic [8:0] init_stab_count;
logic [8:0] init_cmd_r, init_cmd_w;
logic [7:0] receive_data_r, receive_data_w;
// tristate
assign PS2_DAT = de ? ps2_dat_out : 1'bz;
assign o_key = o_key_r;
assign PS2_CLK = ce ? ps2_clk_out : 1'bz;
assign ps2_dat_syn0 = de?1'b1: PS2_DAT;
assign ps2_clk_syn0 = ce?1'b1:PS2_CLK;
assign o_state=state_r;
assign o_state_next=init_cmd_count_r;
always@(posedge i_clk_100k) begin
	begin
		ps2_clk_syn1 <= ps2_clk_syn0;
		ps2_clk_in   <= ps2_clk_syn1;
		ps2_dat_syn1 <= ps2_dat_syn0;
		ps2_dat_in   <= ps2_dat_syn1;
	end
end
//TODO: add init command here
localparam COMMAND_NUM = 5;
localparam bit [8:0]  COMMANDS [0:COMMAND_NUM-1] = '{
9'b111110000, //set scan code
9'b000000001, //set scan code
9'b111101101, //set light
9'b000000111, //set light
9'b011110100  //enable
};

// init logic
always_comb begin
    init_pdn_count_w=1'b0;
    init_send_count_w=1'b0;
    ps2_clk_out = 1'b0;
    ps2_dat_out = 1'b0;
    init_cmd_count_w = init_cmd_count_r;
    init_cmd_w = init_cmd_r;
    receive_cnt_w = 0;
    de = 1'b0;
    ce = 1'b0;
    receive_data_w = receive_data_r;
    o_key_w = o_key_r;
    init_resp_count_w=0;
    case (state_r)
        INIT: begin
            case (init_state_r)
                INIT_WAITING: begin
                    de = 1'b0;
                    ce = 1'b1;
                    init_cmd_w = COMMANDS[init_cmd_count_r];
                    if(init_pdn_count_r <= 12) begin
                        init_pdn_count_w = init_pdn_count_r+1;
                    end
                end
                INIT_ACTIVE: begin
                    ce = 1'b0;
                    de = 1'b1;
                    if (init_send_count_r == 11) begin
                        init_cmd_count_w = init_cmd_count_r+1;
                    end 
                    init_send_count_w = init_send_count_r+1;
                    if(init_send_count_r >= 1 && init_send_count_r <= 9) begin
                        ps2_dat_out = init_cmd_r[init_send_count_r-1];
                    end else if(init_send_count_r>=10)begin
                        de=0;
                    end
                end
                INIT_RESP: begin
                    ce=1'b0;
                    de=1'b0;
                    init_resp_count_w=init_resp_count_r+1;
                end
            endcase
        end
        IDLE: begin
        end
        ACTIVE: begin
            receive_cnt_w = receive_cnt_r+1;
            if (receive_cnt_r>8) begin
                case(receive_data_r)
                    8'h10: begin
                        o_key_w[0] = 1'b1;
                    end
                    8'h03: begin
                        o_key_w[1] = 1'b1;
                    end
                    8'h11: begin
                        o_key_w[2] = 1'b1;
                    end
                    8'h04: begin
                        o_key_w[3] = 1'b1;
                    end
                    8'h12: begin
                        o_key_w[4] = 1'b1;
                    end
                    8'h13: begin
                        o_key_w[5] = 1'b1;
                    end
                    8'h06: begin
                        o_key_w[6] = 1'b1;
                    end
                    8'h14: begin
                        o_key_w[7] = 1'b1;
                    end
                    8'h07: begin
                        o_key_w[8] = 1'b1;
                    end
                    8'h15: begin
                        o_key_w[9] = 1'b1;
                    end
                    8'h08: begin
                        o_key_w[10] = 1'b1;
                    end
                    8'h16: begin
                        o_key_w[11] = 1'b1;
                    end
                    8'h17: begin
                        o_key_w[12] = 1'b1;
                    end
                    8'h0a: begin
                        o_key_w[13] = 1'b1;
                    end
                    8'h18: begin
                        o_key_w[14] = 1'b1;
                    end
                    8'h0b: begin
                        o_key_w[15] = 1'b1;
                    end
                    8'h19: begin
                        o_key_w[16] = 1'b1;
                    end
                    8'h2c: begin
                        o_key_w[17] = 1'b1;
                    end
                    8'h1f: begin
                        o_key_w[18] = 1'b1;
                    end
                    8'h2d: begin
                        o_key_w[19] = 1'b1;
                    end
                    8'h20: begin
                        o_key_w[20] = 1'b1;
                    end
                    8'h2e: begin
                        o_key_w[21] = 1'b1;
                    end
                    8'h21: begin
                        o_key_w[22] = 1'b1;
                    end
                    8'h2f: begin
                        o_key_w[23] = 1'b1;
                    end
                    8'h30: begin
                        o_key_w[24] = 1'b1;
                    end
                    8'h23: begin
                        o_key_w[25] = 1'b1;
                    end
                    8'h31: begin
                        o_key_w[26] = 1'b1;
                    end
                    8'h24: begin
                        o_key_w[27] = 1'b1;
                    end
                    8'h32: begin
                        o_key_w[28] = 1'b1;
                    end
                    8'h33: begin
                        o_key_w[29] = 1'b1;
                    end
                    8'h26: begin
                        o_key_w[30] = 1'b1;
                    end
                    8'h34: begin
                        o_key_w[31] = 1'b1;
                    end
                    8'h90: begin
                        o_key_w[0] = 1'b0;
                    end
                    8'h83: begin
                        o_key_w[1] = 1'b0;
                    end
                    8'h91: begin
                        o_key_w[2] = 1'b0;
                    end
                    8'h84: begin
                        o_key_w[3] = 1'b0;
                    end
                    8'h92: begin
                        o_key_w[4] = 1'b0;
                    end
                    8'h93: begin
                        o_key_w[5] = 1'b0;
                    end
                    8'h86: begin
                        o_key_w[6] = 1'b0;
                    end
                    8'h94: begin
                        o_key_w[7] = 1'b0;
                    end
                    8'h87: begin
                        o_key_w[8] = 1'b0;
                    end
                    8'h95: begin
                        o_key_w[9] = 1'b0;
                    end
                    8'h88: begin
                        o_key_w[10] = 1'b0;
                    end
                    8'h96: begin
                        o_key_w[11] = 1'b0;
                    end
                    8'h97: begin
                        o_key_w[12] = 1'b0;
                    end
                    8'h8a: begin
                        o_key_w[13] = 1'b0;
                    end
                    8'h98: begin
                        o_key_w[14] = 1'b0;
                    end
                    8'h8b: begin
                        o_key_w[15] = 1'b0;
                    end
                    8'h99: begin
                        o_key_w[16] = 1'b0;
                    end
                    8'hac: begin
                        o_key_w[17] = 1'b0;
                    end
                    8'h9f: begin
                        o_key_w[18] = 1'b0;
                    end
                    8'had: begin
                        o_key_w[19] = 1'b0;
                    end
                    8'ha0: begin
                        o_key_w[20] = 1'b0;
                    end
                    8'hae: begin
                        o_key_w[21] = 1'b0;
                    end
                    8'ha1: begin
                        o_key_w[22] = 1'b0;
                    end
                    8'haf: begin
                        o_key_w[23] = 1'b0;
                    end
                    8'hb0: begin
                        o_key_w[24] = 1'b0;
                    end
                    8'ha3: begin
                        o_key_w[25] = 1'b0;
                    end
                    8'hb1: begin
                        o_key_w[26] = 1'b0;
                    end
                    8'ha4: begin
                        o_key_w[27] = 1'b0;
                    end
                    8'hb2: begin
                        o_key_w[28] = 1'b0;
                    end
                    8'hb3: begin
                        o_key_w[29] = 1'b0;
                    end
                    8'hb6: begin
                        o_key_w[30] = 1'b0;
                    end
                    8'hb4: begin
                        o_key_w[31] = 1'b0;
                    end
                endcase
            end else begin
                if(receive_cnt_r >= 1 && receive_cnt_r <= 8) begin
                    receive_data_w[receive_cnt_r-1] = ps2_dat_in;
                end
            end
        end
    endcase
end

always @(posedge i_clk_100k or negedge i_rst_n) begin
    if (~i_rst_n) begin
        init_pdn_count_r <= 0;
        init_cmd_count_r <= 0;
        init_cmd_r <= 0;
        o_key_r <= 0;
        init_stab_count<=0;
        
    end else begin
        init_pdn_count_r <= init_pdn_count_w;
        init_cmd_count_r <= init_cmd_count_w;
        init_cmd_r <= init_cmd_w;
        o_key_r <= o_key_w;
        init_stab_count<=init_stab_count+1;
        
    end
end

always @(negedge ps2_clk_in or negedge i_rst_n) begin
    if (~i_rst_n) begin
        init_send_count_r <= 0;
        receive_cnt_r <= 0;
        receive_data_r <= 0;
        init_resp_count_r<=0;
    end else begin
        init_send_count_r <= init_send_count_w;
        receive_cnt_r <= receive_cnt_w;
        receive_data_r <= receive_data_w;
        init_resp_count_r<=init_resp_count_w;
    end
end

//main state machine
always_comb begin
    state_w=state_r;
    init_state_w=init_state_r;
    case (state_r)
        INIT: begin
            case (init_state_r)
                INIT_STAB:begin
                    if(init_stab_count==100) begin
                        init_state_w = INIT_WAITING;
                    end
                end
                INIT_WAITING: begin
                    if(init_pdn_count_r == 12) begin
                        init_state_w = INIT_ACTIVE;
                    end else begin
                        init_state_w = INIT_WAITING;
                    end
                end
                INIT_ACTIVE: begin
                    if (init_send_count_r == 11) begin
                        init_state_w = INIT_RESP;
                    end else begin
                        init_state_w = INIT_ACTIVE;
                    end
                end
                INIT_RESP: begin
                    if(init_resp_count_r==11) begin
                        if(init_cmd_count_r == COMMAND_NUM)begin
                            state_w = IDLE;
                        end
                        else begin
                            init_state_w=INIT_WAITING;
                        end
                    end
                end
            endcase
        end
        IDLE: begin
            if(!ps2_clk_in) begin
                state_w = ACTIVE;
            end else begin
                state_w = IDLE;
            end
        end
        ACTIVE: begin
            if (receive_cnt_r==10) begin
                state_w = IDLE;
            end else begin
                state_w = ACTIVE;
            end
        end
    endcase
end

always @(posedge i_clk_100k or negedge i_rst_n) begin
    if (~i_rst_n) begin
        state_r <= INIT;
        init_state_r <= INIT_STAB;
    end else begin
        state_r <= state_w;
        init_state_r <= init_state_w;
    end
end

endmodule
