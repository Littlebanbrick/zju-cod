`timescale 1ns / 1ps
`include "defines.vh"

module SCPU(
    input  wire         clk,
    input  wire         rst,
    input  wire         MIO_ready,
    input  wire [31:0]  inst_in,
    input  wire [31:0]  Data_in,
    input  wire         INT0,

    output wire         MemRW,
    output wire         CPU_MIO,
    output wire [31:0]  Addr_out,
    output wire [31:0]  Data_out,
    output wire [31:0]  PC_out,
    output wire [1023:0] debug_regs,
    output wire [31:0]  mepc_o,
    output wire [31:0]  mtvec_o,
    output wire         trap_o
);

    wire [2:0]  ImmSel;
    wire        ALUSrc_B;
    wire [1:0]  MemtoReg;
    wire [1:0]  Jump;
    wire        Branch;
    wire        BranchN;
    wire        RegWrite;
    wire [3:0]  ALU_Control;
    wire        ecall;
    wire        mret;
    wire        ill_instr;

    SCPU_ctrl ctrl_u(
        .Opcode(inst_in[6:0]),
        .Fun3(inst_in[14:12]),
        .Fun7(inst_in[31:25]),
        .Rs1(inst_in[19:15]),
        .Rd(inst_in[11:7]),
        .MIO_ready(MIO_ready),
        .ImmSel(ImmSel),
        .ALUSrc_B(ALUSrc_B),
        .MemtoReg(MemtoReg),
        .Jump(Jump),
        .Branch(Branch),
        .BranchN(BranchN),
        .RegWrite(RegWrite),
        .MemRW(MemRW),
        .ALU_Control(ALU_Control),
        .ecall(ecall),
        .mret(mret),
        .ill_instr(ill_instr),
        .CPU_MIO(CPU_MIO)
    );

    DataPath datapath_u(
        .clk(clk),
        .rst(rst),
        .inst_field(inst_in),
        .Data_in(Data_in),
        .ALU_Control(ALU_Control),
        .ImmSel(ImmSel),
        .MemtoReg(MemtoReg),
        .ALUSrc_B(ALUSrc_B),
        .Jump(Jump),
        .Branch(Branch),
        .BranchN(BranchN),
        .RegWrite(RegWrite),
        .INT0(INT0),
        .ecall(ecall),
        .mret(mret),
        .ill_instr(ill_instr),
        .PC_out(PC_out),
        .Data_out(Data_out),
        .ALU_out(Addr_out),
        .debug_regs(debug_regs),
        .mepc_o(mepc_o),
        .mtvec_o(mtvec_o),
        .trap_o(trap_o)
    );

endmodule
