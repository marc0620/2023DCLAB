`timescale 1ns/10ps
module tb();
    logic i_clk;
	logic i_rst_n;
	logic i_start;
    logic [255:0] N;
    logic [255:0] y;
    logic [255:0] m;
    logic finish_r;

    initial begin
        $dumpfile("modulo_product.fsdb");
        $dumpvars;
        i_clk = 1'b0;
        i_rst_n = 1'b1;
        i_start = 1'b0;
        y = 5;
        N = 7;

        #1  i_rst_n=1'b0;
        #5  i_rst_n=1'b1;
        #20 i_start = 1'b1;
        #10 i_start = 1'b0;
        #3000
        #5  $finish;
    end
    always begin
        #5 i_clk=~i_clk;
    end

    modulo_product m1(i_clk,i_rst_n,i_start,N,y,m,finish_r);
endmodule