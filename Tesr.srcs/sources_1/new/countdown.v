module countdown(
    input clk,                  
    input rst,              
    input start,             
    input [17:0] initial_seconds, 
    output reg is_over,
    output reg [17:0] countdown,
    output reg countdown_done
    // output reg is_counting
    );
    wire clk_sec;       
    assign new_clk=clk_sec;
    clock_divider div (
        .clk(clk),
        .rst(rst),
        .clk_out(clk_sec)  
    );
    reg countdown_initialized;  

    always @(posedge clk_sec or negedge rst) begin
        if (~rst) begin
            countdown <= 0;
            countdown_done <= 1;
            countdown_initialized <= 0;
            is_over<=0;
        end else if (start && !countdown_initialized) begin
            countdown <= initial_seconds;  
            countdown_done <= 0;                     
            countdown_initialized <= 1;    
        end else if (start && countdown > 0 && countdown_initialized) begin
            countdown <= countdown - 1;  // countdown
            countdown_done <= 0;  
            // if(countdown==2) 
        end else if (start && countdown == 0 && countdown_initialized) begin
            countdown_done <= 1; 
            countdown_initialized<=0;
            is_over<=1;
        end
        else begin
            countdown <= 0;
            countdown_done <= 1;
            countdown_initialized <= 0;
            is_over<=0;
        end
    end
endmodule
