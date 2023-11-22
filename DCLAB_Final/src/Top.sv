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
	logic[2:0] state_r, state_w;

	logic i2c_oen;
	wire  i2c_sdat;
	logic [15:0] data_record, data_play;
	logic [15:0] dac_data;

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

endmodule
