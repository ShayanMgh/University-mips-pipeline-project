module Instruction_Memory(
    input [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] memory[0:63];  // 64-word instruction memory
    integer i;
    initial begin
        // Fill all memory words with nops.
        for(i = 0; i < 64; i = i + 1)
            memory[i] = 32'h00000000;
            
        // --- Load initial Fibonacci numbers ---
        // Instruction 0: lw   $1, 0($0)
        memory[0] = 32'h8C010000;
        // Instruction 1: lw   $2, 4($0)
        memory[1] = 32'h8C020004;
        
        // --- Insert extra nops to allow loaded values to propagate in an 8-stage pipeline ---
        memory[2] = 32'h00000000; // nop
        memory[3] = 32'h00000000; // nop
        memory[4] = 32'h00000000; // nop
        memory[5] = 32'h00000000; // nop
        memory[6] = 32'h00000000; // nop
        memory[7] = 32'h00000000; // nop
        
        // --- Loop initialization ---
        // Instruction 8: add  $4, $0, $0    => clear loop counter (r4 = 0)
        memory[8] = 32'h00002020;
        // Instruction 9: addi $5, $0, 8     => set store pointer (r5 = 8)
        memory[9] = 32'h20050008;
        
        // --- Loop body (each iteration computes one Fibonacci term) ---
        // Instruction 10: add  $3, $1, $2   => compute next term: r3 = r1 + r2
        memory[10] = 32'h00221820;
        // Instruction 11: sw   $3, 0($5)    => store r3 into Data_Memory at address in r5
        memory[11] = 32'hACA30000;
        // Instruction 12: add  $1, $2, $0    => shift: r1 = r2
        memory[12] = 32'h00400820;
        // Instruction 13: add  $2, $3, $0    => shift: r2 = r3
        memory[13] = 32'h00601020;
        // Instruction 14: addi $5, $5, 4    => increment store pointer (r5 = r5 + 4)
        memory[14] = 32'h20A50004;
        // Instruction 15: addi $4, $4, 1    => increment loop counter (r4 = r4 + 1)
        memory[15] = 32'h20840001;
        // Instruction 16: addi $7, $0, 10   => load loop limit (r7 = 10)
        memory[16] = 32'h2007000A;
        
        // --- Loop control ---
        // If loop counter equals 10, branch to DONE region.
        // Instruction 17: beq  $4, $7, 5    => branch offset 5: if (r4==10), then PC = PC+4+20 = jump to instruction 23.
        memory[17] = 32'h10870005;
        // Instruction 18: nop              => branch delay slot
        memory[18] = 32'h00000000;
        // Otherwise, continue loop:
        // Instruction 19: j    10          => jump back to loop body at instruction 10
        memory[19] = 32'h0800000A;
        
        // --- DONE region ---
        // Instructions 20-23: nops (halt)
        memory[20] = 32'h00000000;
        memory[21] = 32'h00000000;
        memory[22] = 32'h00000000;
        memory[23] = 32'h00000000;
        // Remaining instructions are nops.
        for(i = 24; i < 64; i = i + 1)
            memory[i] = 32'h00000000;
    end
    // Word addressing: instruction = memory[addr[31:2]]
    assign instruction = memory[addr[31:2]];
endmodule
