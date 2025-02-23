module ID_EX(
    input clk,
    input reset,
    // Control signals
    input RegDst,
    input ALUSrc,
    input MemToReg,
    input RegWrite,
    input MemRead,
    input MemWrite,
    input Branch,
    input [1:0] ALUOp,
    // Data signals
    input [31:0] pc_in,
    input [31:0] read_data1,
    input [31:0] read_data2,
    input [31:0] sign_ext_imm,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [5:0] funct,//for ALU operations in R-type instructions
    output reg RegDst_out,
    output reg ALUSrc_out,
    output reg MemToReg_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg Branch_out,
    output reg [1:0] ALUOp_out,
    output reg [31:0] pc_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] sign_ext_imm_out,
    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,
    output reg [5:0] funct_out
);
    always @(posedge clk) begin
        if(reset) begin
            RegDst_out       <= 1'b0;
            ALUSrc_out       <= 1'b0;
            MemToReg_out     <= 1'b0;
            RegWrite_out     <= 1'b0;
            MemRead_out      <= 1'b0;
            MemWrite_out     <= 1'b0;
            Branch_out       <= 1'b0;
            ALUOp_out        <= 2'b00;
            pc_out           <= 32'd0;
            read_data1_out   <= 32'd0;
            read_data2_out   <= 32'd0;
            sign_ext_imm_out <= 32'd0;
            rs_out           <= 5'd0;
            rt_out           <= 5'd0;
            rd_out           <= 5'd0;
            funct_out        <= 6'd0;
        end else begin
            RegDst_out       <= RegDst;
            ALUSrc_out       <= ALUSrc;
            MemToReg_out     <= MemToReg;
            RegWrite_out     <= RegWrite;
            MemRead_out      <= MemRead;
            MemWrite_out     <= MemWrite;
            Branch_out       <= Branch;
            ALUOp_out        <= ALUOp;
            pc_out           <= pc_in;
            read_data1_out   <= read_data1;
            read_data2_out   <= read_data2;
            sign_ext_imm_out <= sign_ext_imm;
            rs_out           <= rs;
            rt_out           <= rt;
            rd_out           <= rd;
            funct_out        <= funct;
        end
    end
endmodule