module Register_File(
    input clk,
    input RegWrite,
    input [4:0] read_reg1,//first operand
    input [4:0] read_reg2,//second operand
    input [4:0] write_reg,//Register address to write data
    input [31:0] write_data,//Data to be written to write_reg
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] registers[31:0];
    integer i;
    initial begin
        for(i=0; i<32; i=i+1)
            registers[i] = 32'd0;
    end

    // If a register is being written and read in the same cycle,
    // forward the new value; otherwise, return the stored value.
    assign read_data1 = (RegWrite && (read_reg1 == write_reg) && (write_reg != 0))
                           ? write_data : registers[read_reg1];
    assign read_data2 = (RegWrite && (read_reg2 == write_reg) && (write_reg != 0))
                           ? write_data : registers[read_reg2];
    //if RegWrite is high and the write register is not zero, update the register with write_data
    always @(posedge clk) begin
        if (RegWrite && (write_reg != 0))
            registers[write_reg] <= write_data;
    end
endmodule
