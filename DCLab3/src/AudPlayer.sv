module AudPlayer(
	input i_rst_n,
	input i_bclk,
	input i_daclrck, //inout?
	input i_en, // enable AudPlayer only when playing audio, work with AudDSP
	input signed [15:0] i_dac_data, //dac_data
	output o_aud_dacdat,
    output o_state
);
    localparam  player_IDLE =  2'd0;
    localparam  player_left =  2'd1;
    localparam  player_right = 2'd2;
    localparam  player_wait = 2'd3;
    logic [1:0] state,state_next;
    logic [5:0] count,count_next;

    logic o_data,o_data_next;

    assign o_aud_dacdat = o_data;
    assign o_state = state;
    //fsm
    always_comb begin
        state_next = state;
        o_data_next = o_data;
        case(state)
            player_wait: begin
                if(i_en && i_daclrck) begin
                    state_next = player_IDLE;
                end
            end

            player_IDLE: begin
                if(!i_en) begin
                    state_next = player_wait;
                end
                else if(i_en && !i_daclrck) begin
                    state_next = player_left;
                    o_data_next = i_dac_data[15];
                end
                
            end

            player_left: begin
                o_data_next = i_dac_data[15-count];
                if(!i_en) begin
                    state_next = player_wait;
                end
                else if(count==15 && i_daclrck)
                    state_next = player_right;
                else
                    state_next = player_left;
            end

            player_right: begin
                o_data_next = i_dac_data[15-count];
                if(!i_en) begin
                    state_next = player_wait;
                end
                else if(count==15 && !i_daclrck)
                    state_next = player_IDLE;
                else
                    state_next = player_right; 
            end
        endcase
    end

    //counter
    always_comb begin
        count_next = count;
        case(state)
            player_wait: begin
                count_next = count;
            end
            
            player_IDLE: begin
                if(i_en && !i_daclrck)
                    count_next = 1;
                else
                    count_next = 0;
            end

            player_left: begin
                if(count<15)
                    count_next = count + 1;
                else if(count==15) begin
                    if (i_daclrck)
                        count_next = 0;
                    else
                        count_next = 15;
                end
                    
            end

            player_right: begin
                if(count<15)
                    count_next = count + 1;
                 else if(count==15) begin
                    if (!i_daclrck)
                        count_next = 0;
                    else
                        count_next = 15;
                end
            end
        endcase
    end

    always_ff @(posedge i_bclk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            count <= 0;
            o_data <= 0;
            state <= player_wait;
        end
        else begin
            count <= count_next;
            o_data <= o_data_next;
            state <= state_next;
        end
    end 

endmodule