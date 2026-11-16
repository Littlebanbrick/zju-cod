`timescale 1ns / 1ps
`include "defines.vh"

module ImmGen(
    input  wire [2:0]  ImmSel,
    input  wire [31:0] inst_field,
    output reg  [31:0] Imm_out
);

    /* TODO(Lab4-1): 实现 U / I / S / B / J 五种立即数生成。 */

    wire [31:0] U_out;
    wire [31:0] I_out;
    wire [31:0] S_out;
    wire [31:0] B_out;
    wire [31:0] J_out;

    assign U_out = {inst_field[31:12], 12'b0};
    assign I_out = {{20{inst_field[31]}}, inst_field[31:20]};
    assign S_out = {{20{inst_field[31]}}, inst_field[31:25], inst_field[11:7]};
    assign B_out = {{20{inst_field[31]}}, inst_field[7], inst_field[30:25], inst_field[11:8], 1'b0};
    assign J_out = {{12{inst_field[31]}}, inst_field[19:12], inst_field[20], inst_field[30:21], 1'b0};

    always @(*) begin
        case (ImmSel)
            `IMM_U:  Imm_out = U_out;
            `IMM_I:  Imm_out = I_out;
            `IMM_S:  Imm_out = S_out;
            `IMM_B:  Imm_out = B_out;
            `IMM_J:  Imm_out = J_out;
            default: Imm_out = 32'b0;
        endcase
    end

endmodule
