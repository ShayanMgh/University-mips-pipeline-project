`timescale 1ns/1ps
module EX_Dual(
    input clk,
    input reset,
    input [31:0] instr1_in,  // Lane1 instruction
    input [31:0] instr2_in,  // Lane2 instruction (set to 0 if forced to nop)
    output reg [31:0] alu_out1,  // Result for lane1
    output reg [31:0] alu_out2   // Result for lane2
);


    //assume that if instr1_in is not a nop (nonzero), we compute r3 = r1 + r2.
    //two internal registers to hold the operands for lane1.
    reg [31:0] fib1_lane1;  // simulates register $1
    reg [31:0] fib2_lane1;  // simulates register $2

    // Similarly, we define registers for lane2.
    reg [31:0] fib1_lane2;  // simulates register for lane2 operand
    reg [31:0] fib2_lane2;  // simulates second operand for lane2

    always @(posedge clk) begin
        if (reset) begin
            fib1_lane1 <= 32'd0;
            fib2_lane1 <= 32'd1;
            alu_out1   <= 32'd0;
            fib1_lane2 <= 32'd0;
            fib2_lane2 <= 32'd0;
            alu_out2   <= 32'd0;
        end else begin
            // Check if the lane1 instruction is not a nop.
            //assume a nop is encoded as 32'd0.
            if (instr1_in != 32'd0) begin
                alu_out1 <= fib1_lane1 + fib2_lane1;
                // Update the internal registers for the next cycle.
                fib1_lane1 <= fib2_lane1;
                fib2_lane1 <= fib1_lane1 + fib2_lane1;
            end else begin
                // If it is a nop, hold the previous output.
                alu_out1 <= alu_out1;
            end

            // For lane2, perform a similar operation if the instruction is nonzero.
            if (instr2_in != 32'd0) begin
                alu_out2 <= fib1_lane2 + fib2_lane2;
                fib1_lane2 <= fib2_lane2;
                fib2_lane2 <= fib1_lane2 + fib2_lane2;
            end else begin
                alu_out2 <= 32'd0; // lane2 not used, output remains 0.
            end
        end
    end

endmodule
