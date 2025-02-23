`timescale 1ns/1ps
module ID_EX_Dual(
    input clk,
    input reset,
    input [31:0] pc_in,
    input [31:0] decoded1,
    input [31:0] decoded2,
    output reg [31:0] pc_out,
    output reg [31:0] ex_instr1,
    output reg [31:0] ex_instr2
);
    always @(posedge clk) begin
        if(reset) begin
            pc_out    <= 32'd0;
            ex_instr1 <= 32'd0;
            ex_instr2 <= 32'd0;
        end else begin
            pc_out    <= pc_in;
            ex_instr1 <= decoded1;
            ex_instr2 <= decoded2;
        end
    end
endmodule
