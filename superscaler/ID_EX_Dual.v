// ID_EX_Dual.v
module ID_EX_Dual(
    input clk,
    input reset,
    input [31:0] pc_in,
    input [31:0] decoded1_in,
    input [31:0] decoded2_in,
    output reg [31:0] pc_out,
    output reg [31:0] ex_instr1,
    output reg [31:0] ex_instr2
);
    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 0;
            ex_instr1 <= 0;
            ex_instr2 <= 0;
        end else begin
            pc_out <= pc_in;
            ex_instr1 <= decoded1_in;
            ex_instr2 <= decoded2_in;
        end
    end
endmodule
