module Rsa256Wrapper (
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address, // 
    output        avm_read, // high when reading
    input  [31:0] avm_readdata, //data bus
    output        avm_write, // high when writing
    output [31:0] avm_writedata, //data bus
    input         avm_waitrequest //needs to be 0 to do sth
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Feel free to design your own FSM!

localparam S_QUERY_RX = 3'd0;
localparam S_READ = 3'd1;
localparam S_CALCULATE = 3'd2;
localparam S_QUERY_TX = 3'd3;
localparam S_WRITE = 3'd4;

localparam S_READ_N = 2'd0;
localparam S_READ_D = 2'd1;
localparam S_READ_ENC = 2'd2;


logic [255:0] n_r, n_w, d_r, d_w, enc_r, enc_w, dec_r, dec_w;
logic [2:0] state_r, state_w;
logic [1:0] read_state_r, read_state_w;
logic [6:0] bytes_counter_r, bytes_counter_w;
logic [4:0] avm_address_r, avm_address_w;
logic avm_read_r, avm_read_w, avm_write_r, avm_write_w;

logic rsa_start_r, rsa_start_w;
logic rsa_finished;
logic [255:0] rsa_dec;

assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = dec_r[247-:8];


Rsa256Core rsa256_core(
    .i_clk(avm_clk),
    .i_rst(avm_rst),
    .i_start(rsa_start_r),
    .i_a(enc_r),
    .i_d(d_r),
    .i_n(n_r),
    .o_a_pow_d(rsa_dec),
    .o_finished(rsa_finished)
);

task StartRead;
    input [4:0] addr;
    begin
        avm_read_w = 1;
        avm_write_w = 0;
        avm_address_w = addr;
    end
endtask
task StartWrite;
    input [4:0] addr;
    begin
        avm_read_w = 0;
        avm_write_w = 1;
        avm_address_w = addr;
    end
endtask

// defaults


always_comb begin
    n_w = n_r;
    d_w = d_r;
    enc_w = enc_r;
    dec_w = dec_r;
    avm_address_w = avm_address_r;
    avm_read_w = avm_read_r;
    avm_write_w = avm_write_r;
    state_w = state_r;
    read_state_w = read_state_r;
    bytes_counter_w = bytes_counter_r;
    rsa_start_w = rsa_start_r;

    case (state_r)
        S_QUERY_RX: begin
            if((!avm_waitrequest) && (avm_address_r==STATUS_BASE) && avm_readdata[RX_OK_BIT]) begin
                StartRead(RX_BASE);
                state_w = S_READ;
            end
            else begin
                StartRead(STATUS_BASE);
                state_w = S_QUERY_RX;
            end 
        end

        S_READ: begin
            case (read_state_r)
                S_READ_N: begin
                    if ((!avm_waitrequest) && (avm_address_r==RX_BASE)) begin
                        if(bytes_counter_r < 7'd31) begin
                            n_w = n_r << 8;
                            n_w[7:0] = avm_readdata[7:0];
                            bytes_counter_w = bytes_counter_r + 7'd1;
                            StartRead(STATUS_BASE);
                            state_w = S_QUERY_RX;
                            read_state_w = S_READ_N;
                        end
                        else begin
                            n_w = n_r << 8;
                            n_w[7:0] = avm_readdata[7:0];
                            bytes_counter_w = 7'd0;
                            StartRead(STATUS_BASE);
                            state_w = S_QUERY_RX;
                            read_state_w = S_READ_D;
                        end
                    end
                end
                S_READ_D: begin
                    if ((!avm_waitrequest)  && (avm_address_r==RX_BASE)) begin
                        if(bytes_counter_r < 7'd31) begin
                            d_w = d_r << 8;
                            d_w[7:0] = avm_readdata[7:0];
                            bytes_counter_w = bytes_counter_r + 7'd1;
                            StartRead(STATUS_BASE);
                            state_w = S_QUERY_RX;
                            read_state_w = S_READ_D;
                        end
                        else begin
                            d_w = d_r << 8;
                            d_w[7:0] = avm_readdata[7:0];
                            bytes_counter_w = 7'd0;
                            StartRead(STATUS_BASE);
                            state_w = S_QUERY_RX;
                            read_state_w = S_READ_ENC;
                        end
                    end
                end
                S_READ_ENC: begin
                    if ((!avm_waitrequest) && (avm_address_r==RX_BASE)) begin
                        if(bytes_counter_r < 7'd31) begin
                            enc_w = enc_r << 8;
                            enc_w[7:0] = avm_readdata[7:0];
                            bytes_counter_w = bytes_counter_r + 7'd1;
                            StartRead(STATUS_BASE);
                            state_w = S_QUERY_RX;
                            read_state_w = S_READ_ENC;
                        end
                        else begin
                            enc_w = enc_r << 8;
                            enc_w[7:0] = avm_readdata[7:0];
                            bytes_counter_w = 7'd0;
                            StartRead(STATUS_BASE);
                            state_w = S_CALCULATE;
                            read_state_w = S_READ_ENC;
                            rsa_start_w = 1'b1;
                        end
                    end
                end
                default: begin
                    // will not enter
                    read_state_w = read_state_r;
                end
            endcase
        end

        S_CALCULATE: begin
            rsa_start_w = 1'b0;
            if(rsa_finished) begin
                state_w = S_QUERY_TX;
                dec_w = rsa_dec;
            end
        end

        S_QUERY_TX: begin
            if((!avm_waitrequest) && (avm_address_r==STATUS_BASE) && avm_readdata[TX_OK_BIT]) begin
                StartWrite(TX_BASE);
                state_w = S_WRITE;
            end
            else begin
                StartRead(STATUS_BASE);
                state_w = S_QUERY_TX;
            end 
        end

        S_WRITE: begin
            if (!avm_waitrequest && (avm_address_r==TX_BASE)) begin
                if(bytes_counter_r < 7'd30) begin
                    dec_w = dec_r << 8;
                    bytes_counter_w = bytes_counter_r + 7'd1;
                    StartRead(STATUS_BASE);
                    state_w = S_QUERY_TX;
                end
                else begin
                    dec_w = dec_r << 8;
                    bytes_counter_w = 7'd0;
                    StartRead(STATUS_BASE);
                    state_w = S_QUERY_RX;
                end
            end
        end

        default: begin
            // will not enter
            state_w = state_r;
        end

    endcase
end


// Current State
always_ff @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
        n_r <= 0;
        d_r <= 0;
        enc_r <= 0;
        dec_r <= 0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        state_r <= S_QUERY_RX;
        read_state_r <= S_READ_N;
        bytes_counter_r <= 0;
        rsa_start_r <= 0;

    end else begin
        n_r <= n_w;
        d_r <= d_w;
        enc_r <= enc_w;
        dec_r <= dec_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        state_r <= state_w;
        read_state_r <= read_state_w;
        bytes_counter_r <= bytes_counter_w;
        rsa_start_r <= rsa_start_w;
    end
end

endmodule

