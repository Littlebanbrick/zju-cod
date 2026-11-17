`timescale 1ns / 1ps

module RV_Int(
    input  wire        clk,
    input  wire        rst,
    input  wire        INT0,
    input  wire        ecall,
    input  wire        mret,
    input  wire        ill_instr,
    input  wire [31:0] pc_plus4,
    output reg  [31:0] mepc,            // Machine Exception Program Counter: 记下异常出现时的地址，用于 mret 回到原处
    output wire [31:0] mtvec,           // Machine Trap Vector: 跳转目标
    output wire        int_pulse,
    output wire        trap
);

    /* TODO(Lab4-4):
       - 非法指令 -> mtvec = 0x04
       - ecall      -> mtvec = 0x08
       - INT0 上升沿 -> mtvec = 0x0c
       - trap 时保存返回地址到 mepc
       - mret 时从 mepc 恢复执行
       INT0 是电平信号，必须只在上升沿响应一次。 */

    reg INT0_d;             // 用于产生上升沿脉冲
    always @(posedge clk or posedge rst) begin
        if (rst) INT0_d <= 1'b0;
        else     INT0_d <= INT0;
    end

    assign int_pulse    = INT0 & ~INT0_d;
    assign trap         = ill_instr | ecall | int_pulse;
    assign mtvec        = ill_instr ? 32'h00000004 :
                          ecall     ? 32'h00000008 :
                                      32'h0000000c;

    always @(posedge clk or posedge rst) begin
        if (rst)          mepc <= 32'b0;
        else if (trap)    mepc <= pc_plus4;         // 记下返回地址
    end

endmodule
