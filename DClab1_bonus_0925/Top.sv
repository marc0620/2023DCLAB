module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_left,
	input        i_right,
	input        i_start,
	output [3:0] o_random_out,
	output [3:0] o_index_out,
	output [17:0] o_led,
	output [8:0] o_led_idx
);

	logic [25:0] count,count_next;
	logic [1:0] state,state_next;
	logic [3:0] number,number_next,new_num;
	logic [3:0] mem_reg [0:7];
	logic [3:0] mem_reg_next [0:7];
	logic [2:0] idx, idx_next;
	logic [25:0] timer, timer_next;
	logic key2_state, key2_state_next;
	logic [3:0] result;
// please check out the working example in lab1 README (or Top_exmaple.sv) first
	parameter T = 12500000/2;
	parameter S_IDLE = 2'b00;
	parameter S_change_one  = 2'b01;
	parameter S_change_two  = 2'b10;
	parameter S_change_four = 2'b11;

	parameter T_key2 = 50000000/4;
	parameter S_key2_IDLE = 1'b0;
	parameter S_key2_single = 1'b1;

	integer i,j;

// ========================== Output =======================================
	assign o_random_out = (idx==3'b0)? number : mem_reg[idx];
	assign o_index_out = {1'b0, idx};
// ========================== LED R  =======================================
	logic [17:0] o_led_reg;
	assign result = (idx==3'b0)? number : mem_reg[idx];
	always_comb begin
		case(result)
			4'd0:  o_led_reg = 18'b000000000000000001;
			4'd1:  o_led_reg = 18'b000000000000000010;
			4'd2:  o_led_reg = 18'b000000000000000100;
			4'd3:  o_led_reg = 18'b000000000000001000;
			4'd4:  o_led_reg = 18'b000000000000010000;
			4'd5:  o_led_reg = 18'b000000000000100000;
			4'd6:  o_led_reg = 18'b000000000001000000;
			4'd7:  o_led_reg = 18'b000000000010000000;
			4'd8:  o_led_reg = 18'b000000000100000000;
			4'd9:  o_led_reg = 18'b000000001000000000;
			4'd10: o_led_reg = 18'b000000010000000000;
			4'd11: o_led_reg = 18'b000000100000000000;
			4'd12: o_led_reg = 18'b000001000000000000;
			4'd13: o_led_reg = 18'b000010000000000000;
			4'd14: o_led_reg = 18'b000100000000000000;
			4'd15: o_led_reg = 18'b001000000000000000;
		endcase
	end
	
	assign o_led = o_led_reg;
	
// ========================== LED G   =======================================
	logic [8:0] o_led_idx_reg;
	always_comb begin
		case(idx)
			3'd0: o_led_idx_reg = 9'b000000001;
			3'd1: o_led_idx_reg = 9'b000000010;
			3'd2: o_led_idx_reg = 9'b000000100;
			3'd3: o_led_idx_reg = 9'b000001000;
			3'd4: o_led_idx_reg = 9'b000010000;
			3'd5: o_led_idx_reg = 9'b000100000;
			3'd6: o_led_idx_reg = 9'b001000000;
			3'd7: o_led_idx_reg = 9'b010000000;
		endcase
	end
	
	assign o_led_idx = o_led_idx_reg;
// ========================== Counter =======================================
	always_comb begin
		count_next = 26'b0;
		if(state == S_IDLE && !i_start) begin
			count_next =  26'b0;
		end
		else begin
			if(count == 4*T) begin
				count_next = 0;
			end
			else begin
				count_next = count + 1;
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n)  begin
		if(!i_rst_n) begin
			count <= 26'b0;
		end
		else begin
			count <= count_next;
		end
	end


// ========================== State Transition =======================================
	always_comb begin
		case (state)
			S_IDLE: begin
				if(i_start==1) begin
					state_next = S_change_one;
				end
				else begin
					state_next = S_IDLE;
				end
			end

			S_change_one: begin
				if(count==0) begin
					state_next = S_change_two;
				end
				else if(i_left == 1) begin
					state_next = S_IDLE;
				end
				else begin
					state_next = S_change_one;
				end
			end

			S_change_two: begin
				if(count==0) begin
					state_next = S_change_four;
				end
				else if(i_left == 1) begin
					state_next = S_IDLE;
				end
				else begin
					state_next = S_change_two;
				end
			end

			S_change_four: begin
				if(count==0) begin
					state_next = S_IDLE;
				end
				else if(i_left == 1) begin
					state_next = S_IDLE;
				end
				else begin
					state_next = S_change_four;
				end
			end
		endcase
	end
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			state <= S_IDLE;
		end
		else begin
			state <= state_next;
		end
	end

// ========================== Key2 Double Click =======================================

	always_comb begin
		timer_next = 26'b0;
		if(key2_state==S_key2_IDLE) begin
			timer_next = 0;
		end
		else begin
			timer_next = timer+1;
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n)  begin
		if(!i_rst_n) begin
			timer <= 26'b0;
		end
		else begin
			timer <= timer_next;
		end
	end


	always_comb begin
		if(key2_state == S_key2_IDLE) begin
			if(i_right) begin
				key2_state_next = S_key2_single;
			end
			else begin
				key2_state_next = S_key2_IDLE;
			end
		end

		else begin
			if(timer == T_key2 || i_right) begin
				key2_state_next = S_key2_IDLE;
			end
			else begin
				key2_state_next = S_key2_single;
			end
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			key2_state <= S_key2_IDLE;
		end
		else begin
			key2_state <= key2_state_next;
		end
	end

// ========================== Mem Shift Register =======================================
	always_comb begin
		if(state==S_change_four && count==0 || (i_left == 1)) begin
			for (j=1;j<8; ++j) begin
				mem_reg_next[j]=mem_reg[j-1];
			end
			mem_reg_next[0]=number;
		end
		else begin
			for (j=0;j<8; ++j) begin
				mem_reg_next[j]=mem_reg[j];
			end
		end
	end
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			for (i=0; i<8; ++i) begin
				mem_reg[i] <= 4'b0;
			end
		end
		else begin
			for (i=0;i<8; ++i) begin
				mem_reg[i] <= mem_reg_next[i];
			end
		end
	end

	always_comb begin
		if(key2_state==S_key2_IDLE)begin
			if(i_right) begin
				idx_next=idx+1;
			end
			else begin
				idx_next=idx;
			end
		end
		else begin
			if(i_right) begin
				idx_next=0;
			end
			else begin
				idx_next=idx;
			end
		end

		
	end
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			idx<=3'b0;
		end
		else begin
			if(state !== S_IDLE) begin
				idx<=3'b0;
			end
			else begin
				idx<=idx_next;
			end
		end
	end
	
	// ========================== Random Number Generate =======================================
	LFSR4bit L1 (i_clk,i_rst_n,new_num);
	
	always_comb begin
		number_next = number;
		case (state)
			S_IDLE:
				number_next = number;
			S_change_one:
				if(count==1 || count ==1+T || count ==1+2*T || count== 1+3*T)  begin
					number_next = new_num;
				end
			S_change_two:
				if(count==1 || count== 1+2*T) begin
					number_next = new_num;
				end
				else begin
					number_next = number;
				end
			S_change_four:
				if(count== 1) begin
					number_next = new_num;
				end
				else begin
					number_next = number;
				end
		endcase
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			number <= 4'b0;
		end
		else begin
			number <= number_next;
		end
	end

	
endmodule

module LFSR4bit (
  input clk,
  input rst,
  output [3:0] lfsr_out
);

  logic [3:0] lfsr_reg, lfsr_reg_next;
  logic feedback;

  // Feedback polynomial for a 4-bit LFSR: x^4 + x^3 + 1
  assign feedback = (lfsr_reg[3] ^ lfsr_reg[2]) ^ 1;
  
  always_comb begin
    lfsr_reg_next={lfsr_out[2:0],feedback};
  end
  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      lfsr_reg <= 4'b0001; // Initialize with a non-zero value
    end else begin
      lfsr_reg <= lfsr_reg_next;
    end
  end
  assign lfsr_out = lfsr_reg;


endmodule
