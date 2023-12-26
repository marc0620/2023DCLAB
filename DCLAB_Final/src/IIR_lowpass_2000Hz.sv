// `include "IIR_lowpass.sv"

module IIR_lowpass_2000Hz(
    input clk,
    input i_rst_n,
    input i_valid,
    input signed [15:0]  audio_in,
    input  signed [17:0] b1,
    input  signed [17:0] b2,
    input  signed [17:0] b3,
    input  signed [17:0] a2,
    input  signed [17:0] a3,
	 input [6:0] i_shift, 
    output signed [15:0] audio_out
);

    logic signed [15:0] audio_out_one_delay_w,audio_out_one_delay_r;
    logic signed [15:0] audio_out_two_delay_w,audio_out_two_delay_r;

    logic o_valid;

    always_comb begin
        if(i_valid) begin
            audio_out_one_delay_w = audio_out;
            audio_out_two_delay_w = audio_out_one_delay_r;
        end
        else begin
            audio_out_one_delay_w = audio_out_one_delay_r;
            audio_out_two_delay_w = audio_out_two_delay_r;
        end

    end

    always_ff @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            audio_out_one_delay_r <= 16'b0;
            audio_out_two_delay_r <= 16'b0;
        end
        else begin
            audio_out_one_delay_r <= audio_out_one_delay_w;
            audio_out_two_delay_r <= audio_out_two_delay_w;
        end
    end

    IIR_lowpass lowpass_2000Hz(
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_valid(i_valid),
        .audio_in(audio_in),
        // .audio_out_one_delay(audio_out_one_delay_r),
        // .audio_out_two_delay(audio_out_two_delay_r),
        .audio_out_one_delay(audio_out),
        .audio_out_two_delay(audio_out_one_delay_r),
        .b1(b1),
        .b2(b2),
        .b3(b3),
        .a2(a2),
        .a3(a3),
		  .i_shift(i_shift),
        .audio_out(audio_out),
        .o_valid(o_valid)
    );
endmodule