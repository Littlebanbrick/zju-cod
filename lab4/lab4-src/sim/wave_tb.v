`timescale 1ns / 1ps

module wave_tb;
    reg clk;
    reg rst;
    reg INT0;

    // Bare filenames are the Vivado-friendly default. The Icarus scripts
    // override these macros with -DROM_FILE='"program/...mem"'.
    `ifndef ROM_FILE
    `ifdef TEST_MORE
    `define ROM_FILE "I_mem_more.mem"
    `elsif TEST_INT
    `define ROM_FILE "I_mem_INT.mem"
    `else
    `define ROM_FILE "I_mem_4.mem"
    `endif
    `endif
    `ifndef RAM_FILE
    `define RAM_FILE "D_mem.mem"
    `endif

    socTest #(
        .ROM_FILE(`ROM_FILE),
        .RAM_FILE(`RAM_FILE)
    ) m0(
        .clk(clk),
        .rst(rst),
        .INT0(INT0)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        INT0 = 1'b0;
        #17 rst = 1'b0;
        `ifdef TEST_INT
        #700 INT0 = 1'b1;
        `endif
        #2000 $finish;
    end

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/wave.vcd");
        $dumpvars(0, wave_tb);
    end
endmodule
