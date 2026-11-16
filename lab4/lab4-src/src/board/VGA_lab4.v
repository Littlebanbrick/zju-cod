`timescale 1ns / 1ps

// Lab4 VGA wrapper. The Lab2 VGA submodules still provide the video timing and
// character renderer; this wrapper only splits the packed GPR debug bus into
// the individual register inputs expected by VgaDebugger.
module VGA_lab4(
    input  wire         clk_25m,
    input  wire         clk_100m,
    input  wire         rst,
    input  wire [31:0]  pc,
    input  wire [31:0]  inst,
    input  wire [31:0]  alu_res,
    input  wire         mem_wen,
    input  wire [31:0]  dmem_o_data,
    input  wire [31:0]  dmem_i_data,
    input  wire [31:0]  dmem_addr,
    input  wire [1023:0] debug_regs,
    input  wire [31:0]  mepc_o,
    input  wire [31:0]  mtvec_o,

    output wire         hs,
    output wire         vs,
    output wire [3:0]   vga_r,
    output wire [3:0]   vga_g,
    output wire [3:0]   vga_b
);

    wire [9:0]  vga_x;
    wire [8:0]  vga_y;
    wire        video_on;
    wire        display_wen;
    wire [11:0] display_w_addr;
    wire [7:0]  display_w_data;

    VgaController vga_controller(
        .clk       (clk_25m),
        .rst       (rst),
        .vga_x     (vga_x),
        .vga_y     (vga_y),
        .hs        (hs),
        .vs        (vs),
        .video_on  (video_on)
    );

    VgaDisplay vga_display(
        .clk       (clk_100m),
        .video_on  (video_on),
        .vga_x     (vga_x),
        .vga_y     (vga_y),
        .vga_r     (vga_r),
        .vga_g     (vga_g),
        .vga_b     (vga_b),
        .wen       (display_wen),
        .w_addr    (display_w_addr),
        .w_data    (display_w_data)
    );

    VgaDebugger vga_debugger(
        .clk            (clk_100m),
        .display_wen    (display_wen),
        .display_w_addr (display_w_addr),
        .display_w_data (display_w_data),
        .pc             (pc),
        .inst           (inst),
        .rs1            (5'b0),
        .rs1_val        (32'b0),
        .rs2            (5'b0),
        .rs2_val        (32'b0),
        .rd             (5'b0),
        .reg_i_data     (32'b0),
        .reg_wen        (1'b0),
        .is_imm         (1'b0),
        .is_auipc       (1'b0),
        .is_lui         (1'b0),
        .imm            (32'b0),
        .a_val          (32'b0),
        .b_val          (32'b0),
        .alu_ctrl       (4'b0),
        .cmp_ctrl       (3'b0),
        .alu_res        (alu_res),
        .cmp_res        (1'b0),
        .is_branch      (1'b0),
        .is_jal         (1'b0),
        .is_jalr        (1'b0),
        .do_branch      (1'b0),
        .pc_branch      (32'b0),
        .mem_wen        (mem_wen),
        .mem_ren        (1'b0),
        .dmem_o_data    (dmem_o_data),
        .dmem_i_data    (dmem_i_data),
        .dmem_addr      (dmem_addr),
        .csr_wen        (1'b0),
        .csr_ind        (12'b0),
        .csr_ctrl       (2'b0),
        .csr_r_data     (32'b0),
        .x0             (debug_regs[0*32 +: 32]),
        .ra             (debug_regs[1*32 +: 32]),
        .sp             (debug_regs[2*32 +: 32]),
        .gp             (debug_regs[3*32 +: 32]),
        .tp             (debug_regs[4*32 +: 32]),
        .t0             (debug_regs[5*32 +: 32]),
        .t1             (debug_regs[6*32 +: 32]),
        .t2             (debug_regs[7*32 +: 32]),
        .s0             (debug_regs[8*32 +: 32]),
        .s1             (debug_regs[9*32 +: 32]),
        .a0             (debug_regs[10*32 +: 32]),
        .a1             (debug_regs[11*32 +: 32]),
        .a2             (debug_regs[12*32 +: 32]),
        .a3             (debug_regs[13*32 +: 32]),
        .a4             (debug_regs[14*32 +: 32]),
        .a5             (debug_regs[15*32 +: 32]),
        .a6             (debug_regs[16*32 +: 32]),
        .a7             (debug_regs[17*32 +: 32]),
        .s2             (debug_regs[18*32 +: 32]),
        .s3             (debug_regs[19*32 +: 32]),
        .s4             (debug_regs[20*32 +: 32]),
        .s5             (debug_regs[21*32 +: 32]),
        .s6             (debug_regs[22*32 +: 32]),
        .s7             (debug_regs[23*32 +: 32]),
        .s8             (debug_regs[24*32 +: 32]),
        .s9             (debug_regs[25*32 +: 32]),
        .s10            (debug_regs[26*32 +: 32]),
        .s11            (debug_regs[27*32 +: 32]),
        .t3             (debug_regs[28*32 +: 32]),
        .t4             (debug_regs[29*32 +: 32]),
        .t5             (debug_regs[30*32 +: 32]),
        .t6             (debug_regs[31*32 +: 32]),
        .mstatus_o      (32'b0),
        .mcause_o       (32'b0),
        .mepc_o         (mepc_o),
        .mtval_o        (32'b0),
        .mtvec_o        (mtvec_o),
        .mie_o          (32'b0),
        .mip_o          (32'b0)
    );

endmodule
