module Register_File(
    input clk,
    input RegWrite,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] registers[31:0];
    integer i;
    initial begin
        for(i = 0; i < 32; i = i + 1)
            registers[i] = 32'd0;
    end
    assign read_data1 = (RegWrite && (read_reg1 == write_reg) && (write_reg != 0))
                          ? write_data : registers[read_reg1];
    assign read_data2 = (RegWrite && (read_reg2 == write_reg) && (write_reg != 0))
                          ? write_data : registers[read_reg2];
    always @(posedge clk) begin
        if(RegWrite && (write_reg != 0))
            registers[write_reg] <= write_data;
    end
endmodule
