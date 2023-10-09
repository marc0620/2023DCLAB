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
        i_rst = 1'b0;
        i_start = 1'b0;
        // i_a = 5;
        // i_n = 221;
        // i_d = 20; 

        i_n = 256'hca35_86e7_ea48_5f3b_0a22_2a4c_79f7_dd12_e853_88ec_cdee_4035_940d_774c_029c_f831;
        i_d = 256'hb6ac_e0b1_4720_1698_39b1_5fd1_3326_cf1a_1829_beaf_c37b_b937_bec8_802f_bcf4_6bd9;
        i_a = 256'hc6b6_62ec_b173_c53c_c7bb_4212_057f_9c0b_a283_e000_b98c_9dcf_5fea_ee7d_6c93_3dfb;

        #1  i_rst=1'b1;
        #5  i_rst=1'b0;
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