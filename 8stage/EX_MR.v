module EX_MR(
    input             clk,
    input             reset,
    // Control signals in
    input             MemToReg_in,
    input             RegWrite_in,
    input             MemRead_in,
    input             MemWrite_in,
    input             Branch_in,
    // Data signals in
    input      [31:0] branch_target_in,
    input             zero_in,
    input      [31:0] alu_result_in,
    input      [31:0] rt_data_in,
    input      [4:0]  write_reg_in,
    // Outputs
    output reg        MemToReg_out,
    output reg        RegWrite_out,
    output reg        MemRead_out,
    output reg        MemWrite_out,
    output reg        Branch_out,
    output reg [31:0] branch_target_out,
    output reg        zero_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] rt_data_out,
    output reg [4:0]  write_reg_out
);
    always @(posedge clk) begin
        if(reset) begin
            MemToReg_out      <= 0;
            RegWrite_out      <= 0;
            MemRead_out       <= 0;
            MemWrite_out      <= 0;
            Branch_out        <= 0;
            branch_target_out <= 32'd0;
            zero_out          <= 1'b0;
            alu_result_out    <= 32'd0;
            rt_data_out       <= 32'd0;
            write_reg_out     <= 5'd0;
        end else begin
            MemToReg_out      <= MemToReg_in;
            RegWrite_out      <= RegWrite_in;
            MemRead_out       <= MemRead_in;
            MemWrite_out      <= MemWrite_in;
            Branch_out        <= Branch_in;
            branch_target_out <= branch_target_in;
            zero_out          <= zero_in;
            alu_result_out    <= alu_result_in;
            rt_data_out       <= rt_data_in;
            write_reg_out     <= write_reg_in;
        end
    end
endmodule
