module countdown_advanced(
    input clk,                  
    input rst,              
    input start,             
    input signed [17:0] initial_seconds, 
    output reg signed [17:0] countdown,
    output reg countdown_done,
    output reg is_over
    // output reg is_counting
    );

    reg countdown_initialized;  
    reg [26:0] clk_div_counter; 
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            countdown <= 0;
            countdown_done <= 1;
            countdown_initialized <= 0;
            clk_div_counter <= 0;
            is_over<=0;
        end 
        else begin //100000000
        if (start && !countdown_initialized) begin
            if(clk_div_counter>=0) clk_div_counter<=0;
            countdown <= initial_seconds;  
            countdown_done <= 0;                     
            countdown_initialized <= 1;   
        end else if (clk_div_counter == 100000000 - 1 && start && countdown > 0 && countdown_initialized) begin
            clk_div_counter <= 0;
            countdown <= countdown - 1;  // countdown
            countdown_done <= 0;  
         
        end else if (clk_div_counter == 100000000 - 1 &&start && countdown == 0 && countdown_initialized) begin
            clk_div_counter <= 0;
            countdown_done <= 1; 
            countdown_initialized<=0;
            is_over<=1;
        end
        else begin
            if(~start)begin
            countdown <= 0;
            countdown_done <= 1;
            countdown_initialized <= 0;
            is_over<=0;
            end
            clk_div_counter <= clk_div_counter + 1;
        end
     end
 end

endmodule
