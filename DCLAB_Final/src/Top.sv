module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0,
	input i_key_1,
	input i_key_2,
	input [2:0] i_speed, // design how user can decide mode on your own
	input i_fast,
	input i_slow_0,
	input i_slow_1,
	input i_reverse,
	input [1:0] i_volume_r,
	input [1:0] i_volume_l,
	input [6:0] i_shift,
	// AudDSP and SRAM
	//output [25:0] o_D_addr,
	//output [15:0] o_D_wdata,
	//input [15:0] i_D_rdata,
	//output o_D_we_n,
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	output [8:0]  o_leds,
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
    inout  PS2_CLK,
	inout  PS2_DAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	// SEVENDECODER (optional display)
	output [5:0] o_display_time,
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
	output [2:0] o_state_RECD,
	output [2:0] o_state_DSP,
	output [2:0] o_state,
	output [17:0] o_ledr
);
	
	// design the FSM and states as you like
	parameter S_IDLE       = 0;
	parameter S_I2C        = 1;
	parameter S_RECD       = 2;
	parameter S_RECD_PAUSE = 3;
	parameter S_PLAY       = 4;
	parameter S_PLAY_PAUSE = 5;
	logic[2:0] state_r, state_w;

	logic i2c_oen;
	wire  i2c_sdat;
	logic [19:0] addr_record, addr_play, stop_addr;
	logic [15:0] data_record, data_play;
	logic [15:0] dac_data;

	logic i2c_start, i2c_fin, i2c_state;
	logic player_enable;
	logic rec_start,rec_start_next,rec_stop,rec_stop_next,rec_pause,rec_pause_next, dsp_start, dsp_start_next, dsp_pause, dsp_pause_next, dsp_stop, dsp_stop_next;
	logic play_fin, rec_fin;
    logic [2:0] kb_state;
    logic [31:0] key_array;
    logic signed [15:0] carrier_data;

	assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

	//assign o_D_addr[19:0] = (state_r == S_RECD) ? addr_record : addr_play[19:0];
	//assign o_D_addr[25:20] = 0;
	//assign o_D_wdata = (state_r == S_RECD) ? data_record : 16'd0;
	//assign i_data_play = (state_r != S_RECD) ? i_D_rdata : 16'd0; 
	assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play[19:0];
	assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
	assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

	//assign o_D_we_n = (state_r == S_RECD) ? 1'b0 : 1'b1;
	assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
	assign o_SRAM_CE_N = 1'b0;
	assign o_SRAM_OE_N = 1'b0;
	assign o_SRAM_LB_N = 1'b0;
	assign o_SRAM_UB_N = 1'b0;

	assign play_en  = (state_w == S_PLAY);
	assign o_leds[0]=1'b1;
	assign o_leds[1]=i_AUD_BCLK;
	assign o_leds[3:2] =i_volume_l;
	assign o_leds[5:4] =i_volume_r;
	assign o_state = state_r;
	// below is a simple example for module division
	// you can design these as you like

	// === I2cInitializer ===
	// sequentially sent out settings to initialize WM8731 with I2C protocal
	I2cInitializer init0(
		.i_rst_n(i_rst_n),
		.i_clk(i_clk_100k),
		.i_start(i2c_start),
		.o_finished(i2c_fin),
		.o_sclk(o_I2C_SCLK),
		.o_sdat(i2c_sdat),
		.o_oen(i2c_oen), // you are outputing (you are not outputing only when you are "ack"ing.)
		.o_state(i2c_state)
	);

    keyboard_decoder kd0(
		.i_clk_100k(i_clk_100k),   //
    	.PS2_CLK(PS2_CLK), // 10~16.7 kHz
    	.i_rst_n(i_rst_n),
    	.PS2_DAT(PS2_DAT),
		.o_key(key_array),
		.o_state(kb_state),
		.o_state_next()
	);

	Modulator_synth s0(
		.i_clk(i_AUD_BCLK),
		.i_rst_n(i_rst_n),
		.i_data(key_array),
		.o_audio(carrier_data)
	);

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
	.o_state(o_state_RECD),
	.o_fin(rec_fin)
);
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_start(dsp_start),
	.i_pause(dsp_pause),
	.i_stop(dsp_stop),
	.i_speed(i_speed),
	.i_fast(i_fast),
	.i_slow_0(i_slow_0), // constant interpolation
	.i_slow_1(i_slow_1), // linear interpolation
	.i_reverse(i_reverse),
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.i_stop_addr(addr_record),
    .carrier_data(carrier_data),
	.i_shift(i_shift),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play),
	.o_state(o_state_DSP),
	.o_fin(play_fin)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_DACLRCK),
	.i_en(play_en), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT),
	.o_state(o_state_PLAY)
);
	SevenSegmentDisplayTime seven0(
		.rst_n(i_rst_n),
		.clk(i_clk),
		.recorder_start(rec_start),
		.recorder_pause(rec_pause),
		.recorder_stop(rec_stop),
		.player_start(dsp_start),
		.player_pause(dsp_pause),
		.player_stop(dsp_stop),
		.i_speed(i_speed),
		.i_fast(i_fast),
		.i_slow(i_slow_0 || i_slow_1),
		.i_state(state_r == S_PLAY),
		.o_display(o_display_time)
	);

	//=== LED ===
	LEDVolume led0(
		.i_record(state_r == S_RECD),
		.i_data(data_record),
		.o_led_r(o_ledr)
	);



