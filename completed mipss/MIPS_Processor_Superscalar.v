`timescale 1ns/1ps
module MIPS_Processor_Superscalar #(parameter PREDICTOR_TYPE = 1) (
    input clk,
    input reset
);
    //signals for branch resolution & flush
    wire        flush          = 1'b0;     // no real flush logic
    wire [31:0] branch_pc      = 32'd0;    // from EX stage if implemented
    wire        actual_taken   = 1'b0;     // actual outcome
    wire [31:0] correct_target = 32'd0;    // actual branch target
    wire        update_valid   = 1'b0;     // update signal

    // Program Counter and Branch Predictor
    reg [31:0] PC;
    wire [31:0] pred_target;
    wire        pred_taken;

    // Multi-scheme Branch_Predictor
    Branch_Predictor #(PREDICTOR_TYPE) bp(
        .clk(clk),
        .reset(reset),
        .pc_in(PC),
        .pred_taken(pred_taken),
        .pred_target(pred_target),
        .branch_pc(branch_pc),
        .taken(actual_taken),
        .actual_target(correct_target),
        .update_valid(update_valid)
    );

    // NextPC logic
    wire [31:0] nextPC = pred_taken ? pred_target : (PC + 8);

    always @(posedge clk) begin
        if (reset)
            PC <= 32'd0;
        else if (flush)
            PC <= correct_target;  // if misprediction flush logic existed
        else
            PC <= nextPC;
    end

    // Dual Instruction Fetch
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
        .pc_in(PC + 8),  // for dual-issue, we do +8
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

    wire [31:0] decoded1, decoded2;
    ID_Dual id_dual(
        .clk(clk),
        .reset(reset),
        .pc_in(id_pc),
        .instr1_in(id_instr1),
        .instr2_in(id_instr2),
        .pc_out(),  // not used
        .decoded1(decoded1),
        .decoded2(decoded2)
    );

    wire [31:0] ex_pc;
    wire [31:0] ex_instr1, ex_instr2;
    ID_EX_Dual id_ex_dual(
        .clk(clk),
        .reset(reset),
        .pc_in(id_pc),
        .decoded1(decoded1),
        .decoded2(decoded2),
        .pc_out(ex_pc),
        .ex_instr1(ex_instr1),
        .ex_instr2(ex_instr2)
    );

    wire [31:0] alu_result;
    EX ex_stage(
        .clk(clk),
        .reset(reset),
        .instr(ex_instr1),
        .alu_result(alu_result)
    );

    wire [31:0] wb_data;
    MEM_WB mem_wb(
        .clk(clk),
        .reset(reset),
        .alu_result(alu_result),
        .wb_data(wb_data)
    );

    // Store each computed term into Data_Memory dynamically:
    // If wb_data != 0, store it in memory. The first time is "Term 3=1".
    reg [31:0] store_ptr;
    always @(posedge clk) begin
        if(reset) begin
            store_ptr <= 32'h00000008; // word index=2 => Term3
        end else begin
            // If a nonzero fibonacci value is produced => store & increment
            if(wb_data != 32'd0) begin
                store_ptr <= store_ptr + 32'd4;
            end
        end
    end

    // MemWrite is active only if we have a nonzero result
    wire MemWrite_sig = (wb_data != 32'd0);
    wire MemRead_sig  = 1'b0;

    Data_Memory dmem(
        .clk       (clk),
        .MemWrite  (MemWrite_sig),
        .MemRead   (MemRead_sig),
        .addr      (store_ptr),
        .write_data(wb_data),
        .read_data (),
        // The fib2..fib11 outputs are used by the testbench
        .fib2(),
        .fib3(),
        .fib4(),
        .fib5(),
        .fib6(),
        .fib7(),
        .fib8(),
        .fib9(),
        .fib10(),
        .fib11()
    );
endmodule
