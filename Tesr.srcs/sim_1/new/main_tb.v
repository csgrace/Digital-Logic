`timescale 1ns / 1ps

module main_tb;
    reg clk;
    reg rst;
    reg btn1, btn2, btn3, btn4, btn5;
    reg sw, sw_light;
    wire [7:0] mode;
    wire light;
    wire [1:0] edit_index_light;
    wire segment1_control;
    wire segment2_control;
    wire segment3_control;
    wire segment4_control;
    wire segment5_control;
    wire segment6_control;
    wire [15:0] segments;
    wire light1;
    wire beelight;
    wire audio_sd;
    wire audio_pwm;
    wire [1:0] setting_page_index_light;

    // Instantiate the DUT (Device Under Test)
    main uut (
        .clk(clk),
        .rst(rst),
        .btn1(btn1),
        .btn2(btn2),
        .btn3(btn3),
        .btn4(btn4),
        .btn5(btn5),
        .sw(sw),
        .sw_light(sw_light),
        .mode(mode),
        .light(light),
        .edit_index_light(edit_index_light),
        .segment1_control(segment1_control),
        .segment2_control(segment2_control),
        .segment3_control(segment3_control),
        .segment4_control(segment4_control),
        .segment5_control(segment5_control),
        .segment6_control(segment6_control),
        .segments(segments),
        .light1(light1),
        .beelight(beelight),
        .audio_sd(audio_sd),
        .audio_pwm(audio_pwm),
        .setting_page_index_light(setting_page_index_light)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1; btn1 = 0; btn2 = 0; btn3 = 0; btn4 = 0; btn5 = 0;
        sw = 0; sw_light = 0;

        // Reset the system
        rst = 0;
        #20;
        rst = 1;
      
        #2000 sw=1;
        #2000 sw=0;
        #2000 sw=1;
        #2000 sw=0;
        
         #2000 sw=1;
        #2000 sw=0;



         #2000 sw=1;
        #2000  btn1=1;
        #200 btn1=0;
        #40000 
        #2000  btn1=1;
        #200 btn1=0;
      
        #12000
        #2000  btn1=1;
        #200 btn1=0;
        #2000  btn5=1;
        #200 btn5=0;
        
         #40000 
        #2000  btn5=1;
        #200 btn5=0;
        #40000 
        #2000  btn5=1;
        #200 btn5=0;
        #10000
        #2000  btn1=1;
        #200 btn1=0;
        #10000
      

        $finish;
    end

endmodule

