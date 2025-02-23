module ID_EX(
    input             clk,
    input             reset,
    // Control signals in
    input             RegDst_in,
    input             ALUSrc_in,
    input             MemToReg_in,
    input             RegWrite_in,
    input             MemRead_in,
    input             MemWrite_in,
    input             Branch_in,
    input             Jump_in,
    input      [1:0]  ALUOp_in,
    // Data signals in
    input      [31:0] pc_in,
    input      [31:0] rs_data_in,
    input      [31:0] rt_data_in,
    input      [31:0] sign_ext_imm_in,
    input      [4:0]  rs_in,
    input      [4:0]  rt_in,
    input      [4:0]  rd_in,
    input      [5:0]  funct_in,
    // Control signals out
    output reg        RegDst_out,
    output reg        ALUSrc_out,
    output reg        MemToReg_out,
    output reg        RegWrite_out,
    output reg        MemRead_out,
    output reg        MemWrite_out,
    output reg        Branch_out,
    output reg        Jump_out,
    output reg [1:0]  ALUOp_out,
    // Data signals out
    output reg [31:0] pc_out,
    output reg [31:0] rs_data_out,
    output reg [31:0] rt_data_out,
    output reg [31:0] sign_ext_imm_out,
    output reg [4:0]  rs_out,
    output reg [4:0]  rt_out,
    output reg [4:0]  rd_out,
    output reg [5:0]  funct_out
);
    always @(posedge clk) begin
        if(reset) begin
            RegDst_out       <= 0;
            ALUSrc_out       <= 0;
            MemToReg_out     <= 0;
            RegWrite_out     <= 0;
            MemRead_out      <= 0;
            MemWrite_out     <= 0;
            Branch_out       <= 0;
            Jump_out         <= 0;
            ALUOp_out        <= 2'b00;
            pc_out           <= 32'd0;
            rs_data_out      <= 32'd0;
            rt_data_out      <= 32'd0;
            sign_ext_imm_out <= 32'd0;
            rs_out           <= 5'd0;
            rt_out           <= 5'd0;
            rd_out           <= 5'd0;
            funct_out        <= 6'd0;
        end else begin
            RegDst_out       <= RegDst_in;
            ALUSrc_out       <= ALUSrc_in;
            MemToReg_out     <= MemToReg_in;
            RegWrite_out     <= RegWrite_in;
            MemRead_out      <= MemRead_in;
            MemWrite_out     <= MemWrite_in;
            Branch_out       <= Branch_in;
            Jump_out         <= Jump_in;
            ALUOp_out        <= ALUOp_in;
            pc_out           <= pc_in;
            rs_data_out      <= rs_data_in;
            rt_data_out      <= rt_data_in;
            sign_ext_imm_out <= sign_ext_imm_in;
            rs_out           <= rs_in;
            rt_out           <= rt_in;
            rd_out           <= rd_in;
            funct_out        <= funct_in;
        end
    end
endmodule
