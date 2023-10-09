module doubi_product(
    input clk,
    input rst,
    input start,
    input [255:0] N,
    input [255:0] a,
    input [255:0] b,

    output reg [255:0] m,
    output reg finish
);

    logic [8:0] count_next, count;
    logic [255:0] N_stable, a_stable, b_stable, N_next, a_next, b_next, m_next;
    logic finish_next;

    logic [257:0] three_add;
    logic [256:0] add_m_b_stable;
    logic [256:0] add_m_N_stable;
    assign three_add = add_m_b_stable+N_stable;
    assign add_m_b_stable = m+b_stable;
    assign add_m_N_stable = m+N_stable;
    // counter
    always_comb begin
        count_next = count + 1;
        if(count==0 && !start) begin
            count_next = 0;
        end
        else if(count == 257) begin
            count_next = 0;
        end
        else begin
            count_next = count + 1;
        end
    end

    // input ff stable
    always_comb begin
        N_next=N;
        a_next=a;
        b_next=b;
        if(start && count==0) begin
            N_next=N;
            a_next=a;
            b_next=b;
        end
        else begin
            N_next=N_stable;
            a_next=a_stable;
            b_next=b_stable;
        end
    end


    // finish
    // always_comb begin
    //     finish_next=finish;
    //     if(count==257 ||(count==0 && !start)) begin
    //         finish_next=1;
    //     end
    //     else if(start && count==0) begin
    //         finish_next=0;
    //     end
    //     else begin
    //         finish_next=finish;
    //     end
    // end
    always_comb begin
        finish_next = finish;
        if(count == 257) begin
            finish_next = 1;
        end
        if(count == 0 && finish ==1) begin
            finish_next = 0;
        end    
    end

    // algorithm
    always_comb begin
        if(count==0 && start) begin
            m_next=0;
        end
        else if(count==0) begin
            m_next=m;
        end
        else begin
            if(count==257) begin
                if(m>=N_stable) begin
                    m_next=m-N_stable;
                end
                else begin
                    m_next=m;
                end
            end
            else begin
                if(a_stable[(count-1)]==1)begin
                    if((m[0]+b_stable[0])==1) begin
                        m_next=((three_add)>>1);
                    end
                    else begin
                        m_next=((add_m_b_stable)>>1);
                    end
                end
                else begin
                    if(m[0]==1)begin
                        m_next=((add_m_N_stable)>>1);
                    end
                    else begin
                        m_next=m>>1;
                    end
                end
            end
        end
    end



    //all_flipflops
    always_ff @ (posedge clk or posedge rst) begin
        if (rst) begin
            m<=256'b0;
            finish<=1'b0;
            count<=9'b0;
            N_stable<=256'b0;
            a_stable<=256'b0;
            b_stable<=256'b0;
        end
        else begin
            m<=m_next;
            count<=count_next;
            finish<=finish_next;
            N_stable<=N_next;
            a_stable<=a_next;
            b_stable<=b_next;
        end
    end



endmodule