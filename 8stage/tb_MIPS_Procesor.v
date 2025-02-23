module tb_MIPS_Processor;
    reg clk;
    reg reset;

    // Instantiate the processor.
    MIPS_Procesor_8Stage uut(
        .clk(clk),
        .reset(reset)
    );

    // Waveform dump.
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_MIPS_Procesor);
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

    // Wait for the processor to complete and then display memory.
    initial begin
        #2000;
        $display("Computed Fibonacci Terms (next 10 terms):");
        // Display memory contents from word indices 3 through 12.
        for (integer i = 3; i < 13; i = i + 1) begin
            $display("Term %0d: %0d", i, uut.dmem_write_port.memory[i]);
        end
        $finish;
    end
endmodule