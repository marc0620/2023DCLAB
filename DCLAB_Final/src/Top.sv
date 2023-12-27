module Top (
	input i_rst_n,
	input i_clk,
	input i_key_1,
	input [6:0] i_shift,
	input [10:0] i_bit_test,
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
	output [17:0] o_ledr
);
	
	// design the FSM and states as you like
	parameter S_IDLE       = 0;
	parameter S_I2C        = 1;
	parameter S_PLAY       = 4;
	logic[2:0] state_r, state_w;

	logic i2c_oen;
	wire  i2c_sdat;
	logic [15:0] data_record, data_play;
	logic [15:0] dac_data;

	logic i2c_start, i2c_fin, i2c_state;
	logic player_enable;
	logic rec_start,rec_start_next, dsp_start, dsp_start_next;
    logic [2:0] kb_state;
    logic [32:0] key_array;
    logic signed [15:0] carrier_data;
	assign o_leds[0]=key_array[32];
	assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

	logic [15:0] pseudo_SRAM;
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if (~i_rst_n) begin
			pseudo_SRAM <= 16'd0;
		end
		else begin
			pseudo_SRAM <= data_record;
		end
	end


	assign play_en  = (state_w == S_PLAY);
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
	.i_data(i_AUD_ADCDAT),
	.o_data(data_record),
);
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_start(dsp_start),
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(pseudo_SRAM),
    .carrier_data(carrier_data),
	.i_shift(i_shift),
	.i_bit_test(i_bit_test),
	.o_dac_data(dac_data)
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


	//=== LED ===
	LEDVolume led0(
		.i_record(state_r == S_PLAY),
		.i_data(data_record),
		.o_led_r(o_ledr)
	);



always_comb begin
	// design your control here
	state_w=state_r;
	rec_start_next=rec_start;
	dsp_start_next=dsp_start;
	case (state_r)
		S_I2C: begin
			if (i2c_fin==1'b1) begin
				state_w=S_IDLE;
			end
			else begin
				state_w=S_I2C;
			end
			
		end
		S_IDLE: begin
			if(i_key_1==1'b1) begin
				state_w=S_PLAY;
				dsp_start_next=1'b1;
				rec_start_next=1'b1;
			end
			else begin
				state_w=S_IDLE;
			end
		end
		S_PLAY: begin
			dsp_start_next=1'b0;
			state_w=S_PLAY;
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (~i_rst_n) begin
		state_r <= S_I2C;
		i2c_start<=1'b1;
		//set rec signals
		rec_start<=1'b0;
		dsp_start<=1'b0;
	end
	else begin
		state_r <= state_w;
		i2c_start<=1'b1;
		//set rec signals
		rec_start<=rec_start_next;
		dsp_start<=dsp_start_next;

	end
end

endmodule
