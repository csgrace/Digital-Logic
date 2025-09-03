`timescale 1ns / 1ps

module hand(input clk,rst,sw,btn1,btn5,mode,
input [17:0] initial_seconds,
output reg on,off,
output[17:0]hand_time
);
reg start;
wire is_over;
wire countdown_done;
    countdown_advanced cd1(
        .clk(clk),
        .rst(rst),
        .start(start),
        .initial_seconds(initial_seconds),
        .countdown(hand_time),
        .countdown_done(countdown_done),
        .is_over(is_over)
   );
   //理解按键信号
   //down=0 is_over=1 在计时
   reg mode_e;
always @(posedge clk,negedge rst) begin
     if(!rst) begin
     mode_e<=1'b0;
     end
     else mode_e<=mode;
end

wire e_up;
reg dir;
assign e_up=mode&~mode_e;//
wire e_down;
assign e_down=~mode&mode_e;

always @* begin
     if(is_over==1 && countdown_done==1) begin
        start=0;
     end
     if(e_up || e_down) begin
       on=1'b0;
       off=1'b0;
       start=0;
     end
  
     if(sw) begin
     if(countdown_done==1'b1)begin
          if(btn1&~mode)  begin
          start=1'b1;
          dir=1'b0;
        end
        else if(btn5&mode) begin
          start=1'b1;
          dir=1'b1;
         end
        end
        else begin
       if(btn1) begin
       if(dir==1'b1)begin
             start=1'b0;//关机
             off=1'b1;
             on=1'b0;
       end
       end
       else if(btn5) begin
        if(dir==1'b0)begin
             start=1'b0;//开机
             on=1'b1;
             off=1'b0;
        end
       end
     end
    end
     else begin
      start=1'b0;
      dir=1'b0;
      on=1'b0;
      off=1'b0;
     end
end
endmodule
