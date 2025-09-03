module self_cleaning_module(
   input is_clean,clk,rst,
   output wire is_over,
   output [17:0]clean_time
   );
   wire countdown_done;
   parameter t=8'b00000011;
   countdown clean(
        .clk(clk),
        .rst(rst),
        .start(is_clean),
        .initial_seconds(t),
        .is_over(is_over),
        .countdown(clean_time),
        .countdown_done(countdown_done)
   );
   
endmodule
