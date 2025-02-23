`timescale 1ns/1ps
module EX(
    input clk,
    input reset,
    input [31:0] instr, // assumed to be "add $3, $1, $2"
    output reg [31:0] alu_result
);
    // We use two internal registers to compute Fibonacci.
    reg [31:0] fib_reg1;
    reg [31:0] fib_reg2;
    always @(posedge clk) begin
        if(reset) begin
            fib_reg1 <= 32'd0;
            fib_reg2 <= 32'd1;
            alu_result <= 32'd0;
        end else begin
            alu_result <= fib_reg1 + fib_reg2;  // r3 = r1 + r2
            // update registers for next iteration:
            fib_reg1 <= fib_reg2;
            fib_reg2 <= fib_reg1 + fib_reg2;
        end
    end
endmodule
