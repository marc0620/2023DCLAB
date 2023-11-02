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
	output [19:0]o_sram_addr,  // addr_play
    output [2:0] o_state,
    output reg o_fin
);

    localparam S_IDLE = 2'd0;
    localparam S_PLAY = 2'd1;
    localparam S_PAUSE = 2'd2;

    logic [1:0] state, state_next;
    logic [19:0] sram_addr_r,sram_addr_w;
    logic signed [15:0] dac_data_r,dac_data_w;
    logic signed [15:0] previous_data_r, previous_data_w;
    logic previous_daclrck_r, previous_daclrck_w;
    logic o_fin_next;
    logic [3:0] count_w, count_r;
    assign o_sram_addr = sram_addr_r;
    assign o_dac_data = dac_data_r;
    assign o_state = state;
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
always_comb begin
    previous_daclrck_w = i_daclrck;
    dac_data_w = dac_data_r;
    sram_addr_w = sram_addr_r;
    previous_data_w = previous_data_r;
    o_fin_next=o_fin;
    case(state)
        S_IDLE: begin
            o_fin_next=0;
            count_w = 4'b0;
            if(i_start) begin
                dac_data_w = i_sram_data;
                sram_addr_w = 20'b0;
            end
        end
        S_PLAY: begin
            if(i_stop || (sram_addr_r >= i_stop_addr)) begin
                dac_data_w = 16'bz;
                sram_addr_w = 20'b0;
                o_fin_next=1;
                previous_daclrck_w =0;
            end
            else if(i_pause) begin
                dac_data_w = 16'bz;
                sram_addr_w = sram_addr_r;
                previous_data_w = previous_daclrck_r;
            end
            else begin
                if(i_slow_1) begin
                    dac_data_w = ($signed(i_sram_data) * $signed(count_r) + previous_data_r * ($signed(i_speed + 1) - $signed(count_r)) ) / $signed(count_r);
                    if (count_r > i_speed) begin
                        count_w         = (previous_daclrck_r & !i_daclrck) ? 4'd1: count_r;
                        sram_addr_w     = (previous_daclrck_r & !i_daclrck) ? sram_addr_r + 1 : sram_addr_r;
                        previous_data_w = (!previous_daclrck_r & i_daclrck) ? $signed(i_sram_data) : previous_data_r;
                    end
                    else begin
                        count_w =  (previous_daclrck_r & !i_daclrck) ? count_r + 1: count_r;
                    end
                end
                //normal
                dac_data_w = i_sram_data;
                sram_addr_w = (previous_daclrck_r && !i_daclrck)? sram_addr_r + 1 : sram_addr_r;

            end
            
        end
        S_PAUSE: begin
            if(i_stop) begin
                previous_data_w = 16'b0;
                sram_addr_w = 20'b0;
                count_w = 4'b0;
            end
            else if(i_start) begin
                previous_data_w = previous_data_r;
                sram_addr_w = sram_addr_r;
                count_w = count_r;
            end
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        sram_addr_r <= 20'b0;
        dac_data_r <= 16'bz;
        previous_data_r <= 16'b0;
        previous_daclrck_r <= 0;
        count_r <=0;
        o_fin<=0;
    end
    else begin
        sram_addr_r <= sram_addr_w;
        dac_data_r <= dac_data_w;
        previous_data_r <= previous_data_w;
        previous_daclrck_r <= previous_daclrck_w;
        count_r <= count_w;
        o_fin<=o_fin_next;
    end
end

endmodule