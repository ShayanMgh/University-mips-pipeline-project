// Generates control signals from the opcode field.
module Control_Unit(
    input [5:0] opcode,
    output reg RegDst,
    output reg ALUSrc,
    output reg MemToReg,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg Jump,
    output reg [1:0] ALUOp
);
    always @(*) begin
        // Default assignments
        RegDst   = 1'b0; ALUSrc   = 1'b0; MemToReg = 1'b0;
        RegWrite = 1'b0; MemRead  = 1'b0; MemWrite = 1'b0;
        Branch   = 1'b0; Jump     = 1'b0; ALUOp    = 2'b00;
        case(opcode)
            6'b000000: begin // R-type
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            6'b100011: begin // lw
                ALUSrc   = 1'b1;
                MemToReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b101011: begin // sw
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b000100: begin // beq
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end
            6'b001000: begin // addi
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b000010: begin // j
                Jump     = 1'b1;
            end
            default: ;
        endcase
    end
endmodule