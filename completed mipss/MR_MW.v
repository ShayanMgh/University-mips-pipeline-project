// MR_MW.v
module MR_MW(
    input clk,
    input reset,
    input MemToReg,
    input RegWrite,
    input MemWrite,
    input [31:0] mem_read_data,
    input [31:0] alu_result,
    input [4:0] write_reg,
    input [31:0] store_data,
    output reg MemToReg_out,
    output reg RegWrite_out,
    output reg MemWrite_out,
    output reg [31:0] mem_read_data_out,
    output reg [31:0] alu_result_out,
    output reg [4:0] write_reg_out,
    output reg [31:0] store_data_out
);
    always @(posedge clk) begin
        if(reset) begin
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            mem_read_data_out <= 0;
            alu_result_out <= 0;
            write_reg_out <= 0;
            store_data_out <= 0;
        end else begin
            MemToReg_out <= MemToReg;
            RegWrite_out <= RegWrite;
            MemWrite_out <= MemWrite;
            mem_read_data_out <= mem_read_data;
            alu_result_out <= alu_result;
            write_reg_out <= write_reg;
            store_data_out <= store_data;
        end
    end
endmodule
