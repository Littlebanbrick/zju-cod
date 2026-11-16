`timescale 1ns / 1ps
`include "defines.vh"

module ALU(
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALU_operation,
    output reg  [31:0] res,
    output wire        zero
);

    /* TODO(Lab4-1): 根据本实验的 ALU_Control 编码实现整数运算。
       必须支持 AND / OR / ADD / SUB / SLT / SLTU /
       XOR / SRL / SLL / SRA。 */

    wire [31:0] and_res;
    wire [31:0] or_res;
    wire [31:0] add_res;
    wire [31:0] sub_res;
    wire        slt_res;        // 有符号比较
    wire        sltu_res;       // 无符号比较
    wire [31:0] xor_res;
    wire [31:0] srl_res;        // 逻辑右移，取B[4:0]
    wire [31:0] sll_res;        // 逻辑左移，取B[4:0]
    wire [31:0] sra_res;        // 算术右移，取B[4:0]

    assign and_res  = A & B;
    assign or_res   = A | B;
    assign add_res  = A + B;
    assign sub_res  = A + ~B + 1;
    assign slt_res  = ($signed(A) < $signed(B)) ? 1'b1 : 1'b0;
    assign sltu_res = (A < B) ? 1'b1 : 1'b0;
    assign xor_res  = A ^ B;
    assign srl_res  = A >> B[4:0];
    assign sll_res  = A << B[4:0];
    assign sra_res  = $signed(A) >>> B[4:0];        // 显式转成有符号数，再算术右移

    always @(*) begin
        case (ALU_operation)
            `ALU_AND:  res = and_res;
            `ALU_OR:   res = or_res;
            `ALU_ADD:  res = add_res;
            `ALU_SUB:  res = sub_res;
            `ALU_SLT:  res = slt_res;
            `ALU_SLTU: res = sltu_res;
            `ALU_XOR:  res = xor_res;
            `ALU_SRL:  res = srl_res;
            `ALU_SLL:  res = sll_res;
            `ALU_SRA:  res = sra_res;
            default: res = 32'b0;
        endcase
    end

    assign zero = (res == 32'b0) ? 1'b1 : 1'b0;

endmodule
