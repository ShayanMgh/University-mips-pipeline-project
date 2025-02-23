// Decodes two instructions and performs a simple dependency check.
// If the second instruction uses the destination register of the first (and that register is not $0),
// then it is converted into a nop.
module ID_Dual(
    input clk,
    input reset,
    input [31:0] pc_in,
    input [31:0] instr1_in,
    input [31:0] instr2_in,
    output reg [31:0] pc_out,
    output reg [31:0] decoded1,
    output reg [31:0] decoded2
);
    // For instr1
    wire [5:0] opcode1 = instr1_in[31:26];
    wire [4:0] rs1     = instr1_in[25:21];
    wire [4:0] rt1     = instr1_in[20:16];
    wire [4:0] rd1     = instr1_in[15:11];
    // Determine destination: if R-type, dest = rd; otherwise, dest = rt.
    wire [4:0] dest1 = (opcode1 == 6'b000000) ? rd1 : rt1;
    // For instr2, extract source registers.
    wire [4:0] rs2 = instr2_in[25:21];
    wire [4:0] rt2 = instr2_in[20:16];
    // Dependency: if instr2 uses dest1.
    wire dependency = (((rs2 == dest1) || (rt2 == dest1)) && (dest1 != 0));
    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 0;
            decoded1 <= 0;
            decoded2 <= 0;
        end else begin
            pc_out <= pc_in;
            decoded1 <= instr1_in;
            if (dependency)
                decoded2 <= 32'h00000000; // Convert to nop if dependency exists.
            else
                decoded2 <= instr2_in;
        end
    end
endmodule
