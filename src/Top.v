module Top (
    input clk,
    input rst
);
    wire [31:0] F_instruction;   // IF instruction
    wire [31:0] F_pc;            // IF program counter
    wire [31:0] next_pc;         // next program counter
    wire [31:0] rs1_data;        // source register 1 data
    wire [31:0] rs2_data;        // source register 2 data
    wire [31:0] D_instruction;   // ID instruction
    wire [31:0] D_pc;            // ID program counter
    wire [4:0] D_rd_index;       // destination register index
    wire [4:0] D_rs1_index;      // ID source register 1 index
    wire [4:0] D_rs2_index;      // ID source register 2 index
    wire [31:0] D_rs1_data;      // ID source register 1 data
    wire [31:0] D_rs2_data;      // ID source register 2 data
    wire [6:0] D_opcode;         // ID opcode
    wire [2:0] D_func3;          // ID func3
    wire [6:0] D_func7;          // ID func7
    wire [31:0] D_sext_imme;     // ID sign extended immediate
    wire [31:0] E_pc;            // Ex program counter
    wire [31:0] E_rs1_data;      // Ex source register 1 data
    wire [31:0] E_rs2_data;      // Ex source register 2 data
    reg [31:0] E_new_rs1_data;   // Ex source register 1 data
    reg [31:0] E_new_rs2_data;   // Ex source register 2 data
    wire [31:0] E_sext_imme;     // Ex sign extended immediate
    wire [31:0] E_alu_out;       // Ex ALU output
    wire [6:0] E_opcode;         // Ex opcode
    wire [2:0] E_func3;          // Ex func3
    wire [6:0] E_func7;          // Ex func7
    wire [31:0] M_rs2_data;      // Mem source register 2 data
    wire [31:0] M_alu_out;       // Mem ALU output
    wire [31:0] M_ld_data_in;    // Mem data to be loaded
    wire [31:0] W_alu_out;       // WB ALU output
    wire [31:0] W_ld_data_in;    // data to be loaded
    wire [31:0] ld_data_out;     // data loaded from memory
    wire [31:0] wb_data;         // write back data to register
    wire [31:0] jb_operand1;     // operand1 for jump
    wire [31:0] jb_pc;           // jump program counter
    wire [31:0] alu_op1;         // operand1 for ALU
    wire [31:0] alu_op2;         // operand2 for ALU

    wire stall;                  // 0: no stall, 1: stall
    wire jb;                     // 0: no jump, 1: jump
    wire wb_en;                  // 0: no write, 1: write back to reg
    wire branch;                 // 0: pc+4, 1: imm
    wire wb_sel;                 // 0: alu_out, 1: dm_wb_data
    wire D_rs1_sel;              // ID 0: rs1_data, 1: wb_data
    wire D_rs2_sel;              // ID 0: rs2_data, 1: wb_data
    wire [1:0] E_rs1_sel;        // EX 2'b00: rs1_data, 2'b01: alu_out, 2'b10: wb_data
    wire [1:0] E_rs2_sel;        // EX 2'b00: rs2_data, 2'b01: alu_out, 2'b10: wb_data
    wire E_jb_op1_sel;           // EX 0: rs1_data, 1: pc
    wire alu_op1_sel;            // EX 0: rs1_data, 1: pc
    wire alu_op2_sel;            // EX 0: rs2_data, 1: imm
    wire [3:0] dm_w_en;          // 4'b0000: no write, 4'b0001: byte, 4'b0011: half, 4'b1111: word
    wire [2:0] W_func3;          // WB func3 for write back
    wire [4:0] W_rd_index;       // WB destination register index for write back

    always@(*) begin
        case(E_rs1_sel)
        2'b00: E_new_rs1_data = E_rs1_data;
        2'b01: E_new_rs1_data = M_alu_out;
        2'b10: E_new_rs1_data = wb_data;
        default: E_new_rs1_data = 32'b0;
        endcase
        case(E_rs2_sel)
        2'b00: E_new_rs2_data = E_rs2_data;
        2'b01: E_new_rs2_data = M_alu_out;
        2'b10: E_new_rs2_data = wb_data;
        default: E_new_rs2_data = 32'b0;
        endcase
    end
    Mux next_pc_mux(
        .sel(jb),
        .input0(F_pc + 4),
        .input1(jb_pc),
        .out(next_pc)
    );
    Reg_PC reg_pc(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .next_pc(next_pc),
        .pc(F_pc)
    );
    SRAM im(
        .clk(clk),
        .w_en(4'b0000),
        .addr(F_pc[15:0]),
        .write_data(32'b0),
        .read_data(F_instruction)
    );
    Reg_D reg_d(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .jb(jb),
        .F_pc(F_pc),
        .F_instruction(F_instruction),
        .D_pc(D_pc),
        .D_instruction(D_instruction)
    );
    Controller ctrl(
        .clk(clk),
        .D_opcode(D_opcode),
        .D_func3(D_func3),
        .D_func7(D_func7),
        .D_rd_index(D_rd_index),
        .D_rs1_index(D_rs1_index),
        .D_rs2_index(D_rs2_index),
        .branch(branch),
        .stall(stall),
        .jb(jb),
        .wb_en(wb_en),
        .D_rs1_sel(D_rs1_sel),  
        .D_rs2_sel(D_rs2_sel),
        .E_rs1_sel(E_rs1_sel),
        .E_rs2_sel(E_rs2_sel),
        .alu_op1_sel(alu_op1_sel),
        .alu_op2_sel(alu_op2_sel),
        .E_jb_op1_sel(E_jb_op1_sel),
        .E_opcode(E_opcode),
        .E_func3(E_func3),
        .E_func7(E_func7),
        .dm_w_en(dm_w_en),
        .wb_sel(wb_sel),
        .W_func3(W_func3),
        .W_rd_index(W_rd_index)
    );
    Decoder dec(
        .D_instruction(D_instruction),
        .D_rd_index(D_rd_index),
        .D_rs1_index(D_rs1_index),
        .D_rs2_index(D_rs2_index),
        .D_opcode(D_opcode),
        .D_func3(D_func3),
        .D_func7(D_func7)
    );
    Reg regfile(
        .clk(clk),
        .wb_en(wb_en),
        .wb_data(wb_data),
        .W_rd_index(W_rd_index),
        .D_rs1_index(D_rs1_index),
        .D_rs2_index(D_rs2_index),
        .D_rs1_data(rs1_data),
        .D_rs2_data(rs2_data)
    );
    Mux D_rs1(
        .sel(D_rs1_sel),
        .input0(rs1_data),
        .input1(wb_data),
        .out(D_rs1_data)
    );
    Mux D_rs2(
        .sel(D_rs2_sel),
        .input0(rs2_data),
        .input1(wb_data),
        .out(D_rs2_data)
    );
    Imme_Ext imm(
        .instruction(D_instruction),
        .opcode(D_opcode),
        .func3(D_func3),
        .func7(D_func7),
        .sext_imme(D_sext_imme)
    );
    Reg_E reg_e(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .jb(jb),
        .D_pc(D_pc),
        .D_rs1_data(D_rs1_data),
        .D_rs2_data(D_rs2_data),
        .D_sext_imme(D_sext_imme),
        .E_pc(E_pc),
        .E_rs1_data(E_rs1_data),
        .E_rs2_data(E_rs2_data),
        .E_sext_imme(E_sext_imme)
    );
    Mux jb_op1(
        .sel(E_jb_op1_sel),
        .input0(E_new_rs1_data),
        .input1(E_pc),
        .out(jb_operand1)
    );
    JB_Unit jb_unit(
        .operand1(jb_operand1),
        .operand2(E_sext_imme),
        .jb_out(jb_pc)
    );
    Mux op1(
        .sel(alu_op1_sel),
        .input0(E_new_rs1_data),
        .input1(E_pc),
        .out(alu_op1)
    );
    Mux op2(
        .sel(alu_op2_sel),
        .input0(E_new_rs2_data),
        .input1(E_sext_imme),
        .out(alu_op2)
    );
    ALU alu(
        .E_opcode(E_opcode),
        .E_func3(E_func3),
        .E_func7(E_func7),
        .operand1(alu_op1),
        .operand2(alu_op2),
        .E_alu_out(E_alu_out),
        .branch(branch)
    );
    Reg_M reg_m(
        .clk(clk),
        .rst(rst),
        .E_alu_out(E_alu_out),
        .E_rs2_data(E_new_rs2_data),
        .M_alu_out(M_alu_out),
        .M_rs2_data(M_rs2_data)
    );
    SRAM dm(
        .clk(clk),
        .w_en(dm_w_en),
        .addr(M_alu_out[15:0]),
        .write_data(M_rs2_data),
        .read_data(M_ld_data_in)
    );
    Reg_W reg_w(
        .clk(clk),
        .rst(rst),
        .M_alu_out(M_alu_out),
        .M_ld_data_in(M_ld_data_in),
        .W_alu_out(W_alu_out),
        .W_ld_data_in(W_ld_data_in)
    );
    LD_Filter filter(
        .W_func3(W_func3),
        .ld_data_in(W_ld_data_in),
        .ld_data_out(ld_data_out)
    );
    Mux wb(
        .sel(wb_sel),
        .input0(W_alu_out),
        .input1(ld_data_out),
        .out(wb_data)
    );
endmodule