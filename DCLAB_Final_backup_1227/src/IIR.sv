module IIR(
    input  clk,
    input  i_rst_n,
    input  lrclk_negedge,
    input  lrclk_posedge,
    input  i_valid,
    input  signed [15:0] x_in,
    input  signed [17:0] b1,
    input  signed [17:0] b2,
    input  signed [17:0] b3,
    input  signed [17:0] a2,
    input  signed [17:0] a3,
    output signed [15:0] audio_out
);

    // 1st cycle after true lrclk negedge: x_in, x_in_D1, x_in_D2, y_out_D1, y_out_D2 -> y_out

    

    // audio_in is 16-bit signed, and refresh when lrclk_negedge
    logic signed [15:0] x_in_D1,x_in_D2;
    logic signed [36:0] y_out, y_out_D1, y_out_D2, raw_answer;

    always_ff @(posedge clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            x_in_D1 <= 16'b0;
            x_in_D2 <= 16'b0;
            y_out_D1 <= 0;
            y_out_D2 <= 0;
            raw_answer <= 0;
        end
        else begin
            if(~i_valid) begin
                x_in_D1 <= 16'b0;
                x_in_D2 <= 16'b0;
                y_out_D1 <= 0;
                y_out_D2 <= 0;
                raw_answer <= 0;
            end
            else begin
                if(lrclk_posedge) begin
                    x_in_D1 <= x_in;
                    x_in_D2 <= x_in_D1;
                    y_out_D1 <= y_out;
                    y_out_D2 <= y_out_D1;
                    raw_answer <= answer;
                end
                else begin
                    x_in_D1 <= x_in_D1;
                    x_in_D2 <= x_in_D2;
                    y_out_D1 <= y_out_D1;
                    y_out_D2 <= y_out_D2;
                    raw_answer <= raw_answer;
                end
            end
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
    assign x_n_b_1 = x_in * b1; //34-bit signed
    assign x_n_1_b_2 = x_in_D1 * b2;
    assign x_n_2_b_3 = x_in_D2 * b3;
    assign y_n_a_2 = y_out_D1 * a2;
    assign y_n_1_a_3 = y_out_D2 * a3;





    //assign answer = x_n_b_1 + x_n_1_b_2 + x_n_2_b_3 - y_n_a_2 - y_n_1_a_3;
    logic signed [36:0] answer;
    assign answer = x_n_b_1 + x_n_1_b_2 + x_n_2_b_3 + y_n_a_2 + y_n_1_a_3;
    assign y_out = answer >>> 16;

    


    logic [36:0] shifted_before_out;
    assign shifted_before_out = raw_answer >>> 15;
    assign audio_out = {shifted_before_out[36], shifted_before_out[14:0]};

    
    
endmodule