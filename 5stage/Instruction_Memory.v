module Instruction_Memory(
    input [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] memory[0:63];
    integer i;
    initial begin
        // Instruction 0: lw   $1, 0($0)
        memory[0]  = 32'h8C010000;
        // Instruction 1: lw   $2, 4($0)
        memory[1]  = 32'h8C020004;
        // Instruction 2: nop (stall 1)
        memory[2]  = 32'h00000000;
        // Instruction 3: nop (stall 2)
        memory[3]  = 32'h00000000;
        // Instruction 4: add  $4, $0, $0   => clear loop counter (r4 = 0)
        memory[4]  = 32'h00002020;
        // Instruction 5: addi $5, $0, 8    => set store pointer (r5 = 8)
        memory[5]  = 32'h20050008;
        // Instruction 6: add  $3, $1, $2   => r3 = r1 + r2
        memory[6]  = 32'h00221820;
        // Instruction 7: sw   $3, 0($5)    => store r3 at DM[address in r5]
        memory[7]  = 32'hACA30000;
        // Instruction 8: add  $1, $2, $0    => r1 = r2
        memory[8]  = 32'h00400820;
        // Instruction 9: add  $2, $3, $0    => r2 = r3
        memory[9]  = 32'h00601020;
        // Instruction 10: addi $5, $5, 4    => r5 = r5 + 4 (increment store pointer)
        memory[10] = 32'h20A50004;
        // Instruction 11: addi $4, $4, 1    => r4 = r4 + 1 (increment loop counter)
        memory[11] = 32'h20840001;
        // Instruction 12: addi $7, $0, 10   => r7 = 10 (loop count)
        memory[12] = 32'h2007000A;
        // Instruction 13: beq  $4, $7, 1    => if (r4==r7) branch (offset = 1)
        memory[13] = 32'h10870001;
        // Instruction 14: nop             => branch delay slot
        memory[14] = 32'h00000000;
        // Instruction 15: j    6         => jump back to instruction at addr 6 (loop body)
        memory[15] = 32'h08000006;
        // Instruction 16: nop             => final nop
        memory[16] = 32'h00000000;
        // Fill remaining instructions with nop.
        for(i = 17; i < 64; i = i + 1)
            memory[i] = 32'h00000000;
    end
    // Word addressing: instruction = memory[addr[31:2]]
    assign instruction = memory[addr[31:2]];
endmodule
