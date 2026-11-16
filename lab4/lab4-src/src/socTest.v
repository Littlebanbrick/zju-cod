`timescale 1ns / 1ps

module socTest #(
    parameter ROM_FILE = "I_mem_4.mem",
    parameter RAM_FILE = "D_mem.mem"
)(
    input wire clk,
    input wire rst,
    input wire INT0
);

    wire [31:0]  Addr_out;
    wire [31:0]  Data_out;
    wire         CPU_MIO;
    wire         MemRW;
    wire [31:0]  PC_out;
    wire [31:0]  douta;
    wire [31:0]  spo;
    wire [1023:0] debug_regs;
    wire [31:0]  mepc_o;
    wire [31:0]  mtvec_o;
    wire         trap_o;

    SCPU u0(
        .clk(clk),
        .rst(rst),
        .MIO_ready(1'b0),
        .inst_in(spo),
        .Data_in(douta),
        .INT0(INT0),
        .MemRW(MemRW),
        .CPU_MIO(CPU_MIO),
        .Addr_out(Addr_out),
        .Data_out(Data_out),
        .PC_out(PC_out),
        .debug_regs(debug_regs),
        .mepc_o(mepc_o),
        .mtvec_o(mtvec_o),
        .trap_o(trap_o)
    );

    ROM_D #(
        .AW(10),
        .DW(32),
        .INIT_FILE(ROM_FILE)
    ) u2(
        .a(PC_out[11:2]),
        .spo(spo)
    );

    RAM_B #(
        .AW(10),
        .DW(32),
        .INIT_FILE(RAM_FILE)
    ) u1(
        .clka(clk),
        .wea(MemRW),
        .addra(Addr_out[11:2]),
        .dina(Data_out),
        .douta(douta)
    );

endmodule
