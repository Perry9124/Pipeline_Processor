module Reg(
    input clk, 
    input wb_en,
    input [31:0] wb_data,
    input [4:0] W_rd_index,
    input [4:0] D_rs1_index,
    input [4:0] D_rs2_index,
    output [31:0] D_rs1_data,
    output [31:0] D_rs2_data
);
    reg [31:0] registers [31:0];  // x0-x31
    always @(posedge clk) begin
        if (wb_en && W_rd_index != 0) begin
            registers[W_rd_index] <= wb_data;
        end
    end
    assign D_rs1_data = registers[D_rs1_index];
    assign D_rs2_data = registers[D_rs2_index];
endmodule