module AudRecorder(
	input i_rst_n, 
	input i_clk,
	input i_lrc,
	input i_data,
	output reg[15:0] o_data

);
parameter RECORDING = 2;
parameter WAITING =3;
logic [15:0] o_data_next,data_w,data_r;
logic [4:0] counter,counter_next;
logic [1:0] state,state_next;
logic lrc_p;

assign o_state=state;

always_comb begin
    o_data_next=o_data;
    state_next=state;
    counter_next=counter;
    data_w=data_r;
    case(state)
        WAITING: begin
            data_w=15'b0;
            if(lrc_p==1'b1 && i_lrc==1'b0) begin
                counter_next = 5'b0;
                state_next=RECORDING;
            end
            else begin
                state_next=WAITING;
            end
        end
        RECORDING: begin
            if(counter < 16) begin
                counter_next=counter+1;
                data_w[15-counter] = i_data;
                state_next=RECORDING;
            end
            else begin
                o_data_next = data_w;
                counter_next=5'b0;
                state_next=WAITING;
            end
        end
    endcase
end


always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
        o_data <=0;
        lrc_p <= 0;
        state <= WAITING;
        counter<=1'b0;
        data_r<=0;
	end
	else begin
        data_r<=data_w;
        o_data <= o_data_next;
        lrc_p <= i_lrc;
        state <= state_next;
        counter<= counter_next;
	end
end
endmodule

/*	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(),
	.i_pause(),
	.i_stop(),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_wecord), */