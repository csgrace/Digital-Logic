`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/21 14:49:37
// Design Name: 
// Module Name: audio_output
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//耳机孔连接耳机 右边有大声的输出
module audio_output(
    input clk,           // 时钟信号
    input rst,           // 复位信号
    input start_to_sound,         // 启动信号
    output wire is_over,
    output reg audio_sd, // Audio SD控制引脚
    output reg voice,
    output reg audio_pwm // Audio PWM输出引脚
);
    reg [31:0] pwm_counter;
    reg [31:0] pwm_threshold;
    parameter pwm_freq = 1000; // PWM频率
    parameter pwm_duty = 50;   // PWM占空比
    
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            pwm_counter <= 0;
            audio_pwm <= 0;
            audio_sd <= 0;
            voice <= 0;
            pwm_threshold <= (50000000 / pwm_freq);
        end else begin
            if (start_to_sound && !is_over) begin
                audio_sd <= 1; // 启用音频电路
                pwm_counter <= pwm_counter + 1;
                if (pwm_counter < (pwm_threshold * pwm_duty / 100)) begin
                    audio_pwm <= 1; // 输出高电平
                    voice <= 1;
                end else begin
                    audio_pwm <= 0; // 输出低电平
                    voice <= 0;
                end
                if (pwm_counter >= pwm_threshold)
                    pwm_counter <= 0;
            end else begin
                audio_sd <= 0; // 禁用音频电路
                audio_pwm <= 0; // 输出低电平
                voice <= 0;
            end
        end
    end
endmodule
