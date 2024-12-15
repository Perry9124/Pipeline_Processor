module Reg_E(
    input clk,
    input rst,
    input stall,
    input jb,
    input [31:0] D_pc,
    input [31:0] D_rs1_data,
    input [31:0] D_rs2_data,
    input [31:0] D_sext_imme,
    output reg [31:0] E_pc,
    output reg [31:0] E_rs1_data,
    output reg [31:0] E_rs2_data,
    output reg [31:0] E_sext_imme
);
    always@(posedge clk) begin
        if (rst) begin
            E_pc <= 32'b0;
            E_rs1_data <= 32'b0;
            E_rs2_data <= 32'b0;
            E_sext_imme <= 32'b0;
        end
        else begin
            if (jb) begin
                E_pc <= 32'b0;
                E_rs1_data <= 32'b0;
                E_rs2_data <= 32'b0;
                E_sext_imme <= 32'b0;
            end
            else if (stall) begin
                E_pc <= 32'b0;
                E_rs1_data <= 32'b0;
                E_rs2_data <= 32'b0;
                E_sext_imme <= 32'b0;
            end
            else begin
                E_pc <= D_pc;
                E_rs1_data <= D_rs1_data;
                E_rs2_data <= D_rs2_data;
                E_sext_imme <= D_sext_imme;
            end
        end
    end
endmodule