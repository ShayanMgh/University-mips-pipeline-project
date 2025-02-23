module Data_Memory(
    input clk,
    input MemWrite,// If high (1), data is written into memory.
    input MemRead,//If high (1), data is read from memory.
    input [31:0] addr,//The memory address (used as an index).
    input [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] memory[0:63];//64 memory locations, each 32 bits wide
    integer i;
    initial begin
        memory[0] = 32'd0;   // First Fibonacci number: 0
        memory[1] = 32'd1;   // Second Fibonacci number: 1
        for(i=2; i<64; i=i+1)
            memory[i] = 32'd0;
    end
    // Write on clock’s rising edge
    always @(posedge clk) begin
        if(MemWrite)
            memory[addr[31:2]] <= write_data;
    end
    // Read (combinational)
    always @(*) begin
        if(MemRead)
            read_data = memory[addr[31:2]];
        else
            read_data = 32'd0;
    end
endmodule