`timescale 1ns / 1ps
`include "defines.vh"

module SCPU_ctrl(
    input  wire [6:0]  Opcode,
    input  wire [2:0]  Fun3,
    input  wire [6:0]  Fun7,
    input  wire [4:0]  Rs1,         // rs1 寄存器编号
    input  wire [4:0]  Rd,          // rd 寄存器编号
    input  wire        MIO_ready,   // ？？？

    output reg  [2:0]  ImmSel,      // 立即数类型
    output reg         ALUSrc_B,    // ALU 的 B 是 R2 还是立即数
    output reg  [1:0]  MemtoReg,    //
    output reg  [1:0]  Jump,        //
    output reg         Branch,      //
    output reg         BranchN,     //
    output reg         RegWrite,    // 寄存器写使能
    output reg         MemRW,       // RAM 写使能
    output reg  [3:0]  ALU_Control, // ALU 哪种运算
    output reg         ecall,
    output reg         mret,
    output reg         ill_instr,   // 对系统指令之外的编码拉高 ill_instr
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

        case (Opcode)
            `OP_ALU: begin          // R 型，内部还要看 func7, func3
                RegWrite  = 1'b1;         // 要写回
                ALUSrc_B  = 1'b0;         // B 口用 rs2
                MemtoReg  = `MEM_ALU;     // 写回 ALU 结果
                case ({Fun7, Fun3})
                    10'b0000000000: ALU_Control = `ALU_ADD;
                    10'b0100000000: ALU_Control = `ALU_SUB;
                    10'b0000000010: ALU_Control = `ALU_SLT;
                    10'b0000000100: ALU_Control = `ALU_XOR;
                    10'b0000000101: ALU_Control = `ALU_SRL;
                    10'b0000000110: ALU_Control = `ALU_OR;
                    10'b0000000111: ALU_Control = `ALU_AND;
                    // 4.3 sltu, sra, sll
                    10'b0000000011: ALU_Control = `ALU_SLTU;
                    10'b0100000101: ALU_Control = `ALU_SRA;
                    10'b0000000001: ALU_Control = `ALU_SLL;
                    default:        ill_instr = 1'b1;
                endcase
            end

            `OP_ALU_IMM: begin      // I 型，内部还要看 func3
                RegWrite  = 1'b1;         // 要写回
                ALUSrc_B  = 1'b1;         // B 口用立即数
                ImmSel    = `IMM_I;
                MemtoReg  = `MEM_ALU;
                case (Fun3) 
                    3'b000:         ALU_Control = `ALU_ADD;
                    3'b010:         ALU_Control = `ALU_SLT;
                    3'b100:         ALU_Control = `ALU_XOR;
                    3'b110:         ALU_Control = `ALU_OR;
                    3'b111:         ALU_Control = `ALU_AND;
                    // 4.3 sltiu, srai, slli （立即数版本）
                    // 比较 Fun7，0000000的是 srli，0100000的是 srai
                    3'b101: begin
                        case (Fun7)
                            7'b0000000: ALU_Control = `ALU_SRL;
                            7'b0100000: ALU_Control = `ALU_SRA;
                            default: ill_instr = 1'b1;
                        endcase
                    end
                    3'b011:         ALU_Control = `ALU_SLTU;
                    3'b001:         ALU_Control = `ALU_SLL;
                    default:        ill_instr = 1'b1;
                endcase
            end

            `OP_LOAD: begin                   // lw
                ImmSel      = `IMM_I;
                ALUSrc_B    = 1'b1;
                MemtoReg    = `MEM_RAM;       // 写回 RAM 读回的数据
                RegWrite    = 1'b1;
                ALU_Control = `ALU_ADD;       // rs1 + imm = 地址
            end

            `OP_STORE: begin                  // sw
                ImmSel      = `IMM_S;
                ALUSrc_B    = 1'b1;
                MemRW       = 1'b1;           // 写内存
                RegWrite    = 1'b0;
                ALU_Control = `ALU_ADD;
            end

            `OP_BRANCH: begin                 // beq and bne
                ImmSel      = `IMM_B;
                ALUSrc_B    = 1'b0;
                ALU_Control = `ALU_SUB;       // 相减，用 zero 判断
                case (Fun3)
                    3'b000: Branch  = 1'b1;
                    3'b001: BranchN = 1'b1;
                    default: ill_instr = 1'b1;
                endcase
            end

            `OP_JAL: begin                    // jal
                ImmSel      = `IMM_J;
                Jump        = `JUMP_JAL;
                MemtoReg    = `MEM_PC4;       // 写回 PC+4
                RegWrite    = 1'b1;
            end
            
            `OP_JALR: begin
                ImmSel      = `IMM_I;
                Jump        = `JUMP_JALR;
                MemtoReg    = `MEM_PC4;       // 写回 PC+4
                RegWrite    = 1'b1;           // 写 rd
            end

            `OP_LUI: begin                    // Load Upper Immediate: 把 20 位立即数装进寄存器的高 20 位，低 12 位补 0
                ImmSel      = `IMM_U;
                MemtoReg    = `MEM_IMM;
                RegWrite    = 1'b1;
            end

            `OP_SYSTEM:  ; // lab4.4
            default: ill_instr = 1'b1;
        endcase
    end

endmodule
