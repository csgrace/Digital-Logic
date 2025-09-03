
module accumulate_time(
    input clk,
    input rst,              
    input start,
    input level_1,level_2,level_3,clean_mode,off,
    input wire [17:0]max_time,
    output reg [17:0]countup,
    output wire audio_sd,
    output wire audio_pwm,
    output wire beelight
    );

    wire clk_sec; 
    wire bee; 

    clock_divider div (
        .clk(clk),
        .rst(rst),
        .clk_out(clk_sec)  
    );
    
    always @(posedge clk_sec or negedge rst) begin
        if (~rst) begin
            countup <= 0;
        end 
        else begin 
            if(clean_mode || ~off) begin
            countup<=0;
            end 
            else if (level_1||level_2||level_3) begin
            countup <= countup + 1; 
            end 
        end
    end
    assign bee = (countup >= max_time) ? 1'b1 : 1'b0;
    assign beelight = (countup >= max_time) ? 1'b1 : 1'b0;
    
    audio_output ux1(
        .clk(clk),           // ʱ���ź�
        .rst(rst),           // ��λ�ź�
        .start_to_sound(bee),         // �����ź�
        .audio_sd(audio_sd), // Audio SD��������
        .audio_pwm(audio_pwm) // Audio PWM�������
    );
    
endmodule