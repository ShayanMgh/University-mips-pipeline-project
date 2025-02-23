// MEM/WB Pipeline Register
module MEM_WB(
    input clk,
    input reset,
    // Control signals
    input MemToReg,
    input RegWrite,
    // Data signals
    input [31:0] read_data,
    input [31:0] alu_result,
    input [4:0] write_reg,
    output reg MemToReg_out,
    output reg RegWrite_out,
    output reg [31:0] read_data_out,
    output reg [31:0] alu_result_out,
    output reg [4:0] write_reg_out
);
    always @(posedge clk) begin
        if(reset) begin
            MemToReg_out  <= 1'b0;
            RegWrite_out  <= 1'b0;
            read_data_out <= 32'd0;
            alu_result_out<= 32'd0;
            write_reg_out <= 5'd0;
        end else begin
            MemToReg_out  <= MemToReg;
            RegWrite_out  <= RegWrite;
            read_data_out <= read_data;
            alu_result_out<= alu_result;
            write_reg_out <= write_reg;
        end
    end
endmodule
