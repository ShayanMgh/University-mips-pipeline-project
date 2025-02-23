# Makefile for 8-Stage Pipelined MIPS Processor (Fibonacci) Simulation with Waveform Dump
# Tools: Icarus Verilog (iverilog), vvp for simulation, gtkwave for waveform viewing.

IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

TARGET = simulation8.out

SOURCES = \
    Instruction_Memory.v \
    Data_Memory.v \
    Register_File.v \
    ALU.v \
    ALU_Control.v \
    Control_Unit.v \
    IF_PR.v \
    PR_ID.v \
    ID_EX.v \
    EX_MR.v \
    MR_MW.v \
    MW_WB.v \
    WB_FW.v \
    MIPS_Processor_8Stage.v \
    tb_MIPS_Processor.v

all: $(TARGET) run

$(TARGET): $(SOURCES)
	$(IVERILOG) -o $(TARGET) $(SOURCES)

run: $(TARGET)
	$(VVP) $(TARGET)

wave: $(TARGET)
	$(VVP) $(TARGET)
	$(GTKWAVE) wave8.vcd

clean:
	rm -f $(TARGET) wave8.vcd
