module IIR(
    input  clk,
    input  i_rst_n,
    input  i_valid,
    input  signed [15:0] audio_in,
    input  signed [15:0] audio_out_one_delay,
    input  signed [15:0] audio_out_two_delay,
    input  signed [17:0] b1,
    input  signed [17:0] b2,
    input  signed [17:0] b3,
    input  signed [17:0] a2,
    input  signed [17:0] a3,
    output signed [15:0] audio_out,
    output               o_valid
);

    logic signed [15:0] audio_in_one_delay_w,audio_in_one_delay_r,audio_in_two_delay_w,audio_in_two_delay_r;
    logic signed [36:0] answer_w,answer_r;
    logic [3:0] count, count_next;
    logic signed [36:0] answer;


    assign o_valid = (count==3)? 1:0;

    always_comb begin
        if(i_valid==1) begin
            // $display("yes");
            audio_in_one_delay_w = audio_in;
            audio_in_two_delay_w = audio_in_one_delay_r;
            count_next = count + 1;
            answer_w = answer;
        end
        else begin
            // $display("no");
            audio_in_one_delay_w = audio_in_one_delay_r;
            audio_in_two_delay_w = audio_in_two_delay_r;
            count_next = count;
            answer_w = answer_r;
        end
    end

    always_ff @( posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            audio_in_one_delay_r <= 16'b0;
            audio_in_two_delay_r <= 16'b0;
            count <= 0;
            answer_r <= 36'b0;
        end
        else begin
            audio_in_one_delay_r <= audio_in_one_delay_w;
            audio_in_two_delay_r <= audio_in_two_delay_w;
            count <= count_next;
            answer_r <= answer_w;
        end
    end

    
    // The filter is a "Direct Form II Transposed"
    // 
    //    a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
    //                          - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
    // 
    //    If a(1) is not equal to 1, FILTER normalizes the filter
    //    coefficients by a(1). 
    //
    logic signed [36:0] x_n_b_1,x_n_1_b_2,x_n_2_b_3,y_n_a_2,y_n_1_a_3;
    assign x_n_b_1 = audio_in * b1;
    assign x_n_1_b_2 = audio_in_one_delay_r * b2;
    assign x_n_2_b_3 = audio_in_two_delay_r * b3;
    assign y_n_a_2 = audio_out_one_delay * a2;
    assign y_n_1_a_3 = audio_out_two_delay * a3;
    assign answer = audio_in * b1 + audio_in_one_delay_r * b2 + audio_in_two_delay_r * b3 + audio_out_one_delay * a2 + audio_out_two_delay * a3;

    // assign audio_out = {answer[35], answer[32:16]}; //same as to left shift 2^16; truncate answer_r[15:0]
    assign audio_out = {answer_r[36], answer_r[30:16]};
    
endmodule

module signed_mult (out, a, b);

	output 	signed  [17:0]	out;
	input 	signed	[17:0] 	a;
	input 	signed	[17:0] 	b;
	
	wire	signed	[17:0]	out;
	wire 	signed	[35:0]	mult_out;

	assign mult_out = a * b;
	//assign out = mult_out[33:17];
	assign out = {mult_out[35], mult_out[32:16]};
endmodule