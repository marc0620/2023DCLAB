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
	logic [257:0] t_init,m_r,m_w,t_r,t_w;
	logic [257:0] result_m_mont, result_t_mont;
	
	logic [1:0] state,state_next;
	logic [8:0] top_count, top_count_next;

//for answer
	logic o_finished_w,o_finished_r;
	logic [255:0] o_a_pow_d_w,o_a_pow_d_r;

	assign o_finished = o_finished_r;
	assign o_a_pow_d = o_a_pow_d_r;

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
		.rst(i_rst),
		.start(i_mont_start_r),
		.N(i_n),
		.a(t_r),
		.b(m_r),

		.m(result_m_mont),
		.finish(o_mont_m_finish)
	);

	doubi_product d2(
		.clk(i_clk),
		.rst(i_rst),
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

				if(top_count == 255) begin
					state_next = S_IDLE;
				end
				else begin
					state_next = S_MONT;
				end
			end
		endcase
	end
	always_ff @(posedge i_clk or posedge i_rst) begin
		if(i_rst) begin
			state <= S_IDLE;
		end
		else begin
			state <= state_next;
		end
	end
//control signal
	always_comb begin
		i_mod_start_w = i_mod_start_r;
		i_mont_start_w = i_mont_start_r;
		m_w = m_r;
		t_w = t_r;
		o_finished_w = o_finished_r;
		o_a_pow_d_w = o_a_pow_d_r; 
		case (state)
			S_IDLE: begin
				if(i_start) begin
					i_mod_start_w = 1;
				end
			end

			S_MOD: begin
				if(o_mod_finish) begin
					i_mont_start_w = 1;
					t_w = t_init;
				end
			end

			S_MONT: begin
				
				// if(o_mont_m_finish && o_mont_t_finish) begin
				// 	i_mont_start_w = i_mont_start_r; //useless
				// end
				// if
				// else begin
				// 	i_mont_start_w = 0;
				// end

				i_mont_start_w = 0;

				if(o_mont_m_finish) begin
					m_w = (i_d[top_count]==1)? result_m_mont : m_r;
				end
				else begin
					m_w = m_r;
				end

				if(o_mont_t_finish) begin
					t_w = result_t_mont;
				end
				else begin
					t_w = t_r;
				end
			end

			S_Check: begin
				i_mont_start_w = i_mont_start_r;
				if(top_count == 255) begin
					i_mont_start_w = 0;
					o_finished_w = 1;
					o_a_pow_d_w = m_r;
				end
				else begin
					i_mont_start_w = 1;
				end
			end
		endcase
	end
	always_ff @(posedge i_clk or posedge i_rst) begin
		if(i_rst) begin
			i_mod_start_r <= 0;
			i_mont_start_r <= 0;
			m_r <= 256'b1;
			t_r <= 0; // later use t_init to change
			o_finished_r <= 0;
			o_a_pow_d_r <= 256'b0;
		end
		else begin
			i_mod_start_r <= i_mod_start_w;
			i_mont_start_r <= i_mont_start_w;
			m_r <= m_w;
			t_r <= t_w;
			o_finished_r <= o_finished_w;
			o_a_pow_d_r <= o_a_pow_d_w;
		end
	end

//top counter
	always_comb begin
		top_count_next = top_count;
		if(state == S_Check) begin
			top_count_next = top_count + 1;
		end
		if (state == S_Check && top_count==255) begin
			top_count_next = 9'b0;
		end
	end
	always_ff @(posedge i_clk or posedge i_rst) begin
		if(i_rst) begin
			top_count <= 9'b0;
		end
		else begin
			top_count <= top_count_next;
		end
	end
endmodule