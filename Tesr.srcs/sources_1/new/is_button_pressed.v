

module is_button_pressed(input btn,clk,rst,output reg pressed);//tell u whther it is pressed
parameter period =1000000;//1000000
reg stable;
reg stable_d;
reg[1:0] sig;
reg[31:0] cnt;


always @(posedge clk,negedge rst) begin
  if(~rst)
    pressed<=0;
  else
  pressed<=(stable&~stable_d);
end
// assign pressed=stable&~stable_d;

always @(posedge clk,negedge rst) begin
  if(~rst)
    sig<=2'b00;
  else
    sig[0]<=btn;
    sig[1]<=sig[0];
end

always @(posedge clk,negedge rst) begin
  if(~rst)begin
    cnt<=0;
    stable<=1'b0;
  end
  else begin
    if(stable!=sig[1]) begin
      cnt<=cnt+1;
      if(cnt>=period)begin
        stable<=sig[1];
        cnt<=0;
      end
    end
    else begin
      cnt<=0;
    end
  end
end

always @(posedge clk,negedge rst) begin
  if(~rst)
    stable_d<=2'b0;
  else
    stable_d<=stable;
end
endmodule
