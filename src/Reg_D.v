module Reg_D(
    input clk,
    input rst,
    input stall,
    input jb,
    input [31:0] F_pc,
    input [31:0] F_instruction,
    output reg [31:0] D_pc,
    output reg [31:0] D_instruction 
);
    always@(posedge clk) begin
        if (rst) begin
            D_pc <= 32'b0;
            D_instruction <= 32'b0;
        end
        else begin
            if (jb) begin
                D_pc <= 32'b0;
                D_instruction <= 32'b0;
            end
            else if (stall) begin
                D_pc <= D_pc;
                D_instruction <= D_instruction;
            end
            else begin
                D_pc <= F_pc;
                D_instruction <= F_instruction;
            end
        end
    end
endmodule