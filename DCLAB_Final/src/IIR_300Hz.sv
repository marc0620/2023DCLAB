// `include "IIR.sv"

module IIR_300Hz(
    input clk,
    input i_rst_n,
    input lrclk_negedge,
    input lrclk_posedge,
    input i_valid,
    input signed [15:0]  audio_in,
    input  signed [17:0] b1,
    input  signed [17:0] b2,
    input  signed [17:0] b3,
    input  signed [17:0] a2,
    input  signed [17:0] a3,
    output signed [15:0] audio_out
);

    logic signed [15:0] first_filter_out;
    logic signed [15:0] second_filter_out;
    logic i_valid_d1_w,i_valid_d1_r,i_valid_d2_w,i_valid_d2_r;

    always_comb begin
        i_valid_d1_w = i_valid;
        i_valid_d2_w = i_valid_d1_r;
    end

    always_ff @(posedge lrclk_posedge or negedge i_rst_n) begin
        if(!i_rst_n) begin
            i_valid_d1_r <= 0;
            i_valid_d2_r <= 0;
        end
        else begin
            i_valid_d1_r <= i_valid_d1_w;
            i_valid_d2_r <= i_valid_d2_w;
        end
    end

    IIR filter_300Hz(
        .clk(clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(i_valid),
        .x_in(audio_in),
        .b1(b1),
        .b2(b2),
        .b3(b3),
        .a2(a2),
        .a3(a3),
        .audio_out(audio_out)
    );

//    IIR dc_filter(
//        .clk(clk),
//        .i_rst_n(i_rst_n),
//        .lrclk_negedge(lrclk_negedge),
//        .lrclk_posedge(lrclk_posedge),
//        .i_valid(i_valid_d2_r),
//        .x_in(first_filter_out<<<3),
//        .b1(18'sd65536),
//        .b2(-18'sd65536),
//        .b3(18'sd0),
//        .a2(18'sd64000),
//        .a3(18'sd0),
//        .audio_out(second_filter_out)
//    );
//assign audio_out = second_filter_out>>>3;

endmodule