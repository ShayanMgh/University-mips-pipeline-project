`timescale 1ns/1ps
module Branch_Predictor
#(
    // 0=AlwaysTaken,1=AlwaysNotTaken,2=GAs,3=Gshare,4=Hybrid
    parameter PREDICTOR_TYPE = 1
)
(
    input         clk,
    input         reset,

    input  [31:0] pc_in,
    output reg    pred_taken,
    output reg [31:0] pred_target,

    input  [31:0] branch_pc,
    input         taken,          // actual outcome: 1 if branch was taken
    input  [31:0] actual_target,  // correct branch target
    input         update_valid    // 1 if we have a branch outcome to update
);

    // Internals for advanced prediction
    //define a small global history (4 bits) and 16-entry 2-bit saturating counters.
    reg [3:0] global_history;

    // Pattern History Table (16 entries), used for GAs or Gshare
    reg [1:0] pht[0:15];

    // Bimodal table (16 entries)
    reg [1:0] bimodal[0:15];

    // Chooser table for Gshare/Bimodal Hybrid (16 entries)
    reg [1:0] chooser[0:15];

    reg [31:0] btb[0:15];

    integer i;
    initial begin
        global_history = 4'b0000;
        for(i=0; i<16; i=i+1) begin
            pht[i]     = 2'b01; // weakly not taken
            bimodal[i] = 2'b01; // weakly not taken
            chooser[i] = 2'b01; // slightly prefer bimodal
            btb[i]     = 32'h00000000;
        end
    end

    // Functions for 2-bit saturating counter usage
    function is_taken_2bit;
        input [1:0] c;
        begin
            // c=00(strongNT),01(weakNT),10(weakT),11(strongT)
            // If top bit=1 => predict taken
            is_taken_2bit = c[1];
        end
    endfunction

    function [1:0] inc2b;
        input [1:0] c;
        begin
            if(c == 2'b11)
                inc2b = 2'b11;
            else
                inc2b = c + 2'b01;
        end
    endfunction

    function [1:0] dec2b;
        input [1:0] c;
        begin
            if(c == 2'b00)
                dec2b = 2'b00;
            else
                dec2b = c - 2'b01;
        end
    endfunction

    // The index for a 16-entry table uses bits [5:2] from the PC
    wire [3:0] pc_index;
    assign pc_index = pc_in[5:2];
    // For Gshare, index is global_history XOR pc_index
    wire [3:0] gshare_index;
    assign gshare_index = global_history ^ pc_index;
    // For GAs, let's define a 6-bit index: top 4 bits of GH plus 2 zeros
    wire [5:0] gas_idx;
    assign gas_idx = {global_history, 2'b00};
    // For the BTB, we do direct mapping
    wire [3:0] btb_index;
    assign btb_index = pc_index;

    // Combinational Prediction
    reg guess_taken;
    reg [31:0] guess_target;
    reg [1:0] choice;
    reg use_gshare;
    reg gsh_guess;
    reg bim_guess;

    always @(*) begin
        guess_taken  = 1'b0;
        guess_target = pc_in + 4; // default next sequential address
        case(PREDICTOR_TYPE)
            0: begin
                // 0=Always Taken
                guess_taken  = 1'b1;
                guess_target = btb[btb_index];
            end
            1: begin
                // 1=Always Not Taken
                guess_taken  = 1'b0;
                guess_target = pc_in + 4;
            end
            2: begin
                // 2=GAs => index = {global_history,2'b00}
                if(is_taken_2bit(pht[gas_idx]))
                    guess_taken  = 1'b1;
                else
                    guess_taken  = 1'b0;
                if(guess_taken)
                    guess_target = btb[btb_index];
                else
                    guess_target = pc_in + 4;
            end
            3: begin
                // 3=Gshare => pht[gshare_index]
                if(is_taken_2bit(pht[gshare_index]))
                    guess_taken = 1'b1;
                else
                    guess_taken = 1'b0;
                if(guess_taken)
                    guess_target = btb[btb_index];
                else
                    guess_target = pc_in + 4;
            end
            4: begin
                // 4=Hybrid => chooser picks Gshare or Bimodal
                choice = chooser[pc_index];
                use_gshare = choice[1]; // if top bit=1 => prefer Gshare
                gsh_guess  = is_taken_2bit(pht[gshare_index]);
                bim_guess  = is_taken_2bit(bimodal[pc_index]);
                if(use_gshare)
                    guess_taken = gsh_guess;
                else
                    guess_taken = bim_guess;
                if(guess_taken)
                    guess_target = btb[btb_index];
                else
                    guess_target = pc_in + 4;
            end
            default: begin
                // fallback => always not taken
                guess_taken  = 1'b0;
                guess_target = pc_in + 4;
            end
        endcase
    end

    // Assign the outputs from our guess
    always @(*) begin
        pred_taken  = guess_taken;
        pred_target = guess_target;
    end

    // Update Logic (sequential)
    wire [3:0] bpc_index = branch_pc[5:2];
    wire [3:0] b_gshare_index = global_history ^ bpc_index;
    wire [5:0] gas_idx2 = {global_history, 2'b00};

    // define these regs at the top of the always block to avoid inline declarations
    reg gsh_pred, bim_pred;

    always @(posedge clk) begin
        if(reset) begin
            global_history <= 4'b0000;
        end else if(update_valid) begin
            // Update the BTB
            btb[bpc_index] <= actual_target;

            case(PREDICTOR_TYPE)
                0: begin
                    // Always Taken => no table updates
                end
                1: begin
                    // Always Not Taken => no table updates
                end
                2: begin
                    // GAs => use pht[gas_idx2]
                    if(taken)
                        pht[gas_idx2] <= inc2b(pht[gas_idx2]);
                    else
                        pht[gas_idx2] <= dec2b(pht[gas_idx2]);
                    global_history <= {global_history[2:0], taken};
                end
                3: begin
                    // Gshare
                    if(taken)
                        pht[b_gshare_index] <= inc2b(pht[b_gshare_index]);
                    else
                        pht[b_gshare_index] <= dec2b(pht[b_gshare_index]);
                    global_history <= {global_history[2:0], taken};
                end
                4: begin
                    // Hybrid => update Gshare & Bimodal, then chooser
                    // 1) update pht
                    if(taken)
                        pht[b_gshare_index] <= inc2b(pht[b_gshare_index]);
                    else
                        pht[b_gshare_index] <= dec2b(pht[b_gshare_index]);
                    // 2) update bimodal
                    if(taken)
                        bimodal[bpc_index] <= inc2b(bimodal[bpc_index]);
                    else
                        bimodal[bpc_index] <= dec2b(bimodal[bpc_index]);

                    // 3) figure out who was correct
                    gsh_pred = is_taken_2bit(pht[b_gshare_index]);
                    bim_pred = is_taken_2bit(bimodal[bpc_index]);
                    if((gsh_pred == taken) && (bim_pred != taken))
                        chooser[bpc_index] <= inc2b(chooser[bpc_index]);
                    else if((bim_pred == taken) && (gsh_pred != taken))
                        chooser[bpc_index] <= dec2b(chooser[bpc_index]);

                    // 4) update GH
                    global_history <= {global_history[2:0], taken};
                end
                default: ;
            endcase
        end
    end

endmodule
