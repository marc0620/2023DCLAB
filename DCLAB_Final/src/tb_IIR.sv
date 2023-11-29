`timescale 1ns/10ps
module tb();
    logic  clk;
    logic  i_rst_n;
    logic  i_valid;
    logic  signed [15:0] audio_in;
    logic  signed [15:0] audio_out_one_delay;
    logic  signed [15:0] audio_out_two_delay;
    logic  signed [17:0] b1;
    logic  signed [17:0] b2;
    logic  signed [17:0] b3;
    logic  signed [17:0] a2;
    logic  signed [17:0] a3;
    logic  signed [15:0] audio_out;
    logic                o_valid;

    initial begin
        $dumpfile("IIR.fsdb");
        $dumpvars;
        clk = 1'b0;
        i_rst_n = 1'b1;
        i_valid = 1'b0;

        b1 = 18'b1;
        b2 = 18'b1;
        b3 = 18'b1;
        a2 = 18'b1;
        a3 = 18'b1;

        audio_in = {1'b1,{15{1'b0}}};
        // audio_out_one_delay = {1'b1,{15{1'b0}}};
        // audio_out_two_delay = {1'b1,{15{1'b0}}};
        audio_out_one_delay = 16'd5;
        audio_out_two_delay = 16'd10;

        #1 i_rst_n = 1'b0;
        #5 i_rst_n = 1'b1;
        #20 i_valid = 1'b1;
        #11 audio_in = 16'd10;
        #10 audio_in = 16'd20;

        #1000 $finish;
    end
    always begin
        #5 clk = ~clk;
    end

    IIR i1(
        clk,
        i_rst_n,
        i_valid,
        audio_in,
        audio_out_one_delay,
        audio_out_two_delay,
        b1,
        b2,
        b3,
        a2,
        a3,
        audio_out,
        o_valid
    );
endmodule