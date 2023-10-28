`timescale 1ns/10ps
module tb();
	logic i_rst_n;
	logic i_bclk;
	logic i_daclrck; //inout?
	logic i_en; // enable AudPlayer only when playing audio, work with AudDSP
	logic signed [15:0] i_dac_data; //dac_data
	logic o_aud_dacdat;

    initial begin
        $dumpfile("AudPlayer.fsdb");
        $dumpvars;
        i_bclk = 1'b0;
        i_rst_n = 1'b1;
        i_en = 1'b0;
        i_daclrck = 1'b1;
        i_dac_data = 16'b1010101010101010;

        #1  i_rst_n=1'b0;
        #5  i_rst_n=1'b1;
        #20 i_en = 1'b1;
        #14 i_daclrck = 1'b0;
        #200 i_daclrck = 1'b1;
        #200 i_daclrck = 1'b0;
        #2   i_en = 1'b0;
        #300  $finish;
    end
    always begin
        #5 i_bclk=~i_bclk;
    end
    AudPlayer Aud1(i_rst_n,i_bclk,i_daclrck,i_en,i_dac_data,o_aud_dacdat);
endmodule