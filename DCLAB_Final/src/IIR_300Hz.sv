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

    logic i_valid_stable;
    always_ff@(posedge lrclk_posedge or negedge i_rst_n) begin
        if(~i_rst_n) begin
            i_valid_stable<=1'b0;
        end
        else begin
            i_valid_stable<=i_valid;
        end
    end

    IIR filter_300Hz(
        .clk(clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(i_valid_stable),
        .x_in(audio_in),
        .b1(b1),
        .b2(b2),
        .b3(b3),
        .a2(a2),
        .a3(a3),
        .audio_out(audio_out)
    );
endmodule