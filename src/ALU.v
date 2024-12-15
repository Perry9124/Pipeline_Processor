`include "./src/define.v"
module ALU (
    input [6:0] E_opcode,
    input [2:0] E_func3,
    input [6:0] E_func7,
    input [31:0] operand1,
    input [31:0] operand2,
    output reg signed [31:0] E_alu_out,
    output reg branch
);
    wire [31:0] add_result, sub_result, shiftl_result, shiftr_result, sra_result, pc4_result;
    wire [31:0] sra_offset, sra_sign;
    assign shiftl_result = operand1 << operand2[4:0];
    assign shiftr_result = operand1 >> operand2[4:0];
    assign sra_sign = {32{operand1[31]}} << sra_offset;
    Adder add(
        .a(operand1),
        .b(operand2),
        .sum(add_result)
    );
    Adder sub(
        .a(operand1),
        .b(~operand2 + 32'b1),
        .sum(sub_result)
    );
    Adder offset(
        .a(32'd32),
        .b(~operand2 + 32'b1),
        .sum(sra_offset)
    );
    Adder sra(
        .a(sra_sign),
        .b(shiftr_result),
        .sum(sra_result)
    );
    Adder pc4(
        .a(operand1),
        .b(32'b100),
        .sum(pc4_result)
    );
    always@(*) begin
        case(E_opcode)
        `LUI: begin
            E_alu_out = operand2;    // imm << 12
            branch = 1'b0;
        end
        `AUIPC: begin
            E_alu_out = operand1 + operand2;  // PC + imm
            branch = 1'b0;
        end
        `JAL: begin
            E_alu_out = pc4_result;   // PC + 4
            branch = 1'b1;
        end
        `JALR: begin
            E_alu_out = pc4_result;   // PC + 4
            branch = 1'b1;
        end
        `BTYPE: begin
            case(E_func3)
            `BEQ: begin
                branch = operand1 == operand2 ? 1'b1 : 1'b0;
            end
            `BNE: begin
                branch = operand1 != operand2 ? 1'b1 : 1'b0;
            end
            `BLT: begin
                branch = $signed(operand1) < $signed(operand2) ? 1'b1 : 1'b0;
            end
            `BGE: begin
                branch = $signed(operand1) >= $signed(operand2) ? 1'b1 : 1'b0;
            end
            `BLTU: begin
                branch = operand1 < operand2 ? 1'b1 : 1'b0;
            end
            `BGEU: begin
                branch = operand1 >= operand2 ? 1'b1 : 1'b0;
            end
            endcase
        end
        `ITYPE: begin
            case(E_func3)
            `ADD_SUB: begin
                E_alu_out = add_result;
            end
            `SLT: begin
                E_alu_out = $signed(operand1) < $signed(operand2) ? 32'b1 : 32'b0;
            end
            `SLTU: begin
                E_alu_out = operand1 < operand2 ? 32'b1 : 32'b0;
            end
            `XOR: begin
                E_alu_out = operand1 ^ operand2;
            end
            `OR: begin
                E_alu_out = operand1 | operand2;
            end
            `AND: begin
                E_alu_out = operand1 & operand2;
            end
            `SHIFTL: begin
                E_alu_out = shiftl_result;
            end
            `SHIFTR: begin
                case(E_func7)
                `SRA: begin
                    E_alu_out = sra_result;
                end
                `SRL: begin
                    E_alu_out = shiftr_result;
                end
                default: begin
                    E_alu_out = 32'b0;
                end
                endcase
            end
            default: begin
                E_alu_out = 32'b0;
            end
            endcase
        end
        `RTYPE: begin
            case(E_func3)
            `ADD_SUB: begin
                case(E_func7)
                `ADD: begin
                    E_alu_out = add_result;
                end
                `SUB: begin
                    E_alu_out = sub_result;
                end
                default: begin
                    E_alu_out = 32'b0;
                end
                endcase
            end
            `SLT: begin
                E_alu_out = $signed(operand1) < $signed(operand2) ? 32'b1 : 32'b0;
            end
            `SLTU: begin
                E_alu_out = operand1 < operand2 ? 32'b1 : 32'b0;
            end
            `XOR: begin
                E_alu_out = operand1 ^ operand2;
            end
            `OR: begin
                E_alu_out = operand1 | operand2;
            end
            `AND: begin
                E_alu_out = operand1 & operand2;
            end
            `SHIFTL: begin
                E_alu_out = shiftl_result;
            end
            `SHIFTR: begin
                case(E_func7)
                `SRA: begin
                    E_alu_out = sra_result;
                end
                `SRL: begin
                    E_alu_out = shiftr_result;
                end
                default: begin
                    E_alu_out = 32'b0;
                end
                endcase
            end
            default: begin
                E_alu_out = 32'b0;
            end
            endcase
        end
        `STYPE: begin
            E_alu_out = add_result;
        end
        `LOAD: begin
            E_alu_out = add_result;
        end
        default: begin
            E_alu_out = 32'b0;
            branch = 1'b0;
        end
        endcase
    end
endmodule