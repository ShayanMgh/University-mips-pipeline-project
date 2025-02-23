module MIPS_Processor_8Stage(
    input clk,
    input reset
);
    //--- Program Counter & IF Stage ---
    reg [31:0] PC;
    wire [31:0] IF_pc_plus4 = PC + 4;
    wire [31:0] IF_instruction;

    Instruction_Memory imem(
        .addr(PC),
        .instruction(IF_instruction)
    );

    // PC update (simplified: always PC+4)
    always @(posedge clk) begin
        if(reset)
            PC <= 32'd0;
        else
            PC <= IF_pc_plus4;
    end

    wire [31:0] IF_PR_pc, IF_PR_instruction;
    IF_PR if_pr_reg(
        .clk(clk),
        .reset(reset),
        .pc_in(IF_pc_plus4),
        .instr_in(IF_instruction),
        .pc_out(IF_PR_pc),
        .instr_out(IF_PR_instruction)
    );

    // PR Stage (Register Read)
    wire [4:0] pr_rs = IF_PR_instruction[25:21];
    wire [4:0] pr_rt = IF_PR_instruction[20:16];
    wire [31:0] pr_rs_data, pr_rt_data;

    Register_File rf(
        .clk(clk),
        .RegWrite(MEM_WB_RegWrite),     // from WB/FW stage
        .read_reg1(pr_rs),
        .read_reg2(pr_rt),
        .write_reg(MEM_WB_write_reg),   // must be 5 bits
        .write_data(MEM_WB_result),     // 32 bits
        .read_data1(pr_rs_data),
        .read_data2(pr_rt_data)
    );

    wire [31:0] PR_ID_rs_data, PR_ID_rt_data, PR_ID_instr, PR_ID_pc;
    PR_ID pr_id_reg(
        .clk(clk),
        .reset(reset),
        .rs_data_in(pr_rs_data),
        .rt_data_in(pr_rt_data),
        .instr_in(IF_PR_instruction),
        .pc_in(IF_PR_pc),
        .rs_data_out(PR_ID_rs_data),
        .rt_data_out(PR_ID_rt_data),
        .instr_out(PR_ID_instr),
        .pc_out(PR_ID_pc)
    );

    // ID Stage (Decode)
    wire [5:0] opcode = PR_ID_instr[31:26];
    wire [4:0] id_rs  = PR_ID_instr[25:21];
    wire [4:0] id_rt  = PR_ID_instr[20:16];
    wire [4:0] id_rd  = PR_ID_instr[15:11];
    wire [5:0] id_funct = PR_ID_instr[5:0];
    wire [15:0] id_immediate = PR_ID_instr[15:0];
    wire [31:0] sign_ext_imm = {{16{id_immediate[15]}}, id_immediate};

    // Control signals from ID
    wire ID_RegDst, ID_ALUSrc, ID_MemToReg, ID_RegWrite;
    wire ID_MemRead, ID_MemWrite, ID_Branch, ID_Jump;
    wire [1:0] ID_ALUOp;
    Control_Unit ctrl(
        .opcode(opcode),
        .RegDst(ID_RegDst),
        .ALUSrc(ID_ALUSrc),
        .MemToReg(ID_MemToReg),
        .RegWrite(ID_RegWrite),
        .MemRead(ID_MemRead),
        .MemWrite(ID_MemWrite),
        .Branch(ID_Branch),
        .Jump(ID_Jump),
        .ALUOp(ID_ALUOp)
    );

    wire EX_RegDst, EX_ALUSrc, EX_MemToReg, EX_RegWrite;
    wire EX_MemRead, EX_MemWrite, EX_Branch, EX_Jump;
    wire [1:0] EX_ALUOp;
    wire [31:0] EX_pc, EX_rs_data, EX_rt_data, EX_sign_ext_imm;
    wire [4:0] EX_rs, EX_rt, EX_rd;
    wire [5:0] EX_funct;
    ID_EX id_ex_reg(
        .clk(clk),
        .reset(reset),
        .RegDst_in(ID_RegDst),
        .ALUSrc_in(ID_ALUSrc),
        .MemToReg_in(ID_MemToReg),
        .RegWrite_in(ID_RegWrite),
        .MemRead_in(ID_MemRead),
        .MemWrite_in(ID_MemWrite),
        .Branch_in(ID_Branch),
        .Jump_in(ID_Jump),
        .ALUOp_in(ID_ALUOp),
        .pc_in(PR_ID_pc),
        .rs_data_in(PR_ID_rs_data),
        .rt_data_in(PR_ID_rt_data),
        .sign_ext_imm_in(sign_ext_imm),
        .rs_in(id_rs),
        .rt_in(id_rt),
        .rd_in(id_rd),
        .funct_in(id_funct),
        .RegDst_out(EX_RegDst),
        .ALUSrc_out(EX_ALUSrc),
        .MemToReg_out(EX_MemToReg),
        .RegWrite_out(EX_RegWrite),
        .MemRead_out(EX_MemRead),
        .MemWrite_out(EX_MemWrite),
        .Branch_out(EX_Branch),
        .Jump_out(EX_Jump),
        .ALUOp_out(EX_ALUOp),
        .pc_out(EX_pc),
        .rs_data_out(EX_rs_data),
        .rt_data_out(EX_rt_data),
        .sign_ext_imm_out(EX_sign_ext_imm),
        .rs_out(EX_rs),
        .rt_out(EX_rt),
        .rd_out(EX_rd),
        .funct_out(EX_funct)
    );

    // EX Stage (ALU)
    wire [3:0] EX_ALUControl;
    ALU_Control alu_ctrl(
        .ALUOp(EX_ALUOp),
        .funct(EX_funct),
        .ALUControl(EX_ALUControl)
    );
    wire [31:0] alu_operand2 = (EX_ALUSrc) ? EX_sign_ext_imm : EX_rt_data;
    wire [31:0] alu_result;
    wire        alu_zero;
    ALU alu(
        .A(EX_rs_data),
        .B(alu_operand2),
        .ALUControl(EX_ALUControl),
        .Result(alu_result),
        .Zero(alu_zero)
    );
    wire [4:0] ex_write_reg = (EX_RegDst) ? EX_rd : EX_rt;
    wire [31:0] branch_target = EX_pc + (EX_sign_ext_imm << 2);

    wire MR_MemToReg, MR_RegWrite, MR_MemRead, MR_MemWrite, MR_Branch;
    wire [31:0] MR_branch_target, MR_alu_result;
    wire [31:0] MR_rt_data;
    wire [4:0]  MR_write_reg;
    wire        MR_zero;
    EX_MR ex_mr_reg(
        .clk(clk),
        .reset(reset),
        .MemToReg_in(EX_MemToReg),
        .RegWrite_in(EX_RegWrite),
        .MemRead_in(EX_MemRead),
        .MemWrite_in(EX_MemWrite),
        .Branch_in(EX_Branch),
        .branch_target_in(branch_target),
        .zero_in(alu_zero),
        .alu_result_in(alu_result),
        .rt_data_in(EX_rt_data),
        .write_reg_in(ex_write_reg),
        .MemToReg_out(MR_MemToReg),
        .RegWrite_out(MR_RegWrite),
        .MemRead_out(MR_MemRead),
        .MemWrite_out(MR_MemWrite),
        .Branch_out(MR_Branch),
        .branch_target_out(MR_branch_target),
        .zero_out(MR_zero),
        .alu_result_out(MR_alu_result),
        .rt_data_out(MR_rt_data),
        .write_reg_out(MR_write_reg)
    );

    // MR Stage (Memory Read)
    wire [31:0] mr_read_data;
    Data_Memory dmem(
        .clk(clk),
        .MemWrite(1'b0),
        .MemRead(MR_MemRead),
        .addr(MR_alu_result),
        .write_data(32'b0),
        .read_data(mr_read_data)
    );

    wire MW_MemToReg, MW_RegWrite, MW_MemRead, MW_MemWrite;
    wire [31:0] MW_alu_result, MW_read_data, MW_rt_data;
    wire [4:0]  MW_write_reg;
    MR_MW mr_mw_reg(
        .clk(clk),
        .reset(reset),
        .MemToReg_in(MR_MemToReg),
        .RegWrite_in(MR_RegWrite),
        .MemRead_in(MR_MemRead),
        .MemWrite_in(MR_MemWrite),
        .alu_result_in(MR_alu_result),
        .read_data_in(mr_read_data),
        .rt_data_in(MR_rt_data),
        .write_reg_in(MR_write_reg),
        .MemToReg_out(MW_MemToReg),
        .RegWrite_out(MW_RegWrite),
        .MemRead_out(MW_MemRead),
        .MemWrite_out(MW_MemWrite),
        .alu_result_out(MW_alu_result),
        .read_data_out(MW_read_data),
        .rt_data_out(MW_rt_data),
        .write_reg_out(MW_write_reg)
    );

    // MW Stage (Memory Write)
    wire [31:0] dummy_read_unused;
    Data_Memory dmem_write_port(
        .clk(clk),
        .MemWrite(MW_MemWrite),
        .MemRead(1'b0),
        .addr(MW_alu_result),
        .write_data(MW_rt_data),
        .read_data(dummy_read_unused)
    );

    wire WB_MemToReg, WB_RegWrite;
    wire [31:0] WB_alu_result, WB_read_data;
    wire [4:0]  WB_write_reg;
    MW_WB mw_wb_reg(
        .clk(clk),
        .reset(reset),
        .MemToReg_in(MW_MemToReg),
        .RegWrite_in(MW_RegWrite),
        .alu_result_in(MW_alu_result),
        .read_data_in(MW_read_data),
        .write_reg_in(MW_write_reg),
        .MemToReg_out(WB_MemToReg),
        .RegWrite_out(WB_RegWrite),
        .alu_result_out(WB_alu_result),
        .read_data_out(WB_read_data),
        .write_reg_out(WB_write_reg)
    );

    // WB Stage (Write Back)
    // Select between memory read and ALU result
    wire [31:0] MEM_WB_result_internal = (WB_MemToReg) ? WB_read_data : WB_alu_result;
    // Forwarding through a separate stage (WB/FW)
    wire [4:0]  FW_write_reg;
    wire [31:0] FW_write_data;
    wire        FW_regwrite;
    WB_FW wb_fw_reg(
        .clk(clk),
        .reset(reset),
        .write_reg_in(WB_write_reg),
        .wb_data_in(MEM_WB_result_internal),
        .wb_regwrite_in(WB_RegWrite),
        .write_reg_out(FW_write_reg),
        .wb_data_out(FW_write_data),
        .wb_regwrite_out(FW_regwrite)
    );

    wire MEM_WB_RegWrite;
    wire [4:0] MEM_WB_write_reg;
    wire [31:0] MEM_WB_result;
    assign MEM_WB_RegWrite  = FW_regwrite;
    assign MEM_WB_write_reg = FW_write_reg;
    assign MEM_WB_result    = FW_write_data;

endmodule