module I2CInitializer(
    input  	i_rst_n,
    input  	i_clk,
    input  	i_start,
    output logic	o_finished,
    output logic	o_sclk,
    output logic 	o_sdat,
    output logic	o_oen
);
// 7b I2C addr, 1b R/W, 7b Reg addr, 9b Reg data
localparam [239 : 0] REG_CONFIG = {
    24'b0011010_0_000_1001_0_0000_0001,
    24'b0011010_0_000_1000_0_0001_1001,
    24'b0011010_0_000_0111_0_0100_0010,
    24'b0011010_0_000_0110_0_0000_0000,
    24'b0011010_0_000_0101_0_0000_0000,
    24'b0011010_0_000_0100_0_0001_0101,
    24'b0011010_0_000_0011_0_0111_1001,
    24'b0011010_0_000_0010_0_0111_1001,
    24'b0011010_0_000_0001_0_1001_0111,
    24'b0011010_0_000_0000_0_1001_0111
};

localparam S_IDLE = 0;
localparam S_START = 1;
localparam S_DATA = 2;
localparam S_ACK = 3;
localparam S_STOP = 4;
localparam S_RESTART = 5;

logic [2:0]       		 state, state_nxt;
logic [239:0] 		     data, data_nxt;
logic [3:0] 			 reg_count, reg_count_nxt;   // 0 to 9
logic [1:0] 			 byte_count, byte_count_nxt; // 0 to 2
logic [2:0] 			 bit_count, bit_count_nxt;   // 0 to 7

logic [7:0]				 databus;


assign databus = data[239: 232];

always_comb begin
	state_nxt = state;
	data_nxt = data;
	reg_count_nxt = reg_count;
	byte_count_nxt = byte_count;
	bit_count_nxt = bit_count;
	o_sclk = 1'b1;
	o_sdat = 1'b1;
	o_oen = 1'b1;
	o_finished = 1'b0;
	
	case (state)
		S_IDLE: begin
			state_nxt = i_start ? S_START : S_IDLE;
		end
		S_START: begin
			state_nxt = S_DATA;
			bit_count_nxt = 0;
			byte_count_nxt = 0;
			o_sdat = 1'b0;
		end 
		S_DATA: begin
			if(bit_count == 7) begin
				state_nxt = S_ACK; 
				bit_count_nxt = 0;
			end
			else begin
				state_nxt = S_DATA;
				bit_count_nxt = bit_count + 1; 
			end
			o_sclk = ~i_clk;
			o_sdat = databus[ 3'd7 - bit_count ];
		end
		S_ACK: begin
			o_oen = 1'b0;
			o_sclk = ~i_clk;
			// Anyway, we just assume the transmissoin is reliable
			if(byte_count == 2) begin
				state_nxt = S_STOP;
				byte_count_nxt = 0;
				data_nxt = data << 8;
			end
			else begin
				state_nxt = S_DATA;
				byte_count_nxt = byte_count + 1;
				data_nxt = data << 8;
			end
		end 
		S_STOP: begin
			if(reg_count == 9) begin
				state_nxt = S_IDLE;
				reg_count_nxt = 0;
				o_finished = 1'b1;
				
			end
			else begin
				state_nxt = S_RESTART;	
				reg_count_nxt = reg_count + 1;		
			end
			o_sclk = 1;
			o_sdat = 0;
	
		end 
		S_RESTART: begin
			state_nxt = S_START;
			o_sclk = 1;
			o_sdat = 1;
		end 
		default: begin
			
		end 
	endcase
end


always_ff @(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		state <= S_IDLE;
		data <= REG_CONFIG;
		reg_count <= 0;
		byte_count <= 0;
		bit_count <= 0;
	end 
	else begin
		state <= state_nxt;
		data <= data_nxt;
		reg_count <= reg_count_nxt;
		byte_count <= byte_count_nxt;
		bit_count <= bit_count_nxt;
	end
end
endmodule