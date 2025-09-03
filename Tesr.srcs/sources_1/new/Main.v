module main(
    input clk,rst,btn1,btn2,btn3,btn4,btn5,sw,sw_light,
    output reg [7:0]mode,
    output light,
    output wire [1:0] edit_index_light,
    output wire segment1_control,  // 秒个位数数码管控制信号
    output wire segment2_control,  // 秒十位数数码管控制信号
    output wire segment3_control,  // 分钟个位数数码管控制信号
    output wire segment4_control,  // 分钟十位数码管控制信号
    output wire segment5_control,  // 小时个位数码管控制信号
    output wire segment6_control,  // 小时十位数码管控制信号
    output wire [15:0] segments,
    output beelight, //累计工作时长到max，灯亮
    output wire [1:0] setting_page_index_light,
    output query_page_index_light,
    output wire audio_sd,//累计工作时长到max，蜂鸣器叫
    output wire audio_pwm,
    input rxd_pin,        
    output txd_pin,        
    input lb_sel_pin,    
    output bt_pw_on,
    output bt_master_slave,
    output bt_sw_hw,
    output bt_rst_n,
    output bt_sw,
    input [4:0] sw_pin,
    input rst_n

    );
    parameter off=8'b00000000,power=8'b10000000,menu=8'b11000000,setting=8'b10100000,query=8'b10010000,
    s1=8'b10001000,s2=8'b10000100,s3=8'b10000010,s4=8'b10000001,edit=8'b10110000;
    //s4档是自清洁，s123对应123档工作状态
    reg[1:0] setting_page_index;
    reg [1:0] edit_index;
    assign edit_index_light = {2{mode[5]}} & {2{mode[4]}} & edit_index;
    assign setting_page_index_light= {2{mode[5]}}  & setting_page_index;
    reg signed [17:0] display_time;
    wire [17:0]menu_time;
    wire [17:0]level_time;
    wire [17:0]clean_time;
    wire [17:0]cur_time;
    wire btn4_pressed;
    wire btn3_pressed;
    wire btn2_pressed;
    wire btn1_pressed;
    wire btn5_pressed;
    wire clean_is_over;
    reg level3_start_back_to_menu;
    reg ns_level3_start_back_to_menu;
    wire level3_back_to_menu;
    wire level3_is_over;
    reg haved_level3;
    reg ns_haved_level3;
    reg [7:0]next_mode;
    reg start;
    reg ns_start;
    wire btn1_long_pressed;
    reg[1:0] ns_setting_page_index;
    reg query_page_index;
    reg ns_query_page_index;
    reg signed [17:0] data [3:0];//0是手势时间，1是累计时间,2是上限时间,3是动态时间//都是以秒为单位的
    reg signed [17:0] ns_data [3:0];
    wire signed [12:0] edit_data [2:0];
    reg [1:0] ns_edit_index;
    wire signed [17:0] total_sec_limit;
    wire going_to_menu;
    wire hand_on;
    wire hand_off;
    wire [17:0] hand_time;
    wire signed [17:0]  accumulate_time;
    assign query_page_index_light=mode[4]&~mode[5]&query_page_index;
    assign total_sec_limit=18'd86400;
    assign edit_data[0]=13'd3600;
    assign edit_data[1]=13'd60;
    assign  edit_data[2]=13'd1;
    wire bl_power_on;
    assign light=sw_light&mode[7]|bl_power_on&mode[7];
    always @(*) begin
        data[1]=accumulate_time;
    end

    always @(posedge clk, negedge rst) begin
      if(~rst) begin
            mode<=off;
            haved_level3<=1'b0;
            level3_start_back_to_menu<=1'b0;
            setting_page_index<=0;
            query_page_index<=0;
            data[0]<=18'd2;
            data[2]<=18'd60;
            data[3]<=18'd0;
            edit_index<=1;
            start<=0;
            end
      else begin
            mode<=next_mode;
            level3_start_back_to_menu<=ns_level3_start_back_to_menu;
            haved_level3<=ns_haved_level3;
            setting_page_index<=ns_setting_page_index;
            query_page_index<=ns_query_page_index;
            data[0]<=ns_data[0];
            data[2]<=ns_data[2];
            data[3]<=ns_data[3];
            edit_index<=ns_edit_index;
            start<=ns_start;
      end
    end
  
    always @* begin
      ns_data[0]=data[0];
      ns_data[2]=data[2];
      ns_data[3]=data[3];
      ns_edit_index=edit_index;
      ns_setting_page_index=setting_page_index;
      next_mode=mode;
      ns_start=start;
      ns_level3_start_back_to_menu=level3_start_back_to_menu;
      ns_haved_level3=haved_level3;
      ns_query_page_index=query_page_index;
    case(mode)
    off: begin 
      if(sw)begin
        display_time=hand_time;
        if(hand_on) begin
          next_mode=power;
          ns_start=1'b1;
          display_time=cur_time;
        end
      end
      else if(~sw && btn1_pressed) begin
        next_mode=power;
        ns_start=1'b1;
        display_time=cur_time;
      end
      else begin 
         next_mode=off;
         ns_haved_level3=1'b0;
         ns_start=1'b0;
      end
      end
    power:begin
          if(sw)begin
            display_time=hand_time;
            if(hand_off) begin
            next_mode=off;
            ns_start=1'b0; 
            display_time=0; 
          end
          end
          else if(~sw && btn1_long_pressed) begin 
            next_mode=off; 
            ns_start=1'b0; 
            display_time=0; 
            end 
          else if(btn4_pressed) begin 
            next_mode=menu; 
            ns_start=1'b1;
            display_time=cur_time;
            end//加入限制，所有的关机都只能在power模式进行待机/
          else if(btn3_pressed) begin 
            next_mode=query;
            ns_start=1'b1;
            display_time=cur_time;end
          else if(btn2_pressed) begin 
          next_mode=setting;
            display_time=data[setting_page_index];
            end
          else begin 
            next_mode=power;
            ns_start=1'b1;
            display_time=cur_time;
            end
    end
     setting: begin 
            if(setting_page_index==3)begin
              display_time=cur_time;
            end
            else begin
              display_time=data[setting_page_index];
            end
            if(btn1_pressed) begin
            if(setting_page_index==2) begin 
                  ns_setting_page_index=0; 
                  display_time=data[ns_setting_page_index];
            end 
            else if(setting_page_index==3)  begin
                ns_setting_page_index=2;
                display_time=data[ns_setting_page_index];
             end 
            else if(setting_page_index==0) begin 
                ns_setting_page_index=3;
                display_time=data[ns_setting_page_index];
            end 
            else begin 
                ns_setting_page_index=0;
                display_time=data[ns_setting_page_index];
            end
          end
          else if(btn5_pressed) begin //重置
            ns_data[0]=18'd2;
            ns_data[2]=18'd60;
          end
          else if(btn3_pressed || btn4_pressed) begin//调节完必须退回到setting才能继续调节
              next_mode=edit;
            end
          else if(btn2_pressed) begin
            next_mode=power;
            display_time=data[3];
          end
    end 
    edit: begin 
        ns_data[3]=cur_time;
        if(btn2_pressed) begin 
          next_mode=setting;
          display_time=ns_data[setting_page_index];
        end else if(btn1_pressed) begin
            if(edit_index==0) begin 
              ns_edit_index=2;
            end
            else if(edit_index==1)begin
              ns_edit_index=0;
            end 
            else if(edit_index==2)begin
              ns_edit_index=1;
            end 
            else begin ns_edit_index=1;
            end
        end else if(btn5_pressed) begin
            if(edit_index==1)begin  
              ns_edit_index=2; 
            end
            else if(edit_index==2)begin
              ns_edit_index=0;
            end 
            else if(edit_index==0)begin
              ns_edit_index=1;//index 帮个灯
            end 
            else begin ns_edit_index=1;
            end
        end else if(btn3_pressed) begin
            if(setting_page_index!=3) begin
            ns_data[setting_page_index]=data[setting_page_index]+edit_data[edit_index];//可能需要最值判断？
            if(ns_data[setting_page_index]>=total_sec_limit) begin ns_data[setting_page_index]=0;
            end//超限归零
            end
            else begin
            ns_data[setting_page_index]=ns_data[setting_page_index]+edit_data[edit_index];
            if(ns_data[setting_page_index]>=total_sec_limit) begin ns_data[setting_page_index]=0;
            end
            end
        end else if(btn4_pressed) begin
            if(setting_page_index!=3) begin
            ns_data[setting_page_index]=data[setting_page_index]-edit_data[edit_index];//可能需要最值判断？
            if(ns_data[setting_page_index]<0) begin ns_data[setting_page_index]=0;
            end//超限归零
            end
            else begin
            ns_data[setting_page_index]=ns_data[setting_page_index]-edit_data[edit_index];
            if(ns_data[setting_page_index]<0) begin ns_data[setting_page_index]=0;
            end
            end
        end
        if(setting_page_index==3)begin
          display_time=cur_time;
        end else begin
          display_time=data[setting_page_index];
        end
    end 
    query: begin 
      if(btn3_pressed) next_mode=power;
            else if(btn1_pressed || btn5_pressed)begin
              ns_query_page_index=~query_page_index;
              display_time=data[ns_query_page_index];
        end 
          else begin next_mode=query; 
              display_time=data[ns_query_page_index];
          end 
    end
    menu:if(btn1_pressed) begin 
    next_mode=s1; 
    ns_start=1'b1;
    display_time=cur_time;
    end
      else if(btn3_pressed) begin 
        next_mode=s2;
        ns_start=1'b1;
        display_time=cur_time;
      end
      else if(btn5_pressed&&haved_level3==1'b0) begin 
        next_mode=s3;
        display_time=level_time;
        ns_start=1'b1;
      end //还没开始过飓风模式
      else if(btn2_pressed) begin 
        next_mode=s4;
        ns_start=1'b1;
        display_time=clean_time;
      end
      else if(btn4_pressed) begin next_mode=power;ns_start=1'b1;display_time=cur_time;end
      else begin next_mode=menu;ns_start=1'b1;display_time=cur_time;end
               //1档
    s1:if(btn3_pressed) begin next_mode=s2;ns_start=1'b1;display_time=cur_time;end 
       else if(btn4_pressed) begin next_mode=power; ns_start=1'b1;display_time=cur_time;end
       else begin next_mode=s1;ns_start=1'b1;display_time=cur_time;end
               //2档
    s2:if(btn1_pressed) begin next_mode=s1; ns_start=1'b1; display_time=cur_time;end 
       else if(btn4_pressed) begin next_mode=power; ns_start=1'b1; display_time=cur_time;end 
       else begin next_mode=s2; ns_start=1'b1; display_time=cur_time;end 
              //3档
    s3:if(btn4_pressed) begin
       next_mode=s3;
       ns_level3_start_back_to_menu=1'b1;
       ns_start=1'b1;
       display_time=menu_time;
       //此时触发进入抽油烟机里面的倒计时模块
       end
       else if(level3_back_to_menu) begin
       ns_start=1'b1;
       next_mode=power;
       display_time=menu_time;
       ns_level3_start_back_to_menu=1'b0;
       end
       else if(going_to_menu && level3_is_over) begin
       ns_start=1'b1;
       next_mode=s2;
       display_time=cur_time;
       end
       else if(level3_start_back_to_menu)begin
        next_mode=s3;
        ns_start=1'b1;
        ns_level3_start_back_to_menu=1'b1;
        display_time=menu_time;
       end  
       else begin
        next_mode=s3; 
        ns_start=1'b1;
       display_time=level_time;
       ns_level3_start_back_to_menu=1'b0;
       ns_haved_level3=1'b1;
       end   
             //清洁       
    s4:if(clean_is_over) begin next_mode=power;ns_start=1'b1; display_time=cur_time;end 
       else begin next_mode=s4; ns_start=1'b1; display_time=clean_time;end       
    endcase
    end

    is_button_pressed b4(.btn(btn4),.clk(clk),.rst(rst),.pressed(btn4_pressed));
    is_button_pressed b3(.btn(btn3),.clk(clk),.rst(rst),.pressed(btn3_pressed));
    is_button_pressed b2(.btn(btn2),.clk(clk),.rst(rst),.pressed(btn2_pressed));
    is_button_pressed b1(.btn(btn1),.clk(clk),.rst(rst),.pressed(btn1_pressed));
    is_button_pressed b5(.btn(btn5),.clk(clk),.rst(rst),.pressed(btn5_pressed));
    is_button_pressed #(.period(100000000)) b1l(.btn(btn1),.clk(clk),.rst(rst),.pressed(btn1_long_pressed));
    self_cleaning_module uy1(
      .is_clean(mode[0]),
      .is_over(clean_is_over),
      .clk(clk),.rst(rst),
      .clean_time(clean_time)
      );
    extraction_mode uy2(
      .clk(clk),
      .rst(rst),
      .level_time(level_time),
      .menu_time(menu_time),
      .timer_is_start(level3_start_back_to_menu),
      .timer_is_over(level3_back_to_menu),
      .level3_is_over(level3_is_over),
      .level_1(mode[3]),
      .level_2(mode[2]),
      .level_3(mode[1]),
      .going_to_menu(going_to_menu)
      );
    segment ux(
        .clk(clk),
        .rst(rst),
        .control(mode[7]),
        .total_sec(display_time),
        .segments(segments),
        .control1(sw),
        .segment1_control(segment1_control),
        .segment2_control(segment2_control),
        .segment3_control(segment3_control),
        .segment4_control(segment4_control),
        .segment5_control(segment5_control),
        .segment6_control(segment6_control)
    );
    current_time beijing(
        .clk(clk),
        .rst(rst),
        .start(start),
        .mode(mode),
        .ns_data(ns_data[3]),
        .countup(cur_time)
    );
  
    accumulate_time work(
        .clk(clk),
        .rst(rst),
        .start(start),
        .off(mode[7]),
        .max_time(data[2]),
        .clean_mode(mode[0]),
        .level_1(mode[3]),
        .level_2(mode[2]),
        .level_3(mode[1]),
        .countup(accumulate_time),
        .audio_sd(audio_sd),
        .beelight(beelight),
        .audio_pwm(audio_pwm)
    
    );
    bt_uart bt (.clk_pin(clk),
    .rst_pin(rst_n),
    .rxd_pin(rxd_pin),
    .txd_pin(txd_pin),
    .lb_sel_pin(lb_sel_pin),
    .bt_pw_on(bt_pw_on),
    .bt_master_slave(bt_master_slave),
    .bt_sw_hw(bt_sw_hw),
    .bt_rst_n(bt_rst_n),
    .bt_sw(bt_sw),
    .sw_pin(sw_pin),
    .bl_power_on_pins(bl_power_on));

    hand hd(.mode(mode[7]),.hand_time(hand_time),.off(hand_off),.on(hand_on),.clk(clk),.sw(sw),.rst(rst),.btn1(btn1_pressed),.btn5(btn5_pressed),.initial_seconds(data[0]));
endmodule