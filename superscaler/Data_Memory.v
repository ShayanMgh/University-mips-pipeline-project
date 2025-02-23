// Data_Memory.v
module Data_Memory(
    input clk,
    input MemWrite,
    input MemRead,
    input [31:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] memory[0:63];
    integer i;
    initial begin
        memory[0] = 32'd0;   // Fibonacci 0
        memory[1] = 32'd1;   // Fibonacci 1
        for(i = 2; i < 64; i = i + 1)
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
endmodule
