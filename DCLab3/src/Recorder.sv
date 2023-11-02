module AudRecorder(
	input i_rst_n, 
	input i_clk,
	input i_lrc,
	input i_start,
	input i_pause,
	input i_stop,
	input i_data,
	output reg[19:0] o_address,
	output reg[15:0] o_data,
    output [2:0] o_state

);
parameter STOPPED = 0;
parameter PAUSE= 1;
parameter RECORDING = 2;
parameter WAITING =3;
logic [19:0] addr_next;
logic [15:0] o_data_next,data_w,data_r;
logic [4:0] counter,counter_next;
logic [1:0] state,state_next;
logic first,first_next;
logic lrc_p;

assign o_state=state;

always_comb begin
    o_data_next=o_data;
    addr_next=o_address;
    state_next=state;
    counter_next=counter;
    first_next=first;
    data_w=data_r;
    case(state)
        STOPPED: begin
            data_w=15'b0;
            first_next=1'b1;
            if(i_start) begin
                addr_next = 20'b0;
                o_data_next = 16'b0;
                state_next = WAITING;
            end
            else begin
                addr_next = o_address;
                state_next=STOPPED;
            end
        end
        PAUSE: begin
            data_w=15'b0;
            if(i_start) begin
                state_next = WAITING;
            end
            else if(i_stop) begin
                state_next = STOPPED;
            end
            else begin
                state_next=PAUSE;
            end
        end
        WAITING: begin
            data_w=15'b0;
            if(i_stop ||o_address==20'b1) begin
                state_next = STOPPED;
            end
            else if(i_pause) begin
                state_next = PAUSE;
            end
            else begin
                if(lrc_p==1'b1 && i_lrc==1'b0) begin
                    if(first && o_address==20'b0)begin
                        first_next=1'b0;
                    end
                    else begin
                        addr_next=o_address+1;
                    end
                    counter_next = 5'b0;
                    state_next=RECORDING;
                end
                else begin
                    state_next=WAITING;
                end
            end
        end
        RECORDING: begin
            if(i_stop) begin
                state_next = STOPPED;
            end
            else if(i_pause) begin
                state_next = PAUSE;
            end
            else begin
                if(counter < 16) begin
                    addr_next = o_address;
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
        end
    endcase
end


always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		o_address <=0;
        o_data <=0;
        lrc_p <= 0;
        state <= STOPPED;
        counter<=1'b0;
        first<=1'b1;
        data_r<=0;
	end
	else begin
        data_r<=data_w;
		o_address <= addr_next;
        o_data <= o_data_next;
        lrc_p <= i_lrc;
        state <= state_next;
        counter<= counter_next;
        first<=first_next;
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