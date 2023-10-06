`timescale 1ns/10ps
module tb();
    logic i_clk;
	logic i_rst_n;
	logic i_start;
    logic [255:0] N;
    logic [255:0] a;
    logic [255:0] b;
    logic [255:0] m;
    logic finish_r;

    initial begin
        $dumpfile("doubi_product.fsdb");
        $dumpvars;
        i_clk = 1'b0;
        i_rst_n = 1'b1;
        i_start = 1'b0;
        a = 279;
        b = 398;
        N = 221;

        #1  i_rst_n=1'b0;
        #5  i_rst_n=1'b1;
        #20 i_start = 1'b1;
        #10 i_start = 1'b0;
        a=3;
        b=11;
        N=13;
        #2800 i_start = 1'b1;
        #10 i_start = 1'b0; 
        #1000  $finish;
    end
    always begin
        #5 i_clk=~i_clk;
    end

    doubi_product m1(
        .clk(i_clk),
        .rst_n(i_rst_n),
        .start(i_start),
        .N(N),
        .a(a),
        .b(b),
        .m(m),
        .finish(finish_r)
    );
endmodule