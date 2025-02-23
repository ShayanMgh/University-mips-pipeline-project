module MIPS_Processor(
    input clk,
    input reset
);
    // Program Counter
    reg [31:0] PC;
    
    // IF Stage
    wire [31:0] IF_instruction;
    wire [31:0] IF_pc_plus4 = PC + 4;
    
    Instruction_Memory imem(
        .addr(PC),
        .instruction(IF_instruction)
    );
    
    // IF/ID Pipeline Register
    wire [31:0] IF_ID_instr, IF_ID_pc;
    IF_ID if_id_reg(
        .clk(clk),
        .reset(reset),
        .pc_in(IF_pc_plus4),
        .instr_in(IF_instruction),
        .pc_out(IF_ID_pc),
        .instr_out(IF_ID_instr)
    );
    
    // ID Stage: split instruction fields
    wire [5:0] opcode = IF_ID_instr[31:26];
    wire [4:0] rs     = IF_ID_instr[25:21];
    wire [4:0] rt     = IF_ID_instr[20:16];
    wire [4:0] rd     = IF_ID_instr[15:11];
    wire [5:0] funct  = IF_ID_instr[5:0];
    wire [15:0] immediate = IF_ID_instr[15:0];
    wire [31:0] sign_ext_imm = {{16{immediate[15]}}, immediate};
    
    // Control Unit
    wire RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump;
    wire [1:0] ALUOp;
    Control_Unit ctrl(
        .opcode(opcode),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );
    
    // Register File (writes happen in WB stage; note the WB signals are defined later)
    wire [31:0] reg_read_data1, reg_read_data2;
    // WB stage outputs (declared later in MEM/WB)
    wire [4:0] MEM_WB_write_reg;
    wire MEM_WB_RegWrite;
    wire [31:0] MEM_WB_result;
    Register_File rf(
        .clk(clk),
        .RegWrite(MEM_WB_RegWrite),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(MEM_WB_write_reg),
        .write_data(MEM_WB_result),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );
    
    // ID/EX Pipeline Register
    wire ID_EX_RegDst, ID_EX_ALUSrc, ID_EX_MemToReg, ID_EX_RegWrite;
    wire ID_EX_MemRead, ID_EX_MemWrite, ID_EX_Branch;
    wire [1:0] ID_EX_ALUOp;
    wire [31:0] ID_EX_pc, ID_EX_read_data1, ID_EX_read_data2, ID_EX_sign_ext_imm;
    wire [4:0] ID_EX_rs, ID_EX_rt, ID_EX_rd;
    wire [5:0] ID_EX_funct;
    ID_EX id_ex_reg(
        .clk(clk),
        .reset(reset),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUOp(ALUOp),
        .pc_in(IF_ID_pc),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2),
        .sign_ext_imm(sign_ext_imm),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .funct(funct),
        .RegDst_out(ID_EX_RegDst),
        .ALUSrc_out(ID_EX_ALUSrc),
        .MemToReg_out(ID_EX_MemToReg),
        .RegWrite_out(ID_EX_RegWrite),
        .MemRead_out(ID_EX_MemRead),
        .MemWrite_out(ID_EX_MemWrite),
        .Branch_out(ID_EX_Branch),
        .ALUOp_out(ID_EX_ALUOp),
        .pc_out(ID_EX_pc),
        .read_data1_out(ID_EX_read_data1),
        .read_data2_out(ID_EX_read_data2),
        .sign_ext_imm_out(ID_EX_sign_ext_imm),
        .rs_out(ID_EX_rs),
        .rt_out(ID_EX_rt),
        .rd_out(ID_EX_rd),
        .funct_out(ID_EX_funct)
    );
    
    // EX Stage:
    // Select second ALU operand based on ALUSrc.
    wire [31:0] alu_operand2 = ID_EX_ALUSrc ? ID_EX_sign_ext_imm : ID_EX_read_data2;
    
    // ALU Control
    wire [3:0] ALUControl;
    ALU_Control alu_ctrl(
        .ALUOp(ID_EX_ALUOp),
        .funct(ID_EX_funct),
        .ALUControl(ALUControl)
    );
    
    // ALU computes result (for simplicity no forwarding multiplexers are inserted here)
    wire [31:0] alu_result;
    wire alu_zero;
    ALU alu(
        .A(ID_EX_read_data1),
        .B(alu_operand2),
        .ALUControl(ALUControl),
        .Result(alu_result),
        .Zero(alu_zero)
    );
    
    // Determine destination register in EX stage
    wire [4:0] ex_write_reg = ID_EX_RegDst ? ID_EX_rd : ID_EX_rt;
    
    // Compute branch target address
    wire [31:0] branch_target = ID_EX_pc + (ID_EX_sign_ext_imm << 2);
    
    // EX/MEM Pipeline Register
    wire EX_MEM_MemToReg, EX_MEM_RegWrite, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_Branch;
    wire [31:0] EX_MEM_branch_target, EX_MEM_alu_result, EX_MEM_read_data2;
    wire [4:0] EX_MEM_write_reg;
    EX_MEM ex_mem_reg(
        .clk(clk),
        .reset(reset),
        .MemToReg(ID_EX_MemToReg),
        .RegWrite(ID_EX_RegWrite),
        .MemRead(ID_EX_MemRead),
        .MemWrite(ID_EX_MemWrite),
        .Branch(ID_EX_Branch),
        .branch_target(branch_target),
        .Zero(alu_zero),
        .alu_result(alu_result),
        .read_data2(ID_EX_read_data2),
        .write_reg(ex_write_reg),
        .MemToReg_out(EX_MEM_MemToReg),
        .RegWrite_out(EX_MEM_RegWrite),
        .MemRead_out(EX_MEM_MemRead),
        .MemWrite_out(EX_MEM_MemWrite),
        .Branch_out(EX_MEM_Branch),
        .branch_target_out(EX_MEM_branch_target),
        .Zero_out(), // not used further
        .alu_result_out(EX_MEM_alu_result),
        .read_data2_out(EX_MEM_read_data2),
        .write_reg_out(EX_MEM_write_reg)
    );
    
    // MEM Stage: Data Memory access
    wire [31:0] dmem_read_data;
    Data_Memory dmem(
        .clk(clk),
        .MemWrite(EX_MEM_MemWrite),
        .MemRead(EX_MEM_MemRead),
        .addr(EX_MEM_alu_result),
        .write_data(EX_MEM_read_data2),
        .read_data(dmem_read_data)
    );
    
    // MEM/WB Pipeline Register
    wire MEM_WB_MemToReg;
    wire [31:0] MEM_WB_read_data, MEM_WB_alu_result;
    
    MEM_WB mem_wb_reg(
        .clk(clk),
        .reset(reset),
        .MemToReg(EX_MEM_MemToReg),
        .RegWrite(EX_MEM_RegWrite),
        .read_data(dmem_read_data),
        .alu_result(EX_MEM_alu_result),
        .write_reg(EX_MEM_write_reg),
        .MemToReg_out(MEM_WB_MemToReg),
        .RegWrite_out(MEM_WB_RegWrite), // Uses the earlier declaration.
        .read_data_out(MEM_WB_read_data),
        .alu_result_out(MEM_WB_alu_result),
        .write_reg_out(MEM_WB_write_reg)
    );
    
    // WB Stage: Choose between memory data and ALU result
    assign MEM_WB_result = MEM_WB_MemToReg ? MEM_WB_read_data : MEM_WB_alu_result;
    
    // PC update logic (simplified: if branch taken or jump then update PC, else pc+4)
    always @(posedge clk) begin
        if(reset)
            PC <= 32'd0;
        else begin
            if(EX_MEM_Branch && alu_zero)
                PC <= EX_MEM_branch_target;
            else if(Jump)
                PC <= {IF_ID_pc[31:28], IF_ID_instr[25:0], 2'b00};
            else
                PC <= IF_pc_plus4;
        end
    end
endmodule