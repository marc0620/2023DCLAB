module AudDSP(
	input i_rst_n,
	input i_clk,
	input i_start,
	input i_pause,
	input i_stop,
	input [2:0] i_speed, //i_speed + 1 is the real speed
	input i_fast,
	input i_slow_0, // constant interpolation
	input i_slow_1, // linear interpolation
    input i_reverse,
	input i_daclrck,
	input [15:0] i_sram_data,
    input [19:0] i_stop_addr,
	output[15:0] o_dac_data,
	output[19:0] o_sram_addr,
    output o_fin,
    output [2:0] o_state
);

    //parameters
    localparam S_IDLE = 0;
    localparam S_PLAY = 1;
    localparam S_PAUSE = 2;
    //localparam end_addr = 1024000;

    //registers and wires
    logic [1:0]  state_r, state_w;
    logic signed [15:0] o_dac_data_r, o_dac_data_w;
    logic signed [15:0] prev_data_r, prev_data_w;
    logic [19:0] o_sram_addr_r, o_sram_addr_w;
    logic [3:0]  counter_r, counter_w;
    logic [3:0]  ratio;
    logic        prev_daclrck_r, prev_daclrck_w;
    logic o_fin_next;
    //assign ratio = signed'(counter_r)/signed'(i_speed);

    //output
    assign o_dac_data=o_dac_data_w;
    assign o_sram_addr = o_sram_addr_w;
    assign o_state=state_r;
    //combinational circuit
    always_comb begin
        prev_daclrck_w = i_daclrck;
        o_fin_next=o_fin;
        case(state_r)
            S_IDLE: begin
                o_fin_next=0;
                if(i_start) begin
                    state_w = S_PLAY;
                    o_dac_data_w = i_sram_data;
                    o_sram_addr_w = (i_reverse)? i_stop_addr : o_sram_addr_r;
                    prev_data_w = 16'd0;
                    counter_w = 4'd0;
                end
                else begin
                    state_w = S_IDLE;
                    o_dac_data_w = 16'bZ;
                    o_sram_addr_w = 20'd0;
                    prev_data_w = 16'b0;
                    counter_w = 4'd0;
                end
            end
            S_PLAY: begin
                if((i_stop || (o_sram_addr_r >= i_stop_addr)) && i_slow_1) begin
                    state_w = S_IDLE;
                    o_dac_data_w = prev_data_r;
                    o_sram_addr_w = 20'd0;
                    prev_data_w = 16'b0;
                    counter_w = 4'd0;
                    o_fin_next=1;
                end
                else if(i_stop || ((o_sram_addr_r >= i_stop_addr) && (~i_reverse)) || ((o_sram_addr_r == 20'd0) && (i_reverse))) begin
                    state_w = S_IDLE;
                    o_dac_data_w = 16'bZ;
                    o_sram_addr_w = 20'd0;
                    prev_data_w = 16'b0;
                    counter_w = 4'd0;
                    o_fin_next=1;
                end
                else if(i_pause) begin
                    state_w = S_PAUSE;
                    o_dac_data_w = 16'bZ;
                    o_sram_addr_w = o_sram_addr_r;
                    prev_data_w = prev_data_r;
                    counter_w = counter_r;
                end
                else begin
                    state_w = S_PLAY;
                    if(i_fast) begin
                        o_dac_data_w = i_sram_data;
                        o_sram_addr_w = (prev_daclrck_r && ~i_daclrck)? (o_sram_addr_r + i_speed + 20'd1) : o_sram_addr_r;
                        prev_data_w = 16'b0;
                        counter_w = 4'd0;
                    end
                    else if(i_slow_0) begin
                        o_dac_data_w = i_sram_data;
                        prev_data_w = 16'b0;
                        if(counter_r > i_speed) begin
                            o_sram_addr_w = (prev_daclrck_r && ~i_daclrck)? o_sram_addr_r + 20'd1 : o_sram_addr_r;
                            counter_w = (prev_daclrck_r && ~i_daclrck)? 4'd1 : counter_r;
                        end
                        else begin
                            o_sram_addr_w = o_sram_addr_r;
                            counter_w = (prev_daclrck_r && ~i_daclrck)? (counter_r + 4'd1) : counter_r;
                        end
                    end
                    else if(i_slow_1) begin
                        o_dac_data_w = (counter_r == 4'd4) ? (prev_data_r * (1 + $signed(i_speed) - $signed(0)) + $signed(i_sram_data) * $signed(0)) / (1 + $signed(i_speed)) :
                                                             (prev_data_r * (1 + $signed(i_speed) - $signed(counter_r)) + $signed(i_sram_data) * $signed(counter_r)) / (1 + $signed(i_speed));
                        if(counter_r > i_speed) begin
                            prev_data_w = (~prev_daclrck_r && i_daclrck)? $signed(i_sram_data) : prev_data_r;
                            o_sram_addr_w = (prev_daclrck_r && ~i_daclrck)? o_sram_addr_r + 20'd1 : o_sram_addr_r;
                            counter_w = (prev_daclrck_r && ~i_daclrck)? 4'd1 : counter_r;
                        end
                        else begin
                            o_sram_addr_w = o_sram_addr_r;
                            prev_data_w = prev_data_r;
                            counter_w = (prev_daclrck_r && ~i_daclrck)? (counter_r + 4'd1) : counter_r;
                        end
                    end
                    else if(i_reverse) begin
                        o_dac_data_w = i_sram_data;
                        o_sram_addr_w = (prev_daclrck_r && ~i_daclrck)? (o_sram_addr_r - 20'd1) : o_sram_addr_r;
                        prev_data_w = 16'b0;
                        counter_w = 4'd0;
                    end
                    else begin
                        o_dac_data_w = i_sram_data;
                        o_sram_addr_w = (prev_daclrck_r && ~i_daclrck)? (o_sram_addr_r + 20'd1) : o_sram_addr_r;
                        prev_data_w = 16'b0;
                        counter_w = 4'd0;
                    end
                end
            end
            S_PAUSE: begin
                if(i_start) begin
                    state_w = S_PLAY;
                    o_dac_data_w = 16'bZ;
                    o_sram_addr_w = o_sram_addr_r;
                    prev_data_w = prev_data_r;
                    counter_w = counter_r;
                end
                else if(i_stop) begin
                    state_w = S_IDLE;
                    o_dac_data_w = 16'bZ;
                    o_sram_addr_w = 20'd0;
                    prev_data_w = 16'b0;
                    counter_w = 4'd0;
                end
                else begin
                    state_w = S_PAUSE;
                    o_dac_data_w = 16'bZ;
                    o_sram_addr_w = o_sram_addr_r;
                    prev_data_w = prev_data_r;
                    counter_w = counter_r;
                end
            end
            default: begin
                state_w = state_r;
                o_dac_data_w = 16'bZ;
                o_sram_addr_w = o_sram_addr_r;
                prev_data_w = prev_data_r;
                counter_w = counter_r;
            end
        endcase
    end
    
    //sequential circuit
    always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            state_r         <= S_IDLE;
            o_dac_data_r    <= 16'bZ;
            o_sram_addr_r   <= 20'd0;
            prev_data_r     <= 16'b0;
            counter_r       <= 4'd0;
            prev_daclrck_r  <= 1'b0;
            o_fin<=1'b0;
        end
        else begin
            state_r         <= state_w;
            o_dac_data_r    <= o_dac_data_w;
            o_sram_addr_r   <= o_sram_addr_w;
            prev_data_r     <= prev_data_w;
            counter_r       <= counter_w;
            prev_daclrck_r  <= prev_daclrck_w;
            o_fin<=o_fin_next;
        end
    end

endmodule