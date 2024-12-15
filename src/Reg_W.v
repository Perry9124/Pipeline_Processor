module Reg_W(
    input clk,
    input rst,
    input [31:0] M_alu_out,
    input [31:0] M_ld_data_in,
    output reg [31:0] W_alu_out,
    output reg [31:0] W_ld_data_in
);
    always@(posedge clk) begin
        if (rst) begin
            W_alu_out <= 32'b0;
            W_ld_data_in <= 32'b0;
        end
        else begin
            W_alu_out <= M_alu_out;
            W_ld_data_in <= M_ld_data_in;
        end
    end
endmodule