always_comb begin
	// design your control here
	state_w=state_r;
	rec_start_next=rec_start;
	rec_stop_next=rec_stop;
	rec_pause_next=rec_pause;
	dsp_start_next=dsp_start;
	dsp_pause_next=dsp_pause;
	dsp_stop_next=dsp_stop;
	case (state_r)
		S_I2C: begin
			// if(i2c_start==1'b0 && i2c_sent==1'b0) begin
			// 	i2c_start_next=1'b1;
			// 	i2c_sent_next=1'b1;
			// end
			// else if(i2c_start==1'b1) begin
			// 	i2c_start_next=1'b0;
			// end
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
				dsp_start_next=1'b1;
				rec_stop_next=1'b0;
				dsp_stop_next=1'b0;
			end
			else begin
				state_w=S_IDLE;
			end
		end
		S_RECD: begin
			if(i_key_2 ==1'b1 || rec_fin==1)begin  //(o_state_RECD==0 && wait_sub==7) 
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
			if(i_key_2==1'b1 || play_fin) begin
				state_w=S_IDLE;
				dsp_stop_next=1'b1;
				dsp_start_next=1'b0;
			end
			else if(i_key_1==1'b1) begin
				dsp_pause_next=1'b1;
				state_w=S_PLAY_PAUSE;
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
				dsp_pause_next=1'b0;
			end
			else if(i_key_1==1'b1) begin
				dsp_start_next=1'b1;
				state_w=S_PLAY;
				dsp_pause_next=1'b0;
			end
			else begin
				state_w=S_PLAY_PAUSE;
			end
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (~i_rst_n) begin
		state_r <= S_I2C;
		i2c_start<=1'b1;
		//set rec signals
		rec_start<=1'b0;
		rec_stop<=1'b0;
		rec_pause<=1'b0;
		dsp_start<=1'b0;
		dsp_pause<=1'b0;
		dsp_stop<=1'b0;
	end
	else begin
		state_r <= state_w;
		i2c_start<=1'b1;
		//set rec signals
		rec_start<=rec_start_next;
		rec_stop<=rec_stop_next;
		rec_pause<=rec_pause_next;
		dsp_start<=dsp_start_next;
		dsp_pause<=dsp_pause_next;
		dsp_stop<=dsp_stop_next;

	end
end

endmodule
