module AudDSP(
    input i_rst_n,
	input i_clk,
	input i_start,
	input i_pause,		// for 暫停
	input i_stop,		// for 停止
	input [2:0] i_speed,
	input i_fast,
	input i_slow_0,
	input i_slow_1,
	input i_daclrck,    // i_AUD_DACLRCK
	input [15:0]i_sram_data,  // data_play
	input [19:0] i_stop_addr,
	output [15:0]o_dac_data,  // dac_data_r
	output [19:0]o_sram_addr  // addr_play

);

    localparam S_IDLE = 2'd0;
    localparam S_PLAY = 2'd1;
    localparam S_PAUSE = 2'd2;

    logic [1:0] state, state_next;
    logic [19:0] sram_addr_r,sram_addr_w;
    logic signed [15:0] dac_data_r,dac_data_w;
    logic signed [15:0] previous_data_r, previous_data_w;

    assign o_sram_addr = sram_addr_r;
    assign o_dac_data = dac_data_r;
//fsm
always_comb begin
    state_next = state;
    case(state)
        S_IDLE: begin
            if(i_start) begin
                state_next = S_PLAY;
            end
            else begin
                state_next = S_IDLE;
            end
        end
        S_PLAY: begin
            if(i_stop || (sram_addr_r >= i_stop_addr)) begin
                state_next = S_IDLE;
            end
            else if(i_pause) begin
                state_next = S_PAUSE;
            end
            
        end
        S_PAUSE: begin
            if(i_stop) begin
                state_next = S_IDLE;
            end
            else if(i_start) begin
                state_next = S_PLAY;
            end
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state <= S_IDLE;
    end
    else begin
        state <= state_next;
    end
end

//
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        sram_addr_r <= 20'b0;
        dac_data_r <= 16'z;
        previous_data_r <= 16'b0;
    end
    else begin
        sram_addr_r <= sram_addr_w;
        dac_data_r <= dac_data_w;
        previous_data_r <= previous_data_w;
    end
end

endmodule