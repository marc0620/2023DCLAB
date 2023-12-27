module Modulator_synth(
    input i_clk,
    input [31:0] i_data,
    input i_rst_n,
    output [15:0] o_audio
);
localparam bit [10:0] STEPS [0:31] ='{
    46,48,51,54,58,61,65,69,73,77,81,86,91,97,103,109,115,122,129,137,145,154,163,173,183,194,205,217,230,244,259,274
};
localparam CHANNEL=4;
logic signed[15:0]  sum;
logic signed[15:0] channel[0:CHANNEL-1];
logic signed [22:0]  generators [31:0]; //16+7 (128/2) bits
// assign sum = generators[0]>>>8+generators[1]>>>8+generators[2]>>>8+generators[3]>>>8+generators[4]>>>8+generators[5]>>>8+generators[6]>>>8+generators[7]>>>8+generators[8]>>>8+generators[9]>>>8+generators[10]>>>8+generators[11]>>>8+generators[12]>>>8+generators[13]>>>8+generators[14]>>>8+generators[15]>>>8+generators[16]>>>8+generators[17]>>>8+generators[18]>>>8+generators[19]>>>8+generators[20]>>>8+generators[21]>>>8+generators[22]>>>8+generators[23]>>>8+generators[24]>>>8+generators[25]>>>8+generators[26]>>>8+generators[27]>>>8+generators[28]>>>8+generators[29]>>>8+generators[30]>>>8+generators[31]>>>8;

assign o_audio = sum;
integer i,j;

always_comb begin
    j=0;
    for(int i=0;i< 32;i++) begin
        if(i_data[i]==1&&j<CHANNEL) begin
            channel[j]=generators[i]>>>9;
            j=j+1;
        end
    end
end
assign sum=channel[0]+channel[1]+channel[2]+channel[3];
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        for (int i = 0; i < 32; i++) begin
            generators[i] <= 0;
        end
    end else begin
        for (int i = 0; i < 32; i++) begin
            if (i_data[i] == 1) begin
                generators[i]<=generators[i]+$signed(STEPS[i]);
            end else begin
                generators[i]<=0;
            end
        end
    end
end


endmodule