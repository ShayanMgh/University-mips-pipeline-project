# MIPS Pipeline Project

This project implements a superscalar, deeply pipelined MIPS processor with advanced branch prediction. It is organized in multiple parts:

- **Part 1: 5-Stage Pipeline MIPS Processor**  
  A traditional 5-stage MIPS pipeline implementing IF, ID, EX, MEM, and WB stages. It includes hazard handling via forwarding and stall cycles. A simple Fibonacci program is used to validate functionality.

- **Part 2: 8-Stage Pipeline MIPS Processor**  
  Extends the 5-stage design by further segmenting the pipeline to reduce critical path delays and improve the clock frequency (target ≥ 35 MHz).

- **Part 3: Superscalar Execution**  
  Modifies the pipeline to support dual-issue execution. Two instructions are fetched, decoded, and (if no dependency exists) executed in parallel.

- **Part 4: Branch Prediction**  
  Integrates an advanced branch predictor into the superscalar design. The predictor supports multiple schemes:
  - Global Adaptive Scheme (GAs)
  - Gshare (Global History Register + XOR Indexing)
  - Gshare/Bimodal Hybrid
  - Always Taken
  - Always Not Taken

## Project Structure

- **Verilog Modules:**
  - `Instruction_Memory_Dual.v`: Dual-issue instruction memory.
  - `Data_Memory.v`: Data memory with outputs for computed Fibonacci terms.
  - `Register_File.v`: 32x32 register file.
  - `ALU.v`: Arithmetic Logic Unit.
  - `ALU_Control.v`: Generates ALU control signals.
  - `Control_Unit.v`: Main control unit for the processor.
  - Pipeline registers (e.g., `IF_PR_Dual.v`, `PR_ID_Dual.v`, `ID_Dual.v`, `ID_EX_Dual.v`, etc.).
  - `EX.v`: Execution stage (Fibonacci computation logic).
  - `MEM_WB.v`: Memory/Write-Back stage.
  - `Branch_Predictor.v`: Multi-scheme branch predictor.
  - `MIPS_Processor_Superscalar.v`: Top-level module integrating the superscalar pipeline and branch predictor.

- **Testbench:**
  - `tb_MIPS_Processor_Superscalar.v`: Testbench for simulation that prints the computed Fibonacci sequence.

- **Makefile:**  
  Contains instructions to compile and simulate the project using Icarus Verilog.
