module MW_WB(
    input clk,
    input reset,
    input MemToReg,
    input RegWrite,
    input [31:0] mem_read_data,
    input [31:0] alu_result,
    input [4:0] write_reg,
    output reg MemToReg_out,
    output reg RegWrite_out,
    output reg [31:0] mem_read_data_out,
    output reg [31:0] alu_result_out,
    output reg [4:0] write_reg_out
);
    always @(posedge clk) begin
        if(reset) begin
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            mem_read_data_out <= 0;
            alu_result_out <= 0;
            write_reg_out <= 0;
        end else begin
            MemToReg_out <= MemToReg;
            RegWrite_out <= RegWrite;
            mem_read_data_out <= mem_read_data;
            alu_result_out <= alu_result;
            write_reg_out <= write_reg;
        end
    end
endmodule
