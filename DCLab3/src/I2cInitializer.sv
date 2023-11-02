module I2CInitializer(
    input  	i_rst_n,
    input  	i_clk,
    input  	i_start,
	input	i_sdat,
    output logic	o_finished,
    output logic	o_sclk,
    output logic 	o_sdat,
    output logic	o_oen,
	output logic [2:0] o_state,
	output logic [6:0] ACKcount
);
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
// endmodule

assign ACKcount = 7'b0;
assign o_state = state;

localparam [239:0] setting = {
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
localparam IDLE = 0;
localparam START = 1;
localparam SEND_DATA = 2;

localparam FINISH  = 3;
localparam S_STOP = 4;

localparam UPDATE = 0;
localparam READ = 1;
localparam DOWN = 2;

logic [2:0] state, state_nxt;
logic [2:0] substate, substate_nxt;
logic [239:0] data, data_nxt;
logic oen;
logic sdat, sdat_nxt;
logic sclk, sclk_nxt;
logic finish, finish_nxt;
logic [4:0] datatype, datatype_nxt; //datatype=0~3 3rd means 24'b send finish
logic [4:0] bitCounter, bitCounter_nxt; //bitCounter=0~8 8th cycle send high impedence(oen=1)

assign o_finished = finish;
assign o_sclk = sclk;
assign o_sdat = sdat;
assign o_oen = oen;

always_comb begin
	state_nxt = state;
	data_nxt = data;
	sdat_nxt = sdat;
	sclk_nxt = sclk;
	substate_nxt = substate;
	finish_nxt = 0;
	oen = 1;
	datatype_nxt = 0;
	bitCounter_nxt = 0;
	case(state)
		IDLE: begin
			if(i_start) begin
				state_nxt = START;
				data_nxt = setting;
				sclk_nxt = 1;
				sdat_nxt = 0;
				substate_nxt = UPDATE;
			end
			finish_nxt = 0;
			oen = 1;
			datatype_nxt = 0;
			bitCounter_nxt = 0;
		end
		START: begin
			state_nxt = SEND_DATA;
			data_nxt = data << 1;
			sdat_nxt = data[239];
			sclk_nxt = 0;
			substate_nxt = UPDATE;
			finish_nxt = finish;
			oen = 1;
			datatype_nxt = 0;
			bitCounter_nxt = 0;
		end
		SEND_DATA: begin
			if(datatype < 5'd3) begin
				case(substate)
					UPDATE: begin
						bitCounter_nxt = bitCounter;
						datatype_nxt = datatype;
						sdat_nxt = sdat;
						sclk_nxt = 1;
						substate_nxt = READ;
						data_nxt = data;
					end
					READ: begin
						bitCounter_nxt = bitCounter;
						datatype_nxt = datatype;
						sdat_nxt = sdat;
						sclk_nxt = 0;
						substate_nxt = DOWN;
						data_nxt = data;
					end
					DOWN: begin
						bitCounter_nxt = (bitCounter==5'd8)? 0:bitCounter + 5'd1;
						datatype_nxt = (bitCounter==5'd8)? datatype+5'd1:datatype;
						sdat_nxt = data[239];
						sclk_nxt = 0;
						substate_nxt = UPDATE;
						data_nxt = (bitCounter==5'd7)? data: ((bitCounter==5'd8)&&(datatype==5'd2))? data: data << 1;
					end
				endcase
				oen = (bitCounter==5'd8)? 0:1;
				state_nxt = state;
				finish_nxt = 0;
			end
			else begin
				bitCounter_nxt = 5'd8;
				datatype_nxt = 0;
				sdat_nxt = 0;
				sclk_nxt = 1;
				substate_nxt = UPDATE;
				data_nxt = data;
				oen = 1;
				state_nxt = FINISH;
				finish_nxt = 0;
			end
		end
		FINISH: begin
			bitCounter_nxt = 0;
			datatype_nxt = 0;
			oen = 1;
			data_nxt = data;
			finish_nxt = 0;
			if(sdat == 0 && sclk == 1 && bitCounter == 5'd8) begin
				sdat_nxt = 1;
				sclk_nxt = 1;
				state_nxt = FINISH;
				substate_nxt = READ;
				bitCounter_nxt = 0;
			end
			else if(sdat == 1 && sclk == 1) begin
				sdat_nxt = 0;
				sclk_nxt = 1;
				state_nxt = FINISH;
			end
			else if(sdat == 0 && sclk == 1 && bitCounter == 0) begin
				sdat_nxt = 0;
				sclk_nxt = 0;
				state_nxt = S_STOP;
				substate_nxt = UPDATE;
			end
		end
		S_STOP: begin
			if(data!=240'd0) begin
				state_nxt = SEND_DATA;
				data_nxt = data << 1;
				sdat_nxt = data[239];
				sclk_nxt = 0;
				finish_nxt = 0;
				oen = 1;
				datatype_nxt = 0;
				bitCounter_nxt = 0;
			end
			else begin
				state_nxt = S_STOP;
				data_nxt = data;
				sdat_nxt = 0;
				sclk_nxt = 0;
				substate_nxt = UPDATE;
				finish_nxt = 1;
				oen = 1;
				datatype_nxt = 0;
				bitCounter_nxt = 0;
			end
		end
	endcase
end
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		state <= IDLE;
		data <= setting;
		datatype <= 0;
		bitCounter <= 0;
		sdat <= 1;
		sclk <= 1;
		substate <= DOWN;
		finish <= 0;
	end 
	else begin
		state <= state_nxt;
		data <= data_nxt;
		datatype <= datatype_nxt;
		bitCounter <= bitCounter_nxt;
		sdat <= sdat_nxt;
		sclk <= sclk_nxt;
		substate <= substate_nxt;
		finish <= finish_nxt;
	end
end
endmodule