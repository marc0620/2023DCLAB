`timescale 1ns/10ps
parameter N = 161 - 1;
module tb();
    logic clk;
    logic i_rst_n;
    logic i_valid;
    logic signed [15:0] audio_in;
    logic signed [17:0] b1;
    logic signed [17:0] b2;
    logic signed [17:0] b3;
    logic signed [17:0] a2;
    logic signed [17:0] a3;
    logic signed [15:0] audio_out;

    logic [3:0] time_counter;

    initial begin
        $dumpfile("300Hz_IIR.fsdb");
        $dumpvars;

        clk = 1'b0;
        i_rst_n = 1'b1;
        i_valid = 1'b0;

        time_counter = 4'd0;

        b1 = 18'sd45;
        b2 = 18'sd0;
        b3 = -18'sd45;

        a2 = 18'sd130880;
        a3 = -18'sd65445;

        #1 i_rst_n = 1'b0;
        #5 i_rst_n = 1'b1;
        #20 i_valid = 1'b1;

            audio_in = 16'sd0;
        #10 audio_in = 16'sd0;
        #10 audio_in = 16'sd3839;
        #10 audio_in = 16'sd7555;
        #10 audio_in = 16'sd11028;
        #10 audio_in = 16'sd14148;
        #10 audio_in = 16'sd16819;
        #10 audio_in = 16'sd18962;
        #10 audio_in = 16'sd20516;
        #10 audio_in = 16'sd21447;
        #10 audio_in = 16'sd21740;
        #10 audio_in = 16'sd21407;
        #10 audio_in = 16'sd20482;
        #10 audio_in = 16'sd19023;
        #10 audio_in = 16'sd17108;
        #10 audio_in = 16'sd14831;
        #10 audio_in = 16'sd12298;
        #10 audio_in = 16'sd9630;
        #10 audio_in = 16'sd6947;
        #10 audio_in = 16'sd4371;
        #10 audio_in = 16'sd2019;
        #10 audio_in = 16'sd0;
        #10 audio_in = -16'sd1592;
        #10 audio_in = -16'sd2679;
        #10 audio_in = -16'sd3202;
        #10 audio_in = -16'sd3129;
        #10 audio_in = -16'sd2446;
        #10 audio_in = -16'sd1167;
        #10 audio_in = 16'sd672;
        #10 audio_in = 16'sd3013;
        #10 audio_in = 16'sd5777;
        #10 audio_in = 16'sd8867;
        #10 audio_in = 16'sd12175;
        #10 audio_in = 16'sd15582;
        #10 audio_in = 16'sd18965;
        #10 audio_in = 16'sd22201;
        #10 audio_in = 16'sd25171;
        #10 audio_in = 16'sd27767;
        #10 audio_in = 16'sd29893;
        #10 audio_in = 16'sd31470;
        #10 audio_in = 16'sd32440;
        #10 audio_in = 16'sd32768;
        #10 audio_in = 16'sd32440;
        #10 audio_in = 16'sd31470;
        #10 audio_in = 16'sd29893;
        #10 audio_in = 16'sd27767;
        #10 audio_in = 16'sd25171;
        #10 audio_in = 16'sd22201;
        #10 audio_in = 16'sd18965;
        #10 audio_in = 16'sd15582;
        #10 audio_in = 16'sd12175;
        #10 audio_in = 16'sd8867;
        #10 audio_in = 16'sd5777;
        #10 audio_in = 16'sd3013;
        #10 audio_in = 16'sd672;
        #10 audio_in = -16'sd1167;
        #10 audio_in = -16'sd2446;
        #10 audio_in = -16'sd3129;
        #10 audio_in = -16'sd3202;
        #10 audio_in = -16'sd2679;
        #10 audio_in = -16'sd1592;
        #10 audio_in = 16'sd0;
        #10 audio_in = 16'sd2019;
        #10 audio_in = 16'sd4371;
        #10 audio_in = 16'sd6947;
        #10 audio_in = 16'sd9630;
        #10 audio_in = 16'sd12298;
        #10 audio_in = 16'sd14831;
        #10 audio_in = 16'sd17108;
        #10 audio_in = 16'sd19023;
        #10 audio_in = 16'sd20482;
        #10 audio_in = 16'sd21407;
        #10 audio_in = 16'sd21740;
        #10 audio_in = 16'sd21447;
        #10 audio_in = 16'sd20516;
        #10 audio_in = 16'sd18962;
        #10 audio_in = 16'sd16819;
        #10 audio_in = 16'sd14148;
        #10 audio_in = 16'sd11028;
        #10 audio_in = 16'sd7555;
        #10 audio_in = 16'sd3839;
        #10 audio_in = 16'sd0;
        #10 audio_in = -16'sd3839;
        #10 audio_in = -16'sd7555;
        #10 audio_in = -16'sd11028;
        #10 audio_in = -16'sd14148;
        #10 audio_in = -16'sd16819;
        #10 audio_in = -16'sd18962;
        #10 audio_in = -16'sd20516;
        #10 audio_in = -16'sd21447;
        #10 audio_in = -16'sd21740;
        #10 audio_in = -16'sd21407;
        #10 audio_in = -16'sd20482;
        #10 audio_in = -16'sd19023;
        #10 audio_in = -16'sd17108;
        #10 audio_in = -16'sd14831;
        #10 audio_in = -16'sd12298;
        #10 audio_in = -16'sd9630;
        #10 audio_in = -16'sd6947;
        #10 audio_in = -16'sd4371;
        #10 audio_in = -16'sd2019;
        #10 audio_in = 16'sd0;
        #10 audio_in = 16'sd1592;
        #10 audio_in = 16'sd2679;
        #10 audio_in = 16'sd3202;
        #10 audio_in = 16'sd3129;
        #10 audio_in = 16'sd2446;
        #10 audio_in = 16'sd1167;
        #10 audio_in = -16'sd672;
        #10 audio_in = -16'sd3013;
        #10 audio_in = -16'sd5777;
        #10 audio_in = -16'sd8867;
        #10 audio_in = -16'sd12175;
        #10 audio_in = -16'sd15582;
        #10 audio_in = -16'sd18965;
        #10 audio_in = -16'sd22201;
        #10 audio_in = -16'sd25171;
        #10 audio_in = -16'sd27767;
        #10 audio_in = -16'sd29893;
        #10 audio_in = -16'sd31470;
        #10 audio_in = -16'sd32440;
        #10 audio_in = -16'sd32768;
        #10 audio_in = -16'sd32440;
        #10 audio_in = -16'sd31470;
        #10 audio_in = -16'sd29893;
        #10 audio_in = -16'sd27767;
        #10 audio_in = -16'sd25171;
        #10 audio_in = -16'sd22201;
        #10 audio_in = -16'sd18965;
        #10 audio_in = -16'sd15582;
        #10 audio_in = -16'sd12175;
        #10 audio_in = -16'sd8867;
        #10 audio_in = -16'sd5777;
        #10 audio_in = -16'sd3013;
        #10 audio_in = -16'sd672;
        #10 audio_in = 16'sd1167;
        #10 audio_in = 16'sd2446;
        #10 audio_in = 16'sd3129;
        #10 audio_in = 16'sd3202;
        #10 audio_in = 16'sd2679;
        #10 audio_in = 16'sd1592;
        #10 audio_in = 16'sd0;
        #10 audio_in = -16'sd2019;
        #10 audio_in = -16'sd4371;
        #10 audio_in = -16'sd6947;
        #10 audio_in = -16'sd9630;
        #10 audio_in = -16'sd12298;
        #10 audio_in = -16'sd14831;
        #10 audio_in = -16'sd17108;
        #10 audio_in = -16'sd19023;
        #10 audio_in = -16'sd20482;
        #10 audio_in = -16'sd21407;
        #10 audio_in = -16'sd21740;
        #10 audio_in = -16'sd21447;
        #10 audio_in = -16'sd20516;
        #10 audio_in = -16'sd18962;
        #10 audio_in = -16'sd16819;
        #10 audio_in = -16'sd14148;
        #10 audio_in = -16'sd11028;
        #10 audio_in = -16'sd7555;
        #10 audio_in = -16'sd3839;


        #1000 $finish;


    end

    always begin
        #5 clk = ~clk;

        // Display audio_out every ten time units
        time_counter = time_counter + 1;
        if (time_counter == 2) begin
            $display("Time = %0t, audio_out = %d", $time, audio_out);
            time_counter = 0;  // Reset the counter
        end
    end

    //Input
    logic signed [15:0] audio_MEM [0:N];

    // initial begin
    //     @posedge(i_rst_n);
    //     #2;
    //     $readmem    
    // end

    IIR_300Hz filter(
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_valid(i_valid),
        .audio_in(audio_in),
        .b1(b1),
        .b2(b2),
        .b3(b3),
        .a2(a2),
        .a3(a3),
        .audio_out(audio_out)
    );
    
endmodule