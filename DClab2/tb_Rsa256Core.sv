`timescale 1ns/10ps
module tb();
    logic i_clk;
	logic i_rst;
	logic i_start;
    logic [255:0] i_a;
    logic [255:0] i_d;
    logic [255:0] i_n;
    logic [255:0] o_a_pow_d;
    logic o_finished;

    initial begin
        $dumpfile("Rsa256Core.fsdb");
        $dumpvars;
        i_clk = 1'b0;
        i_rst = 1'b1;
        i_start = 1'b0;
        i_a = 5;
        i_n = 221;
        i_d = 20;

        #1  i_rst=1'b0;
        #5  i_rst=1'b1;
        #20 i_start = 1'b1;
        #10 i_start = 1'b0;
        #700000
        $display("");
        if(o_finished ==1) begin
            $display("answer is %d ", o_a_pow_d);
        end
        $display("");
        #5  $finish;
    end
    always begin
        #5 i_clk=~i_clk;
    end

    Rsa256Core r1(i_clk,i_rst,i_start,i_a,i_d,i_n,o_a_pow_d,o_finished);
endmodule