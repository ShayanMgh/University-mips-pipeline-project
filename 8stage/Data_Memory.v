`timescale 1ns / 1ps
module Data_Memory(
    input         clk,
    input         MemWrite,
    input         MemRead,
    input  [31:0] addr,
    input  [31:0] write_data,
    output reg [31:0] read_data
);

    // Define a memory array of 64 words (32 bits each)
    reg [31:0] memory [0:63];
    integer i;
    
    // Initialize memory with the first two Fibonacci numbers
    initial begin
        memory[0] = 32'd0;   // Fibonacci number 0
        memory[1] = 32'd1;   // Fibonacci number 1
        for (i = 2; i < 64; i = i + 1)
            memory[i] = 32'd0;
    end

    // Write operation: on each rising clock edge, if MemWrite is asserted, write the data.
    always @(posedge clk) begin
        if (MemWrite)
            memory[addr[31:2]] <= write_data;
    end

    // Read operation: combinational read from memory when MemRead is asserted.
    always @(*) begin
        if (MemRead)
            read_data = memory[addr[31:2]];
        else
            read_data = 32'd0;
    end

endmodule
