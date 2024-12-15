module Reg_M(
    input clk,
    input rst,
    input [31:0] E_alu_out,
    input [31:0] E_rs2_data,
    output reg [31:0] M_alu_out,
    output reg [31:0] M_rs2_data
);
    always@(posedge clk) begin
        if (rst) begin
            M_alu_out <= 32'b0;
            M_rs2_data <= 32'b0;
        end
        else begin
            M_alu_out <= E_alu_out;
            M_rs2_data <= E_rs2_data;
        end
    end
endmodule