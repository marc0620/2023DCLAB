module modulo_product (
    input clk,
    input rst,
    input start,
    input [255:0] N,
    input [255:0] y,
    output reg [255:0] m,
    output reg finish_r
);
    logic [8:0] count,count_next;
    logic [255:0] m_next;
    logic [257:0] t,t_next;
    logic finish_w;

    logic [256:0] y_add,t_add;

    assign y_add = y + y;
    assign t_add = t + t;
//counter
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
// t

    always_comb begin
        t_next = t;
        if((count==0 && !start) || count==256) begin
            t_next = t;
        end
        else if(count ==0 && start) begin
            if(y_add>N) begin
                t_next = y_add - N;
            end
            else begin
                t_next = y_add;
            end
        end
        else begin    
            if(t_add>N) begin
                t_next = t_add - N;
            end
            else begin
                t_next = t_add;
            end
        end
       
    end
// m
    always_comb begin
        m_next = m;
        if(count == 256) begin
            if(m+t>N) begin
                m_next = m + t - N;
            end
            else begin
                m_next = m + t;
            end
        end 
        if(start && count==0) begin
            m_next = 0;
        end   
    end
//finish
    always_comb begin
        finish_w = finish_r;
        if(count == 256) begin
            finish_w = 1;
        end
        if(count == 0 && finish_r ==1) begin
            finish_w = 0;
        end   
    end
    
//ff
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            count <= 9'b0;
            t <= 258'b0;
            m <= 256'b0;
            finish_r <= 0;
        end
        else begin
            count <= count_next;
            t <= t_next;
            m <= m_next;
            finish_r <= finish_w;
        end
    end
endmodule