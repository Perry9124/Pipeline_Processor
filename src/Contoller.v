`include "./src/define.v"
module Controller(
    input clk,
    input [6:0] D_opcode,
    input [2:0] D_func3,
    input [6:0] D_func7,
    input [4:0] D_rd_index,
    input [4:0] D_rs1_index,
    input [4:0] D_rs2_index,
    input branch,
    output reg stall,
    output reg jb,
    output reg wb_en,
    output reg D_rs1_sel,
    output reg D_rs2_sel,
    output reg [1:0] E_rs1_sel,
    output reg [1:0] E_rs2_sel,
    output reg alu_op1_sel,
    output reg alu_op2_sel,
    output reg E_jb_op1_sel,
    output reg [6:0] E_opcode,
    output reg [2:0] E_func3,
    output reg [6:0] E_func7,
    output reg [3:0] dm_w_en,
    output reg wb_sel,
    output reg [2:0] W_func3,
    output reg [4:0] W_rd_index
);
    reg [4:0] E_rd_index;
    reg [4:0] E_rs1_index;
    reg [4:0] E_rs2_index;
    reg [6:0] M_opcode;
    reg [2:0] M_func3;
    reg [4:0] M_rd_index;
    reg [6:0] W_opcode;

    always@(posedge clk) begin
        if(stall || jb) begin
            E_opcode <= 7'b0;
            E_func3 <= 3'b0;
            E_func7 <= 7'b0;
            E_rd_index <= 5'b0;
            E_rs1_index <= 5'b0;
            E_rs2_index <= 5'b0;
        end
        else begin
            E_opcode <= D_opcode;
            E_func3 <= D_func3;
            E_func7 <= D_func7;
            E_rd_index <= D_rd_index;
            E_rs1_index <= D_rs1_index;
            E_rs2_index <= D_rs2_index;
        end
        M_opcode <= E_opcode;
        M_func3 <= E_func3;
        M_rd_index <= E_rd_index;
        W_opcode <= M_opcode;
        W_func3 <= M_func3;
        W_rd_index <= M_rd_index;
    end
    always@(*) begin
        case(E_opcode)
        `RTYPE: begin
            jb = 1'b0;
            stall = 1'b0;
            E_jb_op1_sel = 1'b0;
            alu_op1_sel = `REG;
            alu_op2_sel = `REG;
        end
        `ITYPE: begin
            jb = 1'b0;
            stall = 1'b0;
            E_jb_op1_sel = 1'b0;
            alu_op1_sel = `REG;
            alu_op2_sel = `IMM;
        end
        `STYPE: begin
            jb = 1'b0;
            stall = 1'b0;
            E_jb_op1_sel = 1'b0;
            alu_op1_sel = `REG;
            alu_op2_sel = `IMM;
            case(E_func3)
            `SB: begin
                dm_w_en = 4'b0001;
            end
            `SH: begin
                dm_w_en = 4'b0011;
            end
            `SW: begin
                dm_w_en = 4'b1111;
            end
            endcase
        end
        `BTYPE: begin
            // pc + imm
            stall = 1'b0;
            E_jb_op1_sel = `PC;
            alu_op1_sel = `REG;
            alu_op2_sel = `REG;
            if (branch) begin
                jb = 1'b1;
            end
            else begin
                jb = 1'b0;
            end
        end
        `LUI: begin
            jb = 1'b0;
            stall = 1'b0;
            wb_en = 1'b1;
            E_jb_op1_sel = `REG;
            alu_op1_sel = `REG;
            alu_op2_sel = `IMM;
        end
        `AUIPC: begin
            jb = 1'b0;
            stall = 1'b0;
            wb_en = 1'b1;
            E_jb_op1_sel = `REG;
            alu_op1_sel = `PC;
            alu_op2_sel = `IMM;
        end
        `JAL: begin
            jb = 1'b1;
            stall = 1'b0;
            wb_en = 1'b1;
            E_jb_op1_sel = `PC;   // pc + imm
            alu_op1_sel = `PC;  // pc + 4
            alu_op2_sel = `REG;
        end
        `JALR: begin
            jb = 1'b1;
            stall = 1'b0;
            wb_en = 1'b1;
            E_jb_op1_sel = `REG;  // rs1 + imm
            alu_op1_sel = `PC;  // pc + 4
            alu_op2_sel = `REG;
        end
        `LOAD: begin
            jb = 1'b0;
            wb_en = 1'b1;
            E_jb_op1_sel = 1'b0;
            alu_op1_sel = `REG;
            alu_op2_sel = `IMM;
            if ((E_rd_index == D_rs1_index && D_rs1_index != 5'b00000) || 
            (E_rd_index == D_rs2_index && D_rs2_index != 5'b00000)) begin
                stall = 1'b1;
            end
            else begin
                stall = 1'b0;
            end
        end
        default: begin
            jb = 1'b0;
            stall = 1'b0;
            wb_en = 1'b0;
            E_jb_op1_sel = 1'b0;
            alu_op1_sel = 1'b0;
            alu_op2_sel = 1'b0;
        end
        endcase
        case(M_opcode)
        `STYPE: begin
            case(M_func3)
            `SB: begin
                dm_w_en = 4'b0001;
            end
            `SH: begin
                dm_w_en = 4'b0011;
            end
            `SW: begin
                dm_w_en = 4'b1111;
            end
            default: begin
                dm_w_en = 4'b0000;
            end
            endcase
        end
        default: begin
            dm_w_en = 4'b0000;
        end
        endcase
        case(W_opcode)
        `RTYPE: begin
            wb_en = 1'b1;
            wb_sel = 1'b0;
        end
        `ITYPE: begin
            wb_en = 1'b1;
            wb_sel = 1'b0;
        end
        `LUI: begin
            wb_en = 1'b1;
            wb_sel = 1'b0;
        end
        `AUIPC: begin
            wb_en = 1'b1;
            wb_sel = 1'b0;
        end
        `JAL: begin
            wb_en = 1'b1;
            wb_sel = 1'b0;
        end
        `JALR: begin
            wb_en = 1'b1;
            wb_sel = 1'b0;
        end
        `LOAD: begin
            wb_en = 1'b1;
            wb_sel = 1'b1;
        end
        default: begin
            wb_en = 1'b0;
            wb_sel = 1'b0;
        end
        endcase
        if (D_rs1_index == W_rd_index && D_rs1_index != 5'b00000) begin
            D_rs1_sel = 1'b1;
        end
        else begin
            D_rs1_sel = 1'b0;
        end
        if (D_rs2_index == W_rd_index && D_rs2_index != 5'b00000) begin
            D_rs2_sel = 1'b1;
        end
        else begin
            D_rs2_sel = 1'b0;
        end
        if (E_rs1_index == M_rd_index && E_rs1_index != 5'b00000) begin
            E_rs1_sel = 2'b01;
        end
        else if (E_rs1_index == W_rd_index && E_rs1_index != 5'b00000) begin
            E_rs1_sel = 2'b10;
        end
        else begin
            E_rs1_sel = 2'b00;
        end
        if (E_rs2_index == M_rd_index && E_rs2_index != 5'b00000) begin
            E_rs2_sel = 2'b01;
        end
        else if (E_rs2_index == W_rd_index && E_rs2_index != 5'b00000) begin
            E_rs2_sel = 2'b10;
        end
        else begin
            E_rs2_sel = 2'b00;
        end
    end
endmodule