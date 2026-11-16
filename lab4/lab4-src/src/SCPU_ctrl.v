`timescale 1ns / 1ps
`include "defines.vh"

module SCPU_ctrl(
    input  wire [6:0]  Opcode,
    input  wire [2:0]  Fun3,
    input  wire [6:0]  Fun7,
    input  wire [4:0]  Rs1,
    input  wire [4:0]  Rd,
    input  wire        MIO_ready,

    output reg  [2:0]  ImmSel,
    output reg         ALUSrc_B,
    output reg  [1:0]  MemtoReg,
    output reg  [1:0]  Jump,
    output reg         Branch,
    output reg         BranchN,
    output reg         RegWrite,
    output reg         MemRW,
    output reg  [3:0]  ALU_Control,
    output reg         ecall,
    output reg         mret,
    output reg         ill_instr,
    output reg         CPU_MIO
);

    /* TODO(Lab4-2): 实现基础主控制器和 ALU 译码。
       TODO(Lab4-3): 扩展支持 26 条指令的译码。
       TODO(Lab4-4): 支持 ecall/mret，并对系统指令之外的编码拉高 ill_instr。 */
    always @(*) begin
        ImmSel    = `IMM_I;
        ALUSrc_B  = 1'b0;
        MemtoReg  = `MEM_ALU;
        Jump      = `JUMP_NONE;
        Branch    = 1'b0;
        BranchN   = 1'b0;
        RegWrite  = 1'b0;
        MemRW     = 1'b0;
        ALU_Control = `ALU_ADD;
        ecall     = 1'b0;
        mret      = 1'b0;
        ill_instr = 1'b0;
        CPU_MIO   = 1'b0;
    end

endmodule
