// EX/MEM Pipeline Register
module EX_MEM(
    input clk,
    input reset,
    // Control signals
    input MemToReg,
    input RegWrite,
    input MemRead,
    input MemWrite,
    input Branch,
    // Data signals
    input [31:0] branch_target,
    input Zero, //A flag indicating whether ALU result is zero (for branch conditions)
    input [31:0] alu_result,
    input [31:0] read_data2,
    input [4:0] write_reg,
    output reg MemToReg_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg Branch_out,
    output reg [31:0] branch_target_out,
    output reg Zero_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] read_data2_out,
    output reg [4:0] write_reg_out
);
    always @(posedge clk) begin
        if(reset) begin
            MemToReg_out     <= 1'b0;
            RegWrite_out     <= 1'b0;
            MemRead_out      <= 1'b0;
            MemWrite_out     <= 1'b0;
            Branch_out       <= 1'b0;
            branch_target_out<= 32'd0;
            Zero_out         <= 1'b0;
            alu_result_out   <= 32'd0;
            read_data2_out   <= 32'd0;
            write_reg_out    <= 5'd0;
        end else begin
            MemToReg_out     <= MemToReg;
            RegWrite_out     <= RegWrite;
            MemRead_out      <= MemRead;
            MemWrite_out     <= MemWrite;
            Branch_out       <= Branch;
            branch_target_out<= branch_target;
            Zero_out         <= Zero;
            alu_result_out   <= alu_result;
            read_data2_out   <= read_data2;
            write_reg_out    <= write_reg;
        end
    end
endmodule