`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 21:37:42
// Design Name: 
// Module Name: clock_divider1
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


module clock_divider(
    input clk,      
    input rst,        
    output reg clk_out 
);

    reg [25:0] counter; 
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            counter <= 0;
            clk_out <= 0; 
        end else if (counter == 49999999) begin
            counter <= 0;
            clk_out <= ~clk_out;  // 每次计数器溢出时，翻转时钟信号
        end else begin
            counter <= counter + 1;
        end
    end
endmodule

