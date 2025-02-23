// EX_MR.v
module EX_MR(
    input clk,
    input reset,
    input MemToReg,
    input RegWrite,
    input MemRead,
    input MemWrite,
    input Branch,
    input [31:0] alu_result,
    input alu_zero,
    input [31:0] pr_read_data2,
    input [4:0] write_reg,
    input [31:0] branch_target,
    output reg MemToReg_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg Branch_out,
    output reg [31:0] alu_result_out,
    output reg alu_zero_out,
    output reg [31:0] pr_read_data2_out,
    output reg [4:0] write_reg_out,
    output reg [31:0] branch_target_out
);
    always @(posedge clk) begin
        if(reset) begin
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            MemRead_out <= 0;
            MemWrite_out <= 0;
            Branch_out <= 0;
            alu_result_out <= 0;
            alu_zero_out <= 0;
            pr_read_data2_out <= 0;
            write_reg_out <= 0;
            branch_target_out <= 0;
        end else begin
            MemToReg_out <= MemToReg;
            RegWrite_out <= RegWrite;
            MemRead_out <= MemRead;
            MemWrite_out <= MemWrite;
            Branch_out <= Branch;
            alu_result_out <= alu_result;
            alu_zero_out <= alu_zero;
            pr_read_data2_out <= pr_read_data2;
            write_reg_out <= write_reg;
            branch_target_out <= branch_target;
        end
    end
endmodule
