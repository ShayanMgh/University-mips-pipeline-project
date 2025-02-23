// PR_ID_Dual.v
module PR_ID_Dual(
    input clk,
    input reset,
    input [31:0] pc_in,
    input [31:0] instr1_in,
    input [31:0] instr2_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr1_out,
    output reg [31:0] instr2_out
);
    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 32'd0;
            instr1_out <= 32'd0;
            instr2_out <= 32'd0;
        end else begin
            pc_out <= pc_in;
            instr1_out <= instr1_in;
            instr2_out <= instr2_in;
        end
    end
endmodule
