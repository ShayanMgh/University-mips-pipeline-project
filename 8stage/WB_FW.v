module WB_FW(
    input             clk,
    input             reset,
    // Data in for forwarding
    input      [4:0]  write_reg_in,
    input      [31:0] wb_data_in,
    input             wb_regwrite_in,//Write enable signal (1 = write, 0 = no write)
    // Outputs
    output reg [4:0]  write_reg_out,
    output reg [31:0] wb_data_out,
    output reg        wb_regwrite_out
);
    always @(posedge clk) begin
        if(reset) begin
            write_reg_out   <= 5'd0;
            wb_data_out     <= 32'd0;
            wb_regwrite_out <= 1'b0;
        end else begin
            write_reg_out   <= write_reg_in;
            wb_data_out     <= wb_data_in;
            wb_regwrite_out <= wb_regwrite_in;
        end
    end
endmodule