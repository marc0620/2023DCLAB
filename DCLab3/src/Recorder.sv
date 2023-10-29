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
);
parameter STOPPED = 0;
parameter PAUSE= 1;
parameter RECORDING = 2;
parameter WAITING =3;
logic [19:0] addr_next;
logic [15:0] o_data_next,data_w;
logic [4:0] counter,counter_next;
logic [1:0] state,state_next;
logic lrc_p;



always_comb begin
    state_next = state;
    o_data_next=o_data;
    addr_next=o_address;
    case(state)
        STOPPED: begin
            if(i_start) begin
                addr_next = 0;
                o_data_next = 0;
                state_next = WAITING;
            end
            else begin
                addr_next = o_address;
            end
        end
        PAUSE: begin
            if(i_start) begin
                state_next = WAITING;
            end
            else if(i_stop) begin
                state_next = STOPPED;
            end
            else begin
                addr_next = o_address;
            end
        end
        WAITING: begin
            data_w=15'b0;
            if(i_stop) begin
                state_next = STOPPED;
            end
            else if(i_pause) begin
                state_next = PAUSE;
            end
            else begin
                if(lrc_p==1'b1 && i_lrc==1'b0) begin
                    state_next = RECORDING;
                    counter_next = 0;
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
                end
                else begin
                    o_data_next = data_w;
                    addr_next = o_address + 1;
                    counter_next=5'b0;
                    if(addr_next = 20'b0) begin
                        state_next = STOPPED;
                    end
                    else begin
                        state_next = WAITING;
                    end
                end
            end
        end
    endcase
end


always_ff @(posedge i_clk or posedge i_rst_n) begin
	if (!i_rst_n) begin
		o_address <=0;
        o_data <=0;
        lrc_p <= 0;
        state <= STOPPED;
	end
	else begin
		o_address <= addr_next;
        o_data <= o_data_next;
        lrc_p <= i_lrc;
        state <= state_next;
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