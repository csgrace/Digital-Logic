`timescale 1ns / 1ps
module segment(
input clk,rst,
    input [16:0] total_sec,
    input control,
    input control1,
    output reg segment1_control,  // 百位数码管控制信号
    output reg segment2_control,  // 十位数码管控制信号
    output reg segment3_control,  // 个位数码管控制信号
    output reg segment4_control,  // 个位数码管控制信号
    output reg segment5_control,  // 个位数码管控制信号
    output reg segment6_control,  // 个位数码管控制信号
    output reg [15:0] segments
    );
    
    reg clkout;
    reg [31:0]cnt;
    reg [15:0] display_counter; // 显示控制计数器
    parameter period=40;
    wire [7:0]hour,minute,second;

    assign second=total_sec%60;
    assign minute = (total_sec % 3600) / 60; 
    assign hour = total_sec / 3600;
     
        // 显示控制逻辑
        always @(posedge clk) begin
            display_counter <= display_counter + 1;
            case (display_counter[15:14])  // 使用高位的6个控制位来控制显示切换
                                2'b00: begin
                                    segment1_control <= 1 & control | 1 & rst & control1;   // 激活第一个数码管
                                    segment2_control <= 0& control | 0 & rst & control1; 
                                    segment3_control <= 1& control | 1 & rst & control1; 
                                    segment4_control <= 0& control | 0 & rst & control1; 
                                    segment5_control <= 0& control | 0 & rst & control1; 
                                    segment6_control <= 0& control | 0 & rst & control1; 
                                    segments <= {display_segment(hour / 10),display_segment(minute / 10)}; // 显示小时十位
                                end
                                2'b01: begin
                                    segment1_control <= 0& control | 0 & rst & control1; 
                                    segment2_control <= 1& control | 1 & rst & control1;   // 激活第二个数码管
                                    segment3_control <= 0& control | 0 & rst & control1; 
                                    segment4_control <= 1& control | 1 & rst & control1; 
                                    segment5_control <= 0& control | 0 & rst & control1; 
                                    segment6_control <= 0& control | 0 & rst & control1; 
                                    segments <= {display_segment(hour % 10),display_segment(minute % 10)}; // 显示小时个位
                                end
                                2'b10: begin
                                    segment1_control <= 0& control | 0 & rst & control1; 
                                    segment2_control <= 0& control | 0 & rst & control1; 
                                    segment3_control <= 0& control | 0 & rst & control1;   // 激活第三个数码管
                                    segment4_control <= 0& control | 0 & rst & control1; 
                                    segment5_control <= 1& control | 1 & rst & control1; 
                                    segment6_control <= 0& control | 0 & rst & control1; 
                                    segments <= {8'b1111_1100,display_segment(second / 10)}; // 显示分钟十位
                                end
                                2'b11: begin
                                    segment1_control <= 0& control | 0 & rst & control1; 
                                    segment2_control <= 0& control | 0 & rst & control1; 
                                    segment3_control <= 0& control | 0 & rst & control1; 
                                    segment4_control <= 0& control | 0 & rst & control1;   // 激活第四个数码管
                                    segment5_control <= 0& control | 0 & rst & control1; 
                                    segment6_control <= 1& control | 1& rst & control1; 
                                    segments <= {8'b1111_1100,display_segment(second % 10)}; // 显示分钟个位
                                end
                                default: begin
                                    segment1_control <= 0& control | 0 & rst & control1; 
                                    segment2_control <= 0& control | 0 & rst & control1; 
                                    segment3_control <= 0& control | 0 & rst & control1; 
                                    segment4_control <= 0& control | 0 & rst & control1; 
                                    segment5_control <= 0& control | 0 & rst & control1; 
                                    segment6_control <= 0& control | 0 & rst & control1; 
                                    segments <= 16'b1111110011111100; // 默认显示0
                                end
                     endcase
        end
        function [7:0] display_segment;
            input [3:0] digit;
            begin
                case(digit)
                    4'd0: display_segment = 8'b1111_1100;  // 0
                    4'd1: display_segment = 8'b0110_0000;  // 1
                    4'd2: display_segment = 8'b1101_1010;  // 2
                    4'd3: display_segment = 8'b1111_0010;  // 3
                    4'd4: display_segment = 8'b0110_0110;  // 4
                    4'd5: display_segment = 8'b1011_0110;  // 5
                    4'd6: display_segment = 8'b1011_1110;  // 6
                    4'd7: display_segment = 8'b1110_0000;  // 7
                    4'd8: display_segment = 8'b1111_1110;  // 8
                    4'd9: display_segment = 8'b1111_0110;  // 9
                    default: display_segment = 8'b1111_1100;  // 默认为0
                endcase
            end
        endfunction
endmodule