module Rsa256Core (
	input          i_clk,
	input          i_rst,
	input          i_start,
	input  [255:0] i_a, // cipher text y
	input  [255:0] i_d, // private key
	input  [255:0] i_n,
	output [255:0] o_a_pow_d, // plain text x
	output         o_finished
);

// operations for RSA256 decryption
// namely, the Montgomery algorithm
	logic i_mod_start, i_mont_m_start, i_mont_t_start;
	logic i_mod_start_w,i_mod_start_r;
	logic i_mont_start_w,i_mont_start_r;
	logic o_mod_finish, o_mont_m_finish, o_mont_t_finish;
	logic [255:0] t_init,m_r,m_w,t_r,t_w;
	logic result_m_mont, result_t_mont;
	
	logic [1:0] state,state_next;
	logic [8:0] top_count, top_count_next;

	modulo_product m1(
		.clk(i_clk),
		.rst(i_rst),
		.start(i_mod_start_r),
		.N(i_n),
		.y(i_a),
		.m(t_init),
		.finish_r(o_mod_finish)
	);

	//m mont
	doubi_product d1(
		.clk(i_clk),
		.rst_n(i_rst),
		.start(i_mont_start_r),
		.N(i_n),
		.a(t_r),
		.b(m_r),

		.m(result_m_mont),
		.finish(o_mont_m_finish)
	);

	doubi_product d2(
		.clk(i_clk),
		.rst_n(i_rst),
		.start(i_mont_start_r),
		.N(i_n),
		.a(t_r),
		.b(t_r),

		.m(result_t_mont),
		.finish(o_mont_t_finish)
	);

//FSM
	parameter S_IDLE = 2'b00;
	parameter S_MOD  = 2'b01;
	parameter S_MONT = 2'b10;
	parameter S_Check = 2'b11;

	always_comb begin
		state_next = state;
		case (state)
			S_IDLE: begin
				state_next = state;
				if(i_start) begin
					state_next = S_MOD;
				end
			end

			S_MOD: begin
				state_next = state;

				if(o_mod_finish) begin
					state_next = S_MONT;
				end
			end

			S_MONT: begin
				state_next = state;

				if(o_mont_m_finish && o_mont_t_finish) begin
					state_next = S_Check;
				end
			end

			S_Check: begin
				state_next = state;

				if(top_count == 256) begin
					state_next = S_IDLE;
				end
			end
		endcase
	end
	always_ff @(posedge i_clk or negedge i_rst) begin
		if(!i_rst) begin
			state <= S_IDLE;
		end
		else begin
			state <= state_next;
		end
	end

//top counter
	always_comb begin
		top_count_next = top_count;
		if(state == S_Check) begin
			top_count_next = top_count + 1;
		end
		else if (state == S_Check && top_count==256) begin
			top_count_next = 9'b0;
		end
	end
	always_ff @(posedge i_clk or negedge i_rst) begin
		if(!i_rst) begin
			top_count <= 9'b0;
		end
		else begin
			top_count <= top_count_next;
		end
	end
endmodule
