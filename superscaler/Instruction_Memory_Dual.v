// Returns two consecutive instructions per fetch (PC increments by 8).
module Instruction_Memory_Dual(
    input [31:0] addr,       // addr must be a multiple of 8
    output [31:0] instr1,
    output [31:0] instr2
);
    reg [31:0] memory[0:127]; // 128-word instruction memory
    integer i;
    initial begin
        // Fill memory with nops.
        for(i = 0; i < 128; i = i + 1)
            memory[i] = 32'h00000000;                   

        // Pair 0 (words 0-1): load initial Fibonacci numbers
        memory[0] = 32'h8C010000;  // lw $1,0($0)
        memory[1] = 32'h8C020004;  // lw $2,4($0)
        // Pair 1 (words 2-3): two nops (stall for load-use)
        memory[2] = 32'h00000000;
        memory[3] = 32'h00000000;
        // Pair 2 (words 4-5): two more nops (total 4 nops)
        memory[4] = 32'h00000000;
        memory[5] = 32'h00000000;
        // Pair 3 (words 6-7): two more nops (total 6 nops)
        memory[6] = 32'h00000000;
        memory[7] = 32'h00000000;
        // Pair 4 (words 8-9): loop initialization
        memory[8]  = 32'h00002020;  // add $4, $0, $0   ; clear loop counter (r4=0)
        memory[9]  = 32'h20050008;  // addi $5, $0, 8    ; set store pointer (r5=8)
        // Pair 5 (words 10-11): loop body, first half
        memory[10] = 32'h00221820;  // add $3, $1, $2   ; r3 = r1 + r2
        memory[11] = 32'hACA30000;  // sw $3, 0($5)     ; store computed term
        // Pair 6 (words 12-13): loop body, second half
        memory[12] = 32'h00400820;  // add $1, $2, $0   ; r1 = r2
        memory[13] = 32'h00601020;  // add $2, $3, $0   ; r2 = r3
        // Pair 7 (words 14-15): update pointer and counter
        memory[14] = 32'h20A50004;  // addi $5, $5, 4   ; increment store pointer
        memory[15] = 32'h20840001;  // addi $4, $4, 1   ; increment loop counter
        // Pair 8 (words 16-17): loop control
        memory[16] = 32'h2007000A;  // addi $7, $0, 10  ; r7 = 10 (loop limit)
        memory[17] = 32'h10870001;  // beq $4, $7, 1    ; branch if (r4==r7)
        // Pair 9 (words 18-19): branch delay and jump
        memory[18] = 32'h00000000;  // nop              ; branch delay slot
        memory[19] = 32'h0800000A;  // j 10             ; jump back to loop body (pair 5)
        // Pair 10 (words 20-21): DONE region (nops)
        memory[20] = 32'h00000000;  // nop
        memory[21] = 32'h00000000;  // nop
        // Fill remaining words with nops.
        for(i = 22; i < 128; i = i + 1)
            memory[i] = 32'h00000000;
    end
    // Word addressing: instr1 is at memory[addr/4] and instr2 at memory[addr/4 + 1]
    assign instr1 = memory[addr[31:2]];
    assign instr2 = memory[addr[31:2] + 1];
endmodule
