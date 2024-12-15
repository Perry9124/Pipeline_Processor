`include "./src/define.v"
module Decoder(
    input [31:0] D_instruction,
    output reg [4:0] D_rd_index,
    output reg [4:0] D_rs1_index,
    output reg [4:0] D_rs2_index,
    output [6:0] D_opcode,
    output reg [2:0] D_func3,
    output reg [6:0] D_func7
);
    assign D_opcode = D_instruction[6:0];
    always@(*) begin
        case(D_opcode)
        `RTYPE: begin
            D_rd_index = D_instruction[11:7];
            D_rs1_index = D_instruction[19:15];
            D_rs2_index = D_instruction[24:20];
            D_func3 = D_instruction[14:12];
            D_func7 = D_instruction[31:25];
        end
        `ITYPE: begin
            D_rd_index = D_instruction[11:7];
            D_rs1_index = D_instruction[19:15];
            D_rs2_index = 5'b00000;
            D_func3 = D_instruction[14:12];
            case(D_func3)
            `SHIFTL: begin
                D_func7 = D_instruction[31:25];
            end
            `SHIFTR: begin
                D_func7 = D_instruction[31:25];
            end
            default: begin
                D_func7 = 7'b0000000;
            end
            endcase
        end
        `STYPE: begin
            D_rd_index = 5'b00000;
            D_rs1_index = D_instruction[19:15];
            D_rs2_index = D_instruction[24:20];
            D_func3 = D_instruction[14:12];
            D_func7 = 7'b0000000;
        end
        `BTYPE: begin
            D_rd_index = 5'b00000;
            D_rs1_index = D_instruction[19:15];
            D_rs2_index = D_instruction[24:20];
            D_func3 = D_instruction[14:12];
            D_func7 = 7'b0000000;
        end
        `LUI: begin
            D_rd_index = D_instruction[11:7];
            D_rs1_index = 5'b00000;
            D_rs2_index = 5'b00000;
            D_func3 = 3'b000;
            D_func7 = 7'b0000000;
        end
        `AUIPC: begin
            D_rd_index = D_instruction[11:7];
            D_rs1_index = 5'b00000;
            D_rs2_index = 5'b00000;
            D_func3 = 3'b000;
            D_func7 = 7'b0000000;
        end
        `JAL: begin
            D_rd_index = D_instruction[11:7];
            D_rs1_index = 5'b00000;
            D_rs2_index = 5'b00000;
            D_func3 = 3'b000;
            D_func7 = 7'b0000000;
        end
        `JALR: begin
            D_rd_index = D_instruction[11:7];
            D_rs1_index = D_instruction[19:15];
            D_rs2_index = 5'b00000;
            D_func3 = 3'b000;
            D_func7 = 7'b0000000;
        end
        `LOAD: begin
            D_rd_index = D_instruction[11:7];
            D_rs1_index = D_instruction[19:15];
            D_rs2_index = 5'b00000;
            D_func3 = D_instruction[14:12];
            D_func7 = 7'b0000000;
        end
        default: begin
            D_rd_index = 5'b00000;
            D_rs1_index = 5'b00000;
            D_rs2_index = 5'b00000;
            D_func3 = 3'b000;
            D_func7 = 7'b0000000;
        end
        endcase
    end
endmodule