module MW_WB(
    input             clk,
    input             reset,
    // Control in
    input             MemToReg_in,
    input             RegWrite_in,
    // Data in
    input      [31:0] alu_result_in,
    input      [31:0] read_data_in,
    input      [4:0]  write_reg_in,
    // Outputs
    output reg        MemToReg_out,
    output reg        RegWrite_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] read_data_out,
    output reg [4:0]  write_reg_out
);
    always @(posedge clk) begin
        if(reset) begin
            MemToReg_out   <= 0;
            RegWrite_out   <= 0;
            alu_result_out <= 32'd0;
            read_data_out  <= 32'd0;
            write_reg_out  <= 5'd0;
        end else begin
            MemToReg_out   <= MemToReg_in;
            RegWrite_out   <= RegWrite_in;
            alu_result_out <= alu_result_in;
            read_data_out  <= read_data_in;
            write_reg_out  <= write_reg_in;
        end
    end
endmodule