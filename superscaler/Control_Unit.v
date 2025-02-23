// Control_Unit.v
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
        // Default values
        RegDst = 0; ALUSrc = 0; MemToReg = 0;
        RegWrite = 0; MemRead = 0; MemWrite = 0;
        Branch = 0; Jump = 0; ALUOp = 2'b00;
        case(opcode)
            6'b000000: begin // R-type
                RegDst = 1;
                RegWrite = 1;
                ALUOp = 2'b10;
            end
            6'b100011: begin // lw
                ALUSrc = 1;
                MemToReg = 1;
                RegWrite = 1;
                MemRead = 1;
                ALUOp = 2'b00;
            end
            6'b101011: begin // sw
                ALUSrc = 1;
                MemWrite = 1;
                ALUOp = 2'b00;
            end
            6'b000100: begin // beq
                Branch = 1;
                ALUOp = 2'b01;
            end
            6'b001000: begin // addi
                ALUSrc = 1;
                RegWrite = 1;
                ALUOp = 2'b00;
            end
            6'b000010: begin // jump
                Jump = 1;
            end
            default: ;
        endcase
    end
endmodule
