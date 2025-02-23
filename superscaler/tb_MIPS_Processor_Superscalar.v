`timescale 1ns/1ps
module tb_MIPS_Processor_Superscalar;
    reg clk;
    reg reset;
    
    MIPS_Processor_Superscalar uut(
        .clk(clk),
        .reset(reset)
    );
    
    initial begin
        $dumpfile("wave_super.vcd");
        $dumpvars(0, tb_MIPS_Processor_Superscalar);
    end
    
    // Clock generation: period = 10 ns.
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reset sequence.
    initial begin
        reset = 1;
        #10;
        reset = 0;
    end
    
    // Wait for the Fibonacci loop to complete, then print results.
    // We assume that lane1’s computed Fibonacci numbers are written into Data_Memory
    // (starting at word index 2 as in the original program).
    initial begin
        #3000; // Adjust simulation time if needed.
        $display("Computed Fibonacci Terms (next 10 terms) from lane1:");
        for (integer i = 2; i < 12; i = i + 1) begin
            $display("Term %0d: %0d", i+1, uut.dmem.memory[i]);
        end
        $finish;
    end
endmodule
