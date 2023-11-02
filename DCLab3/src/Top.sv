module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0,          // key 0: record
	input i_key_1,			// key 1: play
	input i_key_2,			// key 2: stop
	// input [3:0] i_speed, // design how user can decide mode on your own
	
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	output logic[2:0] o_state_num,
	output logic[2:0] o_state_num_nxt,
	output logic[2:0] o_state_RECD,
	output logic[2:0] o_state_DSP,
	output logic[2:0] o_state_PLAY,
	output o_i2c_oen,
	output l_bclk,
	output l_clk_a_bclk

	// SEVENDECODER (optional display)
	// output [5:0] o_record_time,
	// output [5:0] o_play_time,

	// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

	// LED
	// output  [8:0] o_ledg,
	// output [17:0] o_ledr
);

// design the FSM and states as you like
parameter S_IDLE       = 0;
parameter S_I2C        = 1;
parameter S_RECD       = 2;
parameter S_RECD_PAUSE = 3;
parameter S_PLAY       = 4;
parameter S_PLAY_PAUSE = 5;
assign o_state_num = state_r;
assign o_state_num_nxt = state_w;
assign o_i2c_fin = i2c_fin;
assign o_i2c_start = i2c_start;
assign l_bclk = i_AUD_BCLK;
assign l_clk_a_bclk = i_AUD_BCLK & i_clk;
logic [10:0] cntr2048, cntr2048_nxt;
logic i2c_oen, i2c_sdat, i2c_start, i2c_fin, i2c_start_next,i2c_sent,i2c_sent_next,rec_start,rec_start_next,rec_stop,rec_stop_next,rec_pause,rec_pause_next, play_en,play_en_next, dsp_start, dsp_start_next, dsp_pause, dsp_pause_next, dsp_stop, dsp_stop_next;
logic [19:0] addr_record, addr_play;
logic [15:0] data_record, data_play, dac_data;
logic [2:0] state_r, state_w;
assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;
assign o_i2c_oen = i2c_oen;

assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play[19:0];
assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

// below is a simple example for module division
// you can design these as you like

// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2CInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(i2c_start),
	.i_sdat(i2c_sdat),
	.o_finished(i2c_fin),
	.o_sclk(o_I2C_SCLK),
	.o_sdat(i2c_sdat),
	.o_oen(i2c_oen), // you are outputing (you are not outputing only when you are "ack"ing.)
	.o_state(o_state_I2C)
);



// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_AUD_BCLK),
	.i_start(dsp_start),
	.i_pause(dsp_pause),
	.i_stop(dsp_stop),
	.i_speed(),
	.i_fast(),
	.i_slow_0(), // constant interpolation
	.i_slow_1(), // linear interpolation
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play),
	.o_state(o_state_DSP)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(play_en), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT),
	.o_state(o_state_PLAY)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(rec_start),
	.i_pause(rec_pause),
	.i_stop(rec_stop),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record),
	.o_state(o_state_RECD)
);

always_comb begin
	// design your control here
	state_w=state_r;
	i2c_start_next=i2c_start;
	i2c_sent_next=i2c_sent;
	rec_start_next=rec_start;
	rec_stop_next=rec_stop;
	rec_pause_next=rec_pause;
	play_en_next=play_en;
	dsp_start_next=dsp_start;
	dsp_pause_next=dsp_pause;
	dsp_stop_next=dsp_stop;
	cntr2048_nxt = cntr2048;
	case (state_r)
		S_I2C: begin
			// if(i2c_start==1'b0 && i2c_sent==1'b0) begin
			// 	i2c_start_next=1'b1;
			// 	i2c_sent_next=1'b1;
			// end
			// else if(i2c_start==1'b1) begin
			// 	i2c_start_next=1'b0;
			// end
			if(cntr2048 < 2047)begin
				cntr2048_nxt = cntr2048 + 1;
				i2c_start_next=1'b1;
			end
			else begin
				i2c_start_next=1'b0;
			end
			
			
			if (i2c_fin==1'b1) begin
				state_w=S_IDLE;
			end
			else begin
				state_w=S_I2C;
			end
			
		end
		S_IDLE: begin
			if(i_key_0==1'b1) begin
				state_w=S_RECD;
				rec_start_next=1'b1;
				rec_stop_next=1'b0;
				dsp_stop_next=1'b0;
			end
			else if(i_key_1==1'b1) begin
				state_w=S_PLAY;
				play_en_next=1'b1;
				dsp_start_next=1'b1;
				rec_stop_next=1'b0;
				dsp_stop_next=1'b0;
			end
			else begin
				state_w=S_IDLE;
			end
		end
		S_RECD: begin
			if(i_key_2 ==1'b1)begin
				state_w=S_IDLE;
				rec_stop_next=1'b1;
				rec_start_next=1'b0;

			end
			else if(i_key_0==1'b1) begin
				state_w=S_RECD_PAUSE;
				rec_pause_next=1'b1;
				rec_start_next=1'b0;

			end
			else begin
				state_w=S_RECD;
			end
		end
		S_RECD_PAUSE: begin
			if(i_key_2) begin
				state_w=S_IDLE;
				rec_stop_next=1'b1;
				rec_pause_next=1'b0;

			end
			else if(i_key_0) begin
				state_w=S_RECD;
				rec_start_next=1'b1;
				rec_pause_next=1'b0;

			end
			else begin
				state_w=S_RECD_PAUSE;
			end
		end
		S_PLAY: begin
			
			if(i_key_2==1'b1) begin
				state_w=S_IDLE;
				dsp_stop_next=1'b1;
				play_en_next=1'b0;
				dsp_start_next=1'b0;
			end
			else if(i_key_1==1'b1) begin
				dsp_pause_next=1'b1;
				state_w=S_PLAY_PAUSE;
				play_en_next=1'b0;
				dsp_start_next=1'b0;
			end
			else begin
				state_w=S_PLAY;
			end
		end
		S_PLAY_PAUSE: begin
			if(i_key_2==1'b1) begin
				state_w=S_IDLE;
				dsp_stop_next=1'b1;
				play_en_next=1'b0;
				dsp_pause_next=1'b0;
			end
			else if(i_key_1==1'b1) begin
				dsp_start_next=1'b1;
				state_w=S_PLAY;
				play_en_next=1'b1;
				dsp_pause_next=1'b0;
			end
			else begin
				state_w=S_PLAY_PAUSE;
			end
		end
	endcase
end

always_ff @(posedge i_AUD_BCLK or negedge i_rst_n) begin
	if (~i_rst_n) begin
		state_r <= S_I2C;
		i2c_start<=1'b0;
		i2c_sent<=1'b0;
		//set rec signals
		rec_start<=1'b0;
		rec_stop<=1'b0;
		rec_pause<=1'b0;
		play_en<=1'b0;
		dsp_start<=1'b0;
		dsp_pause<=1'b0;
		dsp_stop<=1'b0;
		cntr2048 <= 0;
	end
	else begin
		i2c_sent<=i2c_sent_next;
		state_r <= state_w;
		i2c_start<=i2c_start_next;
		//set rec signals
		rec_start<=rec_start_next;
		rec_stop<=rec_stop_next;
		rec_pause<=rec_pause_next;
		play_en<=play_en_next;
		dsp_start<=dsp_start_next;
		dsp_pause<=dsp_pause_next;
		dsp_stop<=dsp_stop_next;
		cntr2048 <= cntr2048_nxt;

	end
end

endmodule