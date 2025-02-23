`timescale 1ns/1ps
module tb_MIPS_Processor_Superscalar;
    reg clk;
    reg reset;

    MIPS_Processor_Superscalar #(1) uut (  // PREDICTOR_TYPE=1: Always Not Taken
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $dumpfile("wave_super.vcd");
        $dumpvars(0, tb_MIPS_Processor_Superscalar);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10;
        reset = 0;
    end

    // Wait enough time for the Fibonacci loop to complete and print the results.
    // (We assume 10 iterations take about 10 cycles; adjust the delay as needed.)
    initial begin
        #3000;
        $display("Computed Fibonacci Terms (next 10 terms):");
        $display("Term 3:  %0d", uut.dmem.fib2);
        $display("Term 4:  %0d", uut.dmem.fib3);
        $display("Term 5:  %0d", uut.dmem.fib4);
        $display("Term 6:  %0d", uut.dmem.fib5);
        $display("Term 7:  %0d", uut.dmem.fib6);
        $display("Term 8:  %0d", uut.dmem.fib7);
        $display("Term 9:  %0d", uut.dmem.fib8);
        $display("Term 10: %0d", uut.dmem.fib9);
        $display("Term 11: %0d", uut.dmem.fib10);
        $display("Term 12: %0d", uut.dmem.fib11);
        $finish;
    end
endmodule
