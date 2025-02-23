# Makefile for 5-Stage Pipelined MIPS Processor Simulation with Waveform Dump
# Uses Icarus Verilog (iverilog) for compilation and vvp for simulation.

# Tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Target simulation executable
TARGET = simulation.out

# List of Verilog source files (adjust filenames as needed)
SOURCES = \
    MIPS_Processor.v \
    Instruction_Memory.v \
    Data_Memory.v \
    Register_File.v \
    ALU.v \
    ALU_Control.v \
    Control_Unit.v \
    IF_ID.v \
    ID_EX.v \
    EX_MEM.v \
    MEM_WB.v \
    tb_MIPS_Processor.v

# Default target: compile then run the simulation.
all: $(TARGET) run

# Compile the design and testbench.
$(TARGET): $(SOURCES)
	$(IVERILOG) -o $(TARGET) $(SOURCES)

# Run the simulation (creates wave.vcd if your testbench dumps waves).
run: $(TARGET)
	$(VVP) $(TARGET)

# Run simulation and then open the waveform viewer.
wave: $(TARGET)
	$(VVP) $(TARGET)
	$(GTKWAVE) wave.vcd

# Clean up generated files.
clean:
	rm -f $(TARGET) wave.vcd
