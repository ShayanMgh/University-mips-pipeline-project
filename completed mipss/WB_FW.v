// WB_FW.v
module WB_FW(
    input clk,
    input reset,
    input RegWrite,
    input [31:0] write_back_data,
    input [4:0] write_reg,
    output reg RegWrite_out,
    output reg [31:0] write_back_data_out,
    output reg [4:0] write_reg_out
);
    always @(posedge clk) begin
        if(reset) begin
            RegWrite_out <= 0;
            write_back_data_out <= 0;
            write_reg_out <= 0;
        end else begin
            RegWrite_out <= RegWrite;
            write_back_data_out <= write_back_data;
            write_reg_out <= write_reg;
        end
    end
endmodule
