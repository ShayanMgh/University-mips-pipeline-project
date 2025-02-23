# Makefile for Superscalar MIPS Processor with Branch Predictor (Fibonacci)
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

TARGET = simulation_bp.out

SOURCES = \
    Branch_Predictor.v \
    Instruction_Memory_Dual.v \
    Data_Memory.v \
    Register_File.v \
    ALU.v \
    ALU_Control.v \
    Control_Unit.v \
    IF_PR_Dual.v \
    PR_ID_Dual.v \
    ID_Dual.v \
    ID_EX_Dual.v \
    EX.v \
    MEM_WB.v \
    MIPS_Processor_Superscalar.v \
    tb_MIPS_Processor_Superscalar.v

all: $(TARGET) run

$(TARGET): $(SOURCES)
	$(IVERILOG) -o $(TARGET) $(SOURCES)

run: $(TARGET)
	$(VVP) $(TARGET)

wave: $(TARGET)
	$(VVP) $(TARGET)
	$(GTKWAVE) wave_super.vcd

clean:
	rm -f $(TARGET) wave_super.vcd
