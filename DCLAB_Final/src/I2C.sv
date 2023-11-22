module I2cInitializer(
    input  i_rst_n,
    input  i_clk,
    input  i_start,
    output o_finished,
    output o_sclk,
    inout  o_sdat,
    output o_oen,
    output o_state
);
localparam data_bytes = 30;
localparam [data_bytes * 8-1: 0] setup_data = {
    24'b00110100_000_1001_0_0000_0001,
    24'b00110100_000_1000_0_0001_1001,
    24'b00110100_000_0111_0_0100_0010,
    24'b00110100_000_0110_0_0000_0000,
    24'b00110100_000_0101_0_0000_0000,
    24'b00110100_000_0100_0_0001_0101,
    24'b00110100_000_0011_0_0111_1001,
    24'b00110100_000_0010_0_0111_1001,
    24'b00110100_000_0001_0_1001_0111,
    24'b00110100_000_0000_0_1001_0111
};
localparam S_IDLE = 0;
localparam S_READY = 1;
localparam S_PROC = 2;
localparam S_FIN1 = 3;
localparam S_FIN2 = 4;
localparam S_FIN3 = 5;
localparam S_FIN4 = 6;
localparam SCLK_READY = 0;
localparam SCLK_OUTPUT = 1;
localparam SCLK_MOD = 2;

logic [2:0] state,state_nxt;
logic [2:0] sclk_S, sclk_Snxt;
logic [data_bytes * 8 - 1: 0] data, data_nxt;
logic oen;
logic sdat, sdat_nxt;
logic sclk, sclk_nxt;
logic finish, finish_nxt;
logic [4:0] ctr1, ctr1_nxt; //ctr1=0~3 3rd means 24'b send finish
logic [4:0] ctr2, ctr2_nxt; //ctr2=0~8 8th cycle send high impedence(oen=1)

assign o_finished = finish;
assign o_sclk = sclk;
assign o_sdat = oen? sdat: 1'bz;
assign o_oen = oen;
assign o_state = ~o_finished & (state>=S_READY);

