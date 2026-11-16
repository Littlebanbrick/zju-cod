`timescale 1ns / 1ps

module Regs(
    input  wire          clk,
    input  wire          rst,
    input  wire [4:0]    Rs1_addr,
    input  wire [4:0]    Rs2_addr,
    input  wire [4:0]    Wt_addr,
    input  wire [31:0]   Wt_data,
    input  wire          RegWrite,
    output wire [31:0]   Rs1_data,
    output wire [31:0]   Rs2_data,
    output wire [1023:0] debug_regs
);

    /* TODO(Lab4-1): 实现 32 x 32 位寄存器堆（x0 恒为 0）。
       debug_regs[32*i +: 32] 必须输出 x_i，供 VGA 调试使用。 */
    reg [31:0] register [1:31];
    integer i;

    assign Rs1_data = (Rs1_addr == 5'd0) ? 32'h0 : register[Rs1_addr];
    assign Rs2_data = (Rs2_addr == 5'd0) ? 32'h0 : register[Rs2_addr];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 1; i <= 31; i = i + 1) begin
                register[i] <= 32'h0;
            end
        end
        else if (RegWrite && (Wt_addr != 5'd0)) begin
            register[Wt_addr] <= Wt_data;
        end
        else begin
            // Do nothing
        end
    end



    reg [1023:0] dbg;
    integer j;

    always @(*) begin
        dbg = 1024'b0;
        for (j = 1; j <= 31; j = j + 1)
            dbg[32*j +: 32] = register[j];
    end

    assign debug_regs = dbg;

endmodule
