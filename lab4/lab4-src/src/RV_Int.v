`timescale 1ns / 1ps

module RV_Int(
    input  wire        clk,
    input  wire        rst,
    input  wire        INT0,
    input  wire        ecall,
    input  wire        mret,
    input  wire        ill_instr,
    input  wire [31:0] pc_plus4,
    output reg  [31:0] mepc,
    output wire [31:0] mtvec,
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
    assign mtvec     = 32'b0;
    assign int_pulse = 1'b0;
    assign trap      = 1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst)
            mepc <= 32'b0;
    end

endmodule
