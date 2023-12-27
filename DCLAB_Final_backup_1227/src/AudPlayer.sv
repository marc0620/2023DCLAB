module AudPlayer (
	input 		  i_rst_n,
	input 		  i_clk,
	input 		  i_lrc,
	input 		  i_en, // enable AudPlayer only when playing audio, work with AudDSP
	input  signed [15:0] i_dac_data, //dac_data
	output 		  o_aud_dacdat,
	output		  [1:0] o_state
);

parameter S_IDLE = 0;
parameter S_PLAY = 1;
parameter S_WAIT = 2;

logic [ 1:0] state_r, state_w;
assign o_state = state_r;
logic [ 3:0] counter_r, counter_w;
logic 		 l_finish_r, l_finish_w;
logic 		 o_aud_dacdat_r, o_aud_dacdat_w;



logic signed [15:0] i_dac_data_slow1;
// assign i_dac_data_slow1 = i_dac_data;
// need a slow FF to delay the i_dac_data for an LRCK cycle
always_ff @(posedge i_lrc or negedge i_rst_n) begin
	if(~i_rst_n) begin
		i_dac_data_slow1 <= 0;
	end 
	else begin
		i_dac_data_slow1 <= i_dac_data;
	end
end


assign o_aud_dacdat = o_aud_dacdat_r;

always_comb begin 
	case (state_r)
		S_IDLE : begin 
			if (i_en && i_lrc) begin
				state_w = S_WAIT;
				counter_w = 15;
				l_finish_w = 0;
				o_aud_dacdat_w = 0;
			end
			else begin 
				state_w = S_IDLE;
				counter_w = 15;
				l_finish_w = 0;
				o_aud_dacdat_w = 0;
			end
		end
		S_WAIT : begin 
			if (!i_en) begin
				state_w = S_IDLE;
				counter_w = 15;
				l_finish_w = 0;
				o_aud_dacdat_w = 0;
			end
			else if (!i_lrc && l_finish_r) begin
				state_w = S_PLAY;
				counter_w = counter_r - 1;
				l_finish_w = 0;
				o_aud_dacdat_w = i_dac_data_slow1[counter_r];
			end
			else if (i_lrc) begin
				state_w = S_WAIT;
				counter_w = 15;
				l_finish_w = 1;
				o_aud_dacdat_w = 0;
			end
			else begin 
				state_w = S_WAIT;
				counter_w = 15;
				l_finish_w = 0;
				o_aud_dacdat_w = 0;
			end
		end
		S_PLAY : begin 
			if (!i_en) begin
				state_w = S_IDLE;
				counter_w = 15;
				l_finish_w = 0;
				o_aud_dacdat_w = 0;
			end
			else if (counter_r == 0) begin
				state_w = S_WAIT;
				counter_w = 15;
				l_finish_w = 0;
				o_aud_dacdat_w = i_dac_data_slow1[counter_r];
			end
			else begin 
				state_w = S_PLAY;
				counter_w = counter_r - 1;
				l_finish_w = 0;
				o_aud_dacdat_w = i_dac_data_slow1[counter_r];
			end
		end
		default : begin 
			state_w = S_IDLE;
			counter_w = 15;
			l_finish_w = 0;
			o_aud_dacdat_w = 0;
		end
	endcase
end

always_ff @(negedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		state_r 		<= S_IDLE;
		counter_r 		<= 15;
		l_finish_r 		<= 0;
		o_aud_dacdat_r 	<= 0;
	end 
	else begin
		state_r 		<= state_w;
		counter_r 		<= counter_w;
		l_finish_r 		<= l_finish_w;
		o_aud_dacdat_r 	<= o_aud_dacdat_w;
	end
end

endmodule
