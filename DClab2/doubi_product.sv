module doubi_product(
    input clk,
    input rst_n,
    input start,
    input [255:0] N;
    input [255:0] a;
    input [255:0] b;

    output reg [255:0] m;
    output reg finish;
);

    logic [8:0] count_next, count;
    logic [255:0] N_stable, a_stable, b_stable, N_next, a_next, b_next, m_next;
    logic finish_next;

    // counter
    always_comb begin
        count_next = count + 1;
        if(count==0 && !start) begin
            count_next = 0;
        end
        else if(count == 256) begin
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
    always_comb begin
        if(count==256 ||(count==0 && !start)) begin
            finish_next=1;
        end
        else if(start && count==0) begin
            finish_next=0;
        end
        else begin
            finish_next=finish;
        end
    end

    // algorithm
    always_comb begin
        if(count==0 && start) begin
            m_next=0;
        end
        else begin
            if(a_stable[count]==1) begin
                m_next=m_next+b_stable;
            end
            else begin
                m_next=m_next;
            end
            if m[0]==1 begin
                m_next=m_next+N_stable;
            end
            else begin
                m_next=m_next;
            end
            m_next=m_next>>1;
            if(count==256) begin
                if(m>=N_stable) begin
                    m_next=m-N_stable;
                end
                else begin
                    m_next=m;
                end
            end
            else begin
                m_next=m_next;
            end
        end
    end



    //all_flipflops
    always_ff @ (posedge clk or negedge rst) begin
        if (!rst) begin
            m<=256'0;
            finish<=0;
            count<=8'0;
            N_stable<=256'0;
            a_stable<=256'0;
            b_stable<=256'0;
        end
        else begin
            m<=m_next;
            count<=count_next;
            N_stable<=N_next;
            a_stable<=a_next;
            b_stable<=b_next;
        end
    end



endmodule