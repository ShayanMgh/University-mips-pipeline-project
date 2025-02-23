`timescale 1ns/1ps
module MEM_WB(
    input clk,
    input reset,
    input [31:0] alu_result,
    output reg [31:0] wb_data
);
    always @(posedge clk) begin
        if(reset)
            wb_data <= 32'd0;
        else
            wb_data <= alu_result;
    end
endmodule
