`timescale 1ns / 1ps
`include "defines.vh"

module DataPath(
    input  wire         clk,
    input  wire         rst,
    input  wire [31:0]  inst_field,     // ROM 组合读回的 32 位指令
    input  wire [31:0]  Data_in,        // RAM 读回的数据，lw 用，经 MemtoReg 选中后写回寄存器
    input  wire [3:0]   ALU_Control,    // ALU 做哪种运算
    input  wire [2:0]   ImmSel,         // ImmGen 输出哪种立即数（I/S/B/J/U）
    input  wire [1:0]   MemtoReg,       // 写回数据取 ALU 结果 / RAM 读回 / PC+4 / 立即数
    input  wire         ALUSrc_B,       // ALU 的 B 是 R2 还是立即数
    input  wire [1:0]   Jump,           // 下一 PC 取不跳 / jal / jalr
    input  wire         Branch,         // beq 成立时跳转
    input  wire         BranchN,        // bne 成立时跳转
    input  wire         RegWrite,       // 寄存器堆写使能
    input  wire         INT0,           // 4.4
    input  wire         ecall,          // 4.4
    input  wire         mret,           // 4.4
    input  wire         ill_instr,      // 4.4

    output wire [31:0]  PC_out,         // 32 位字节地址，送到 ROM；socTest 里取 PC_out[11:2] 当字地址
    output wire [31:0]  Data_out,       // R2 的值，即 sw 要写进内存的数据
    output wire [31:0]  ALU_out,        // ALU 结果，同时作为访存地址
    output wire [1023:0] debug_regs,
    output wire [31:0]  mepc_o,         // 4.4
    output wire [31:0]  mtvec_o,        // 4.4
    output wire         trap_o          // 4.4
);

    /* TODO(Lab4-1): 完成 PC 更新、寄存器堆读写、ALU 输入选择、
       立即数选择、写回选择，以及分支/jal/jalr 下一 PC 选择。 */
    
    // PC_out

    wire [31:0] PC_next;

    REG32 u_pc(
        .clk (clk),
        .rst (rst),
        .CE  (1'b1),
        .D   (PC_next),
        .Q   (PC_out)
    );

    wire [31:0] Imm;
    ImmGen u_immgen (.ImmSel(ImmSel), .inst_field(inst_field), .Imm_out(Imm));

    wire [31:0] PC4;                                    // 顺序执行
    add_32 u_pc4 (.a(PC_out), .b(32'd4), .c(PC4));      // PC4 = PC_out + 4

    wire [31:0] PCBranch;                               // 跳转到的地址
    add_32 u_pcb (.a(PC_out), .b(Imm), .c(PCBranch));   // PC相对寻址：指令里存的是相对当前 PC 的偏移量

    wire [31:0] R1, R2;                                 // rs1 和 rs2 的值
    wire [31:0] JALR_sum;
    add_32 u_jalr (.a(R1), .b(Imm), .c(JALR_sum));      // 寄存器相对寻址：地址来自寄存器

    wire [31:0] JALR_tgt;                               // 寄存器寻址目标
    assign JALR_tgt = {JALR_sum[31:1], 1'b0};           // jalr 的目标地址最低位强制清零，显式避免跳转目标非法

    wire branch_taken, zero;
    // beq 且两数相等，或 bne 且两数不等
    assign branch_taken = (Branch & zero) | (BranchN & ~zero);

    wire [31:0] alu_b, alu_res;

    MUX2T1_32 u_alusrc (                                 // ALU 的 B 口：寄存器还是立即数
        .I0 (R2),
        .I1 (Imm),
        .s  (ALUSrc_B),
        .o  (alu_b)
    );

    ALU u_alu (
        .A              (R1),
        .B              (alu_b),
        .ALU_operation  (ALU_Control),
        .res            (alu_res),
        .zero           (zero)
    );

    ///////////////////////////////////////////////////////////////
    //  31      25 24    20 19    15 14  12 11    7 6      0     //
    // ┌──────────┬────────┬────────┬──────┬────────┬────────┐   //
    // │  funct7  │  rs2   │  rs1   │funct3│   rd   │ opcode │   //
    // └──────────┴────────┴────────┴──────┴────────┴────────┘   //
    //     7 位      5 位     5 位    3 位    5 位     7 位        //
    ///////////////////////////////////////////////////////////////

    wire [4:0]  Wt_addr;                                // rd 的编号
    wire [31:0] Wt_data;

    assign Wt_addr = inst_field[11:7];

    MUX4T1_32 u_wb (                                     // 写回数据来源
        .s  (MemtoReg),
        .I0 (alu_res),      // MEM_ALU
        .I1 (Data_in),      // MEM_RAM
        .I2 (PC4),          // MEM_PC4
        .I3 (Imm),          // MEM_IMM
        .o  (Wt_data)
    );

    Regs u_regs (
        .clk        (clk),
        .rst        (rst),
        .Rs1_addr   (inst_field[19:15]),    // rs1 的编号
        .Rs2_addr   (inst_field[24:20]),    // rs2 的编号
        .Wt_addr    (Wt_addr),              // rd 的编号
        .Wt_data    (Wt_data),
        .RegWrite   (RegWrite),
        .Rs1_data   (R1),                   // rs1 的值
        .Rs2_data   (R2),                   // rs2 的值
        .debug_regs (debug_regs)
    );

    assign Data_out   = R2;
    assign ALU_out    = alu_res;
    // 不用再 assign debug_regs = ??? 了

    /* TODO(Lab4-4): 接入 RV_Int，并完成 trap/mret 的下一 PC 选择。 */
    wire [31:0] mepc, mtvec;
    wire        trap;
    wire        int_pulse;

    RV_Int u_rint (
        .clk       (clk),
        .rst       (rst),
        .INT0      (INT0),
        .ecall     (ecall),
        .mret      (mret),
        .ill_instr (ill_instr),
        .pc_plus4  (PC4),          // PC+4
        .mepc      (mepc),
        .mtvec     (mtvec),
        .int_pulse (int_pulse),
        .trap      (trap)
    );

    assign mepc_o  = mepc;
    assign mtvec_o = mtvec;
    assign trap_o  = trap;

    assign PC_next =    trap ? mtvec :
                        mret ? mepc  :
                        (Jump == `JUMP_JAL)  ? PCBranch :
                        (Jump == `JUMP_JALR) ? JALR_tgt :
                        branch_taken         ? PCBranch : PC4;

endmodule
