module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALUControl,  
    output reg [31:0] Result,
    output Zero
);
    // Zero flag is high if result equals zero.
    assign Zero = (Result == 32'd0);
    always @(*) begin
        case(ALUControl)
            4'b0010: Result = A + B;    // add
            4'b0110: Result = A - B;    // subtract
            4'b0000: Result = A & B;    // and
            4'b0001: Result = A | B;    // or
            default: Result = 32'd0;
        endcase
    end
endmodule