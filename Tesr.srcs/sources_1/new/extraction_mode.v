module extraction_mode(
   input level_1,level_2,level_3,clk,rst,timer_is_start,
   output wire timer_is_over,level3_is_over,[17:0]menu_time,[17:0]level_time,
   output going_to_menu
   );
   parameter tim=8'b00000110;
 
   //按菜单键启动
    countdown uy1(
        .clk(clk),
        .rst(rst),
        .start(timer_is_start),
        .initial_seconds(tim),
        .is_over(timer_is_over),
        .countdown(menu_time),
        .countdown_done(going_to_menu)
    );
   wire countdown_done;
   //一进入三档就开始倒计时
   countdown uy2(
        .clk(clk),
        .rst(rst),
        .start(level_3),
        .initial_seconds(tim),
        .is_over(level3_is_over),
        .countdown(level_time),
        .countdown_done(countdown_done)
    );   


endmodule