always_comb begin
	state_nxt = state;
		data_nxt = data;
		sdat_nxt = sdat;
		sclk_nxt = sclk;
		sclk_Snxt = sclk_S;
		finish_nxt = 0;
		oen = 1;
		ctr1_nxt = 0;
		ctr2_nxt = 0;
	case(state)
		S_IDLE: begin
			if(i_start) begin
				state_nxt = S_READY;
				data_nxt = setup_data;
				sclk_nxt = 1;
				sdat_nxt = 0;
				sclk_Snxt = SCLK_READY;
			end
			else begin
				state_nxt = state;
				data_nxt = data;
				sdat_nxt = sdat;
				sclk_nxt = sclk;
				sclk_Snxt = sclk_S;
			end
			finish_nxt = 0;
			oen = 1;
			ctr1_nxt = 0;
			ctr2_nxt = 0;
		end
		S_READY: begin
			state_nxt = S_PROC;
			data_nxt = data << 1;
			sdat_nxt = data[data_bytes * 8 - 1];
			sclk_nxt = 0;
			sclk_Snxt = SCLK_READY;
			finish_nxt = finish;
			oen = 1;
			ctr1_nxt = 0;
			ctr2_nxt = 0;
		end
		S_PROC: begin
			if(ctr1<5'd3) begin
				case(sclk_S)
					SCLK_READY: begin
						ctr2_nxt = ctr2;
						ctr1_nxt = ctr1;
						sdat_nxt = sdat;
						sclk_nxt = 1;
						sclk_Snxt = SCLK_OUTPUT;
						data_nxt = data;
					end
					SCLK_OUTPUT: begin
						ctr2_nxt = ctr2;
						ctr1_nxt = ctr1;
						sdat_nxt = sdat;
						sclk_nxt = 0;
						sclk_Snxt = SCLK_MOD;
						data_nxt = data;
					end
					SCLK_MOD: begin
						ctr2_nxt = (ctr2==5'd8)? 0:ctr2 + 5'd1;
						ctr1_nxt = (ctr2==5'd8)? ctr1+5'd1:ctr1;
						sdat_nxt = data[data_bytes * 8 - 1];
						sclk_nxt = 0;
						sclk_Snxt = SCLK_READY;
						data_nxt = (ctr2==5'd7)? data: ((ctr2==5'd8)&&(ctr1==5'd2))? data: data << 1;
					end
				endcase
				oen = (ctr2==5'd8)? 0:1;
				state_nxt = state;
				finish_nxt = 0;
			end
			else begin
				ctr2_nxt = 0;
				ctr1_nxt = 0;
				sdat_nxt = 0;
				sclk_nxt = 1;
				sclk_Snxt = SCLK_READY;
				data_nxt = data;
				oen = 1;
				state_nxt = S_FIN1;
				finish_nxt = 0;
			end
		end
		S_FIN1: begin
			ctr2_nxt = 0;
			ctr1_nxt = 0;
			sdat_nxt = 1;
			sclk_nxt = 1;
			sclk_Snxt = SCLK_READY;
			data_nxt = data;
			oen = 1;
			state_nxt = S_FIN2;
			finish_nxt = 0;
		end
		S_FIN2: begin
			ctr2_nxt = 0;
			ctr1_nxt = 0;
			sdat_nxt = 0;
			sclk_nxt = 1;
			sclk_Snxt = SCLK_READY;
			data_nxt = data;
			oen = 1;
			state_nxt = S_FIN3;
			finish_nxt = 0;
		end
		S_FIN3: begin
			ctr2_nxt = 0;
			ctr1_nxt = 0;
			sdat_nxt = 0;
			sclk_nxt = 0;
			sclk_Snxt = SCLK_READY;
			data_nxt = data;
			oen = 1;
			state_nxt = S_FIN4;
			finish_nxt = 0;
		end
		S_FIN4: begin
			if(data!=240'd0) begin
				state_nxt = S_PROC;
				data_nxt = data << 1;
				sdat_nxt = data[data_bytes * 8 - 1];
				sclk_nxt = 0;
				sclk_Snxt = SCLK_READY;
				finish_nxt = 0;
				oen = 1;
				ctr1_nxt = 0;
				ctr2_nxt = 0;
			end
			else begin
				state_nxt = S_FIN4;
				data_nxt = data;
				sdat_nxt = 0;
				sclk_nxt = 0;
				sclk_Snxt = SCLK_READY; //don't care
				finish_nxt = 1;
				oen = 1;
				ctr1_nxt = 0;
				ctr2_nxt = 0;
			end
		end
		default: begin
			state_nxt = state;
			data_nxt = data;
			sdat_nxt = sdat;
			sclk_nxt = sclk;
			sclk_Snxt = sclk_S;
			finish_nxt = 0;
			oen = 1;
			ctr1_nxt = 0;
			ctr2_nxt = 0;
		end
	endcase
end
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		state <= S_IDLE;
		data <= setup_data;
		ctr1 <= 0;
		ctr2 <= 0;
		sdat <= 1;
		sclk <= 1;
		sclk_S <= SCLK_MOD;
		finish <= 0;
	end else begin
		state <= state_nxt;
		data <= data_nxt;
		ctr1 <= ctr1_nxt;
		ctr2 <= ctr2_nxt;
		sdat <= sdat_nxt;
		sclk <= sclk_nxt;
		sclk_S <= sclk_Snxt;
		finish <= finish_nxt;
	end
end

// // 7b I2C addr, 1b R/W, 7b Reg addr, 9b Reg data
// localparam [239 : 0] REG_CONFIG = {
//     24'b0011010_0_000_1001_0_0000_0001,
//     24'b0011010_0_000_1000_0_0001_1001,
//     24'b0011010_0_000_0111_0_0100_0010,
//     24'b0011010_0_000_0110_0_0000_0000,
//     24'b0011010_0_000_0101_0_0000_0000,
//     24'b0011010_0_000_0100_0_0001_0101,
//     24'b0011010_0_000_0011_0_0111_1001,
//     24'b0011010_0_000_0010_0_0111_1001,
//     24'b0011010_0_000_0001_0_1001_0111,
//     24'b0011010_0_000_0000_0_1001_0111
// };

// localparam S_IDLE = 0;
// localparam S_START = 1;
// localparam S_DATA = 2;
// localparam S_ACK = 3;
// localparam S_STOP = 4;
// localparam S_RESTART = 5;
// localparam S_RESTART2 = 6;


// logic [2:0]       		 state, state_nxt;
// logic [239:0] 		     data, data_nxt;
// logic [3:0] 			 reg_count, reg_count_nxt;   // 0 to 9
// logic [1:0] 			 byte_count, byte_count_nxt; // 0 to 2
// logic [2:0] 			 bit_count, bit_count_nxt;   // 0 to 7

// logic [7:0]				 databus;


// assign databus = data[239: 232];
// assign o_state = state;



// always_ff @(negedge i_clk or negedge i_rst_n) begin
// 	if(~i_rst_n) begin
// 		ACKcount <= 0;
// 	end
// 	else begin
// 		if((state==S_ACK))begin
// 			ACKcount <= ACKcount+1;
// 		end
// 		else begin
// 			ACKcount <= ACKcount;
// 		end
// 	end
// end


// always_comb begin
// 	state_nxt = state;
// 	data_nxt = data;
// 	reg_count_nxt = reg_count;
// 	byte_count_nxt = byte_count;
// 	bit_count_nxt = bit_count;
// 	o_sclk = 1'b1;
// 	o_sdat = 1'b1;
// 	o_oen = 1'b1;
// 	o_finished = 1'b0;
	
// 	case (state)
// 		S_IDLE: begin
// 			state_nxt = i_start ? S_START : S_IDLE;
// 		end
// 		S_START: begin
// 			state_nxt = S_DATA;
// 			bit_count_nxt = 0;
// 			byte_count_nxt = 0;
// 			o_sdat = 1'b0;
// 		end 
// 		S_DATA: begin
// 			if(bit_count == 7) begin
// 				state_nxt = S_ACK; 
// 				bit_count_nxt = 0;
// 			end
// 			else begin
// 				state_nxt = S_DATA;
// 				bit_count_nxt = bit_count + 1; 
// 			end
// 			o_sclk = ~i_clk;
// 			o_sdat = databus[ 3'd7 - bit_count ];
// 		end
// 		S_ACK: begin
// 			o_oen = 1'b0;
// 			o_sclk = ~i_clk;
// 			// Anyway, we just assume the transmissoin is reliable
			
// 			if(byte_count == 2) begin
// 				state_nxt = S_STOP;
// 				byte_count_nxt = 0;
// 				data_nxt = data << 8;
// 			end
// 			else begin
// 				state_nxt = S_DATA;
// 				byte_count_nxt = byte_count + 1;
// 				data_nxt = data << 8;
// 			end
// 		end 
// 		S_STOP: begin
			
// 			if(reg_count == 9) begin
// 				state_nxt = S_IDLE;
// 				reg_count_nxt = 0;
// 				o_finished = 1'b1;
// 			end
// 			else begin
// 				state_nxt = S_RESTART;	
// 				reg_count_nxt = reg_count + 1;		
// 			end
// 			o_sclk = 1;
// 			o_sdat = 0;
	
// 		end 
// 		S_RESTART: begin
// 			state_nxt = i_sdat? S_START : state;
// 			o_sclk = 1;
// 			o_sdat = 1;
// 		end 
// 		default: begin
			
// 		end 
// 	endcase
// end


// always_ff @(posedge i_clk or negedge i_rst_n) begin
// 	if(~i_rst_n) begin
// 		state <= S_IDLE;
// 		data <= REG_CONFIG;
// 		reg_count <= 0;
// 		byte_count <= 0;
// 		bit_count <= 0;
// 	end 
// 	else begin
// 		state <= state_nxt;
// 		data <= data_nxt;
// 		reg_count <= reg_count_nxt;
// 		byte_count <= byte_count_nxt;
// 		bit_count <= bit_count_nxt;
// 	end
// end

endmodule
