`timescale 1us/1us

module IIR_test;

parameter	cycle = 100.0;

// ==============generate all input signals===============
logic 		i_clk;
logic 		i_daclrck;
logic 		i_rst_n;	
logic 		i_valid;


logic lrclk_negedge, lrclk_posedge;
logic prev_daclrck;
always_ff @(posedge i_clk or negedge i_rst_n  ) begin 
	prev_daclrck <= i_daclrck;
end
assign lrclk_posedge = (~prev_daclrck) && i_daclrck;
assign lrclk_negedge = prev_daclrck && (~i_daclrck);


initial i_clk = 0;
always #(cycle/2.0) i_clk = ~i_clk;

initial i_daclrck = 0;
always #(40*cycle/2.0) i_daclrck = ~i_daclrck;



logic signed [15:0] x_array [0:3199];
integer i = 0;
integer file, filtered;
logic signed [15:0] x_in;
logic signed [15:0] audio_out;

initial begin
		$fsdbDumpfile("IIR_test.fsdb");
		$fsdbDumpvars(0, IIR_test, "+all");

		file     = $fopen("./input_golden_original.txt", "rb");
		filtered = $fopen("./output_golden_final_6.txt","wb");
		
		while (!$feof(file)) begin
			@(negedge i_daclrck);
            $fscanf(file, "%d\n", x_in);
            x_array[i] = x_in;
			@(posedge i_daclrck);
			$fwrite(filtered, "%d\n" , audio_out);
			i = i + 1;

        end

		$fclose(file);
		$finish;
end



	
IIR DUT(
    .clk(i_clk),
    .i_rst_n(i_rst_n),
    .lrclk_negedge(lrclk_negedge),
    .lrclk_posedge(lrclk_posedge),
	.i_valid(i_valid),
    .x_in(x_in<<<3),
    .b1(18'sd67),
    .b2(18'sd0),
    .b3(-18'sd67),
    .a2(18'sd130709),
    .a3(-18'sd65400),
    .audio_out(audio_out)
);




initial begin	
	i_clk 	= 0;
	i_rst_n = 1;
	i_valid = 0;
	

	@(negedge i_clk);
	@(negedge i_clk);
	@(negedge i_clk) i_rst_n = 0;
	@(negedge i_clk) i_rst_n = 1; 


	@(negedge i_daclrck) i_valid = 1;
end

initial #(cycle*1000000) $finish;

endmodule
