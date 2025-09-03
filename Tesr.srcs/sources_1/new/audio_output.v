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

//���������Ӷ��� �ұ��д��������
module audio_output(
    input clk,           // ʱ���ź�
    input rst,           // ��λ�ź�
    input start_to_sound,         // �����ź�
    output wire is_over,
    output reg audio_sd, // Audio SD��������
    output reg voice,
    output reg audio_pwm // Audio PWM�������
);
    reg [31:0] pwm_counter;
    reg [31:0] pwm_threshold;
    parameter pwm_freq = 1000; // PWMƵ��
    parameter pwm_duty = 50;   // PWMռ�ձ�
    
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            pwm_counter <= 0;
            audio_pwm <= 0;
            audio_sd <= 0;
            voice <= 0;
            pwm_threshold <= (50000000 / pwm_freq);
        end else begin
            if (start_to_sound && !is_over) begin
                audio_sd <= 1; // ������Ƶ��·
                pwm_counter <= pwm_counter + 1;
                if (pwm_counter < (pwm_threshold * pwm_duty / 100)) begin
                    audio_pwm <= 1; // ����ߵ�ƽ
                    voice <= 1;
                end else begin
                    audio_pwm <= 0; // ����͵�ƽ
                    voice <= 0;
                end
                if (pwm_counter >= pwm_threshold)
                    pwm_counter <= 0;
            end else begin
                audio_sd <= 0; // ������Ƶ��·
                audio_pwm <= 0; // ����͵�ƽ
                voice <= 0;
            end
        end
    end
endmodule
