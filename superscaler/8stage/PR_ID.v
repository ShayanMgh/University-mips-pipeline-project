module PR_ID(
    input             clk,
    input             reset,
    input      [31:0] rs_data_in,
    input      [31:0] rt_data_in,
    input      [31:0] instr_in,
    input      [31:0] pc_in,
    output reg [31:0] rs_data_out,
    output reg [31:0] rt_data_out,
    output reg [31:0] instr_out,
    output reg [31:0] pc_out
);
    always @(posedge clk) begin
        if(reset) begin
            rs_data_out <= 32'd0;
            rt_data_out <= 32'd0;
            instr_out   <= 32'd0;
            pc_out      <= 32'd0;
        end else begin
            rs_data_out <= rs_data_in;
            rt_data_out <= rt_data_in;
            instr_out   <= instr_in;
            pc_out      <= pc_in;
        end
    end
endmodule