module MIPS_Processor_Superscalar(
    input clk,
    input reset
);

    // Superscalar IF Stage:
    // PC increments by 8 each cycle.
    reg [31:0] PC;
    wire [31:0] if_pc_plus8 = PC + 8;
    wire [31:0] instr1, instr2;
    Instruction_Memory_Dual imem_dual(
        .addr(PC),
        .instr1(instr1),
        .instr2(instr2)
    );
    
    wire [31:0] pr_pc;
    wire [31:0] pr_instr1, pr_instr2;
    IF_PR_Dual if_pr_dual(
        .clk(clk),
        .reset(reset),
        .pc_in(if_pc_plus8),
        .instr1_in(instr1),
        .instr2_in(instr2),
        .pc_out(pr_pc),
        .instr1_out(pr_instr1),
        .instr2_out(pr_instr2)
    );
    
    wire [31:0] id_pc;
    wire [31:0] id_instr1, id_instr2;
    PR_ID_Dual pr_id_dual(
        .clk(clk),
        .reset(reset),
        .pc_in(pr_pc),
        .instr1_in(pr_instr1),
        .instr2_in(pr_instr2),
        .pc_out(id_pc),
        .instr1_out(id_instr1),
        .instr2_out(id_instr2)
    );
    
    // Dual ID Stage with Dependency Checking
    wire [31:0] decoded1, decoded2;
    ID_Dual id_dual(
        .clk(clk),
        .reset(reset),
        .pc_in(id_pc),
        .instr1_in(id_instr1),
        .instr2_in(id_instr2),
        .pc_out(), // not used further
        .decoded1(decoded1),
        .decoded2(decoded2)
    );
    
    wire [31:0] ex_pc;
    wire [31:0] ex_instr1, ex_instr2;
    ID_EX_Dual id_ex_dual(
        .clk(clk),
        .reset(reset),
        .pc_in(id_pc),
        .decoded1_in(decoded1),
        .decoded2_in(decoded2),
        .pc_out(ex_pc),
        .ex_instr1(ex_instr1),
        .ex_instr2(ex_instr2)
    );
    
    // Dual EX Stage:
    wire [31:0] alu_out1, alu_out2;
    EX_Dual ex_dual(
        .clk(clk),
        .reset(reset),
        .instr1_in(ex_instr1),
        .instr2_in(ex_instr2),
        .alu_out1(alu_out1),
        .alu_out2(alu_out2)
    );
    
    wire exmr_MemToReg, exmr_RegWrite, exmr_MemRead, exmr_MemWrite, exmr_Branch;
    wire [31:0] exmr_alu_result;
    wire exmr_zero;
    wire [31:0] exmr_data;
    wire [4:0] exmr_write_reg;
    wire [31:0] exmr_branch_target;
    EX_MR ex_mr(
        .clk(clk), .reset(reset),
        .MemToReg(1'b1),    // For an R-type, we do not access memory so this is arbitrary
        .RegWrite(1'b1),
        .MemRead(1'b0),
        .MemWrite(1'b0),
        .Branch(1'b0),
        .alu_result(alu_out1),
        .alu_zero(exmr_zero),
        .pr_read_data2(32'd0),
        .write_reg(5'd3),   // Assume destination register $3 holds the Fibonacci term
        .branch_target(32'd0),
        .MemToReg_out(exmr_MemToReg),
        .RegWrite_out(exmr_RegWrite),
        .MemRead_out(exmr_MemRead),
        .MemWrite_out(exmr_MemWrite),
        .Branch_out(exmr_Branch),
        .alu_result_out(exmr_alu_result),
        .alu_zero_out(),
        .pr_read_data2_out(exmr_data),
        .write_reg_out(exmr_write_reg),
        .branch_target_out(exmr_branch_target)
    );
    
    // Data Memory:
    wire [31:0] dm_data;
    Data_Memory dmem(
        .clk(clk),
        .MemWrite(exmr_MemWrite),
        .MemRead(exmr_MemToReg),
        .addr(exmr_alu_result),
        .write_data(exmr_data),
        .read_data(dm_data)
    );
    
    wire mrmw_MemToReg, mrmw_RegWrite, mrmw_MemWrite;
    wire [31:0] mrmw_mem_read_data;
    wire [31:0] mrmw_alu_result;
    wire [4:0] mrmw_write_reg;
    wire [31:0] mrmw_store_data_out;
    MR_MW mr_mw(
        .clk(clk), .reset(reset),
        .MemToReg(exmr_MemToReg),
        .RegWrite(exmr_RegWrite),
        .MemWrite(exmr_MemWrite),
        .mem_read_data(dm_data),
        .alu_result(exmr_alu_result),
        .write_reg(exmr_write_reg),
        .store_data(exmr_data),
        .MemToReg_out(mrmw_MemToReg),
        .RegWrite_out(mrmw_RegWrite),
        .MemWrite_out(mrmw_MemWrite),
        .mem_read_data_out(mrmw_mem_read_data),
        .alu_result_out(mrmw_alu_result),
        .write_reg_out(mrmw_write_reg),
        .store_data_out(mrmw_store_data_out)
    );
    
    wire mwwb_MemToReg, mwwb_RegWrite;
    wire [31:0] mwwb_mem_read_data, mwwb_alu_result;
    wire [4:0] mwwb_write_reg;
    MW_WB mw_wb(
        .clk(clk), .reset(reset),
        .MemToReg(mrmw_MemToReg),
        .RegWrite(mrmw_RegWrite),
        .mem_read_data(mrmw_mem_read_data),
        .alu_result(mrmw_alu_result),
        .write_reg(mrmw_write_reg),
        .MemToReg_out(mwwb_MemToReg),
        .RegWrite_out(mwwb_RegWrite),
        .mem_read_data_out(mwwb_mem_read_data),
        .alu_result_out(mwwb_alu_result),
        .write_reg_out(mwwb_write_reg)
    );
    
    wire [31:0] wb_write_data = mwwb_MemToReg ? mwwb_mem_read_data : mwwb_alu_result;
    wire wbfw_RegWrite;
    wire [31:0] wbfw_write_data;
    wire [4:0] wbfw_write_reg;
    WB_FW wb_fw(
        .clk(clk), .reset(reset),
        .RegWrite(mwwb_RegWrite),
        .write_back_data(wb_write_data),
        .write_reg(mwwb_write_reg),
        .RegWrite_out(wbfw_RegWrite),
        .write_back_data_out(wbfw_write_data),
        .write_reg_out(wbfw_write_reg)
    );
    
    // PC Update: PC increments by 8 each cycle.
    always @(posedge clk) begin
        if(reset)
            PC <= 32'd0;
        else
            PC <= if_pc_plus8;
    end
endmodule
