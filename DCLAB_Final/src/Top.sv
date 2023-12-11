module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0,
	input i_key_1,
	input i_key_2,
	
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
	output [8:0]  o_ledg,
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
	inout  [35:0] GPIO,
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
	output [2:0] o_state,
	output [17:0] o_ledr,
	output [2:0] o_kb_state,
	output [2:0] o_kb_state_next
);
	
	// design the FSM and states as you like
	logic[2:0] state_r, state_w;
	logic signed [15:0] carrier_data;
	logic i2c_oen;
	wire  i2c_sdat;
	logic [15:0] data_play;
	localparam S_I2C = 0;
	localparam S_ACTIVE = 1;
	logic [31:0] key_array;
	logic i2c_fin;
	logic [2:0] kb_state,i2c_state,player_state;
	assign o_kb_state=kb_state;
	assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;
	assign o_state=state_r;
	assign GPIO[0] = i_clk_100k;
	assign GPIO[1] = PS2_CLK;
	assign GPIO[2] = PS2_DAT;
	assign GPIO[3] = i_AUD_BCLK;
	assign GPIO[4] = o_AUD_DACDAT;
	assign GPIO[5] = i_AUD_DACLRCK;
	assign GPIO[6] = carrier_data[0];

	assign o_ledg[0]=i2c_fin;
	//assign o_D_addr[19:0] = (state_r == S_RECD) ? addr_record : addr_play[19:0];
	//assign o_D_addr[25:20] = 0;
	//assign o_D_wdata = (state_r == S_RECD) ? data_record : 16'd0;
	//assign i_data_play = (state_r != S_RECD) ? i_D_rdata : 16'd0; 
	// assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play[19:0];
	// assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
	// assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

	//assign o_D_we_n = (state_r == S_RECD) ? 1'b0 : 1'b1;
	// assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
	// assign o_SRAM_CE_N = 1'b0;
	// assign o_SRAM_OE_N = 1'b0;
	// assign o_SRAM_LB_N = 1'b0;
	// assign o_SRAM_UB_N = 1'b0;
	// below is a simple example for module division
	// you can design these as you like

	// === I2cInitializer ===
	// sequentially sent out settings to initialize WM8731 with I2C protocal
	I2cInitializer init0(
		.i_rst_n(i_rst_n),
		.i_clk(i_clk_100k),
		.i_start(1'b1),
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


	// === AudPlayer ===
	AudPlayer aud0(
		.i_rst_n(i_rst_n),
		.i_clk(i_AUD_BCLK),
		.i_lrc(i_AUD_DACLRCK),
		.i_en(1'b1), // enable AudPlayer only when playing audio, work with AudDSP
		.i_dac_data(carrier_data), //dac_data
		.o_aud_dacdat(o_AUD_DACDAT),
		.o_state(o_kb_state_next)
	);
	assign o_ledr=key_array[17:0];

	always_comb begin
		state_w=state_r;
		if(i2c_fin) begin
			state_w=S_ACTIVE;
		end
	end

	// always_ff @ (posedge i_clk_100k or negedge i_rst_n) begin
	// 	if(~i_rst_n) begin
	// 		carrier_data<=0;
	// 	end
	// 	else begin
	// 		carrier_data<=carrier_data+128;
	// 	end
	// end

	always_ff @( posedge i_clk or negedge i_rst_n ) begin
		if (~i_rst_n) begin
			state_r <= S_I2C;
		end
		else begin
			state_r <= state_w;
		end
	end

endmodule
