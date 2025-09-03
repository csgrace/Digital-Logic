

module current_time(
    input clk,
    input rst,              
    input start,
    input [7:0] mode,
    input [17:0] ns_data,
    output reg signed [17:0] countup
    );
    parameter off=8'b00000000,power=8'b10000000,menu=8'b11000000,setting=8'b10100000,query=8'b10010000,
    s1=8'b10001000,s2=8'b10000100,s3=8'b10000010,s4=8'b10000001,edit=8'b10110000;
    wire signed [17:0] total_sec_limit;
     assign total_sec_limit=18'd86400;

    reg [26:0] clk_div_counter; 
    always @(posedge clk or negedge rst) begin
    if (~rst) begin
        clk_div_counter <= 0;
        countup <= 0;
    end else begin
        if (clk_div_counter == 100_000_000 - 1) begin
            clk_div_counter <= 0;
            if (start && countup + 1 == 86399) begin
                countup <= 0;
            end 
            else if (start) begin
                if (mode == edit) begin
                    if (countup >= total_sec_limit || countup < 0)  
                        countup <= 0;
                    else 
                        countup <= ns_data+1;
                end else begin
                    countup <= countup + 1;
                end
            end else begin
                countup <= 0;
            end
        end else begin
            clk_div_counter <= clk_div_counter + 1;
            if(start) begin 
                if (mode == edit) begin
                    countup <= ns_data;
                end 
            end
            else begin
               countup<=0;
            end
        end
    end
end


endmodule
