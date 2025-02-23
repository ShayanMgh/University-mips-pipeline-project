module tb_MIPS_Processor;
    reg clk;
    reg reset;

    // Instantiate the processor.
    MIPS_Processor uut(
        .clk(clk),
        .reset(reset)
    );
    initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_MIPS_Processor);
    end

    // Clock generation: 10 time unit period.
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

    // Wait for the processor to finish computing and then print the 10 computed Fibonacci terms.
    initial begin
        // Wait long enough (2000 time units) for the loop to complete 10 iterations.
        #2000;
        $display("Computed Fibonacci Terms (next 10 terms):");
        // The processor writes computed terms into Data_Memory starting at byte address 8,
        // which corresponds to word indices 2 through 11.
        for (integer i = 3; i < 13; i = i + 1) begin
            $display("Term %0d: %0d", i, uut.dmem.memory[i]);
        end
        $finish;
    end
endmodule
