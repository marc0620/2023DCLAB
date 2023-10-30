`timescale 1ns/10ps
module tb();
	logic i_rst_n;
	logic i_bclk;
	logic i_daclrck,i_daclrck_n; //inout?
	logic i_en; // enable AudPlayer only when playing audio, work with AudDSP
	logic i_dac_data; //dac_data
    logic i_start, i_pause, i_stop;
    logic [15:0] dac_data;
	logic [15:0] o_aud_dacdat;
    logic [19:0] o_address;
    logic [5:0] counter,counter_next;
    initial begin
        $dumpfile("AudRecorder.fsdb");
        $dumpvars;
        i_bclk = 1'b0;
        i_rst_n = 1'b1;
        i_en = 1'b0;
        dac_data = 16'b1001001001001001;
        i_start=1'b0;
        i_pause=1'b0;
        i_stop=1'b1;
        counter=0;
        i_dac_data=0;
        i_daclrck=0;
        #1  i_rst_n=1'b0;
        #5  i_rst_n=1'b1;
        #20 i_stop=1'b0;
        #0 i_start=1'b1;
        #20 i_start=1'b0;
        #1000  $finish;
    end
    always begin
        #5 i_bclk=~i_bclk;
    end


    assign i_daclrck_n=~i_daclrck;
    assign counter_next=counter+1;
    
    always @ (negedge i_bclk) begin
        $display("%d", counter);
        if(counter==20) begin
            $display("aaa");
            counter=0;
            i_daclrck<=i_daclrck_n;
        end
        else if(counter<17 && counter >0) begin
            i_dac_data <= dac_data[counter-1];
        end
        else begin
        end
        counter<=counter_next;
    end
    AudRecorder recorder0(
        .i_rst_n(i_rst_n), 
        .i_clk(i_bclk),
        .i_lrc(i_daclrck),
        .i_start(i_start),
        .i_pause(i_pause),
        .i_stop(i_stop),
        .i_data(i_dac_data),
        .o_address(o_address),
        .o_data(o_aud_dacdat)
    );

endmodule