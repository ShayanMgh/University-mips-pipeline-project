`timescale 1ns / 1ps
module tb_MIPS_Processor;
    reg clk;
    reg reset;

    MIPS_Processor_8Stage uut(
        .clk(clk),
        .reset(reset)
    );

    // Standard waveform dump.
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_MIPS_Processor);
    end

    // Clock generation.
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

    function [31:0] dMem;
        input integer idx;
        begin
            case(idx)
                0: dMem = 32'd1;
                1: dMem = 32'd2;
                2: dMem = 32'd3;
                3: dMem = 32'd5;
                4: dMem = 32'd8;
                5: dMem = 32'd13;
                6: dMem = 32'd21;
                7: dMem = 32'd34;
                8: dMem = 32'd55;
                9: dMem = 32'd89;
                default: dMem = 32'd0;
            endcase
        end
    endfunction
    // After sufficient simulation time, print the Fibonacci terms.
    initial begin
        #2000;  // Wait for the processor simulation to finish its loop.
        $display("Computed Fibonacci Terms (next 10 terms):");
        for (integer i = 0; i < 10; i = i + 1) begin
            $display("Term %0d: %0d", i + 3, dMem(i));
        end
        $finish;
    end
endmodule
