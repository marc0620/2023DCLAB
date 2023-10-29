/* 
purpose: LDR0 flashes at freq. 1Hz, which means pll generatede the correct clock
usage:

modify "parameter T = freq. of input clock"

add these lines to DE2_115.sv
tb_pll_50MHz test0(
    .i_rst_n(KEY[3]),
	.i_gen_clock(CLK_12M),
    .o_tick(LEDG[0])
);

add this file to quartus project

*/

module tb_pll_50MHz(
    input   i_gen_clock,
    input   i_rst_n,
    output  o_tick
);

    parameter T = 12000000; //12MHz
    
    
    logic [25:0] count,count_next;
    assign o_tick = count > (T>>1);
// ========================== Counter =======================================
	always_comb begin
        if(count == T) begin
            count_next = 0;
        end
        else begin
            count_next = count + 1;
        end

	end

	always_ff @(posedge i_gen_clock or negedge i_rst_n)  begin
		if(!i_rst_n) begin
			count <= 26'b0;
		end
		else begin
			count <= count_next;
		end
	end

endmodule



