`timescale 1ns/1ps
module Data_Memory(
    input clk,
    input MemWrite,
    input MemRead,
    input [31:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data,
    output [31:0] fib2,
    output [31:0] fib3,
    output [31:0] fib4,
    output [31:0] fib5,
    output [31:0] fib6,
    output [31:0] fib7,
    output [31:0] fib8,
    output [31:0] fib9,
    output [31:0] fib10,
    output [31:0] fib11
    
);
    reg [31:0] memory[0:63];
    integer i;
    initial begin
        memory[0] = 32'd0;   // Fibonacci seed 0
        memory[1] = 32'd1;   // Fibonacci seed 1
        for(i=2; i<64; i=i+1)
            memory[i] = 32'd0;
    end
    always @(posedge clk) begin
        if(MemWrite)
            memory[addr[31:2]] <= write_data;
    end
    always @(*) begin
        if(MemRead)
            read_data = memory[addr[31:2]];
        else
            read_data = 32'd0;
    end
    // Export computed Fibonacci terms (assume stored from word index 2 upward)
    assign fib2  = memory[2];
    assign fib3  = memory[3];
    assign fib4  = memory[4];
    assign fib5  = memory[5];
    assign fib6  = memory[6];
    assign fib7  = memory[7];
    assign fib8  = memory[8];
    assign fib9  = memory[9];
    assign fib10 = memory[10];
    assign fib11 = memory[11];
endmodule
