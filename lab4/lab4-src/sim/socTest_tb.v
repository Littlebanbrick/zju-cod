`timescale 1ns / 1ps

`define TEST_INT

module socTest_tb;
    reg clk;
    reg rst;
    reg INT0;

    integer i;
    integer errors;
    integer checkpoint_seen;
    reg [31:0] expected [0:31];

    reg ill_vector_ok;
    reg ecall_vector_ok;
    reg int_vector_ok;

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

    `ifdef TEST_MORE
    localparam [31:0] CHECK_PC = 32'h000000a4;
    localparam [31:0] COMMIT_PC = 32'h00000000;
    `elsif TEST_INT
    localparam [31:0] CHECK_PC = 32'h000000c4;
    localparam [31:0] COMMIT_PC = 32'h000000c4;
    `else
    localparam [31:0] CHECK_PC = 32'h00000070;
    localparam [31:0] COMMIT_PC = 32'h00000000;
    `endif

    socTest #(
        .ROM_FILE(`ROM_FILE),
        .RAM_FILE(`RAM_FILE)
    ) m0(
        .clk(clk),
        .rst(rst),
        .INT0(INT0)
    );

    always #5 clk = ~clk;

    task init_expected;
        begin
            for (i = 0; i < 32; i = i + 1)
                expected[i] = 32'b0;

            `ifdef TEST_MORE
            expected[1]  = 32'h80000000;
            expected[2]  = 32'h88888000;
            expected[3]  = 32'h80000000;
            expected[5]  = 32'h80000000;
            expected[6]  = 32'h88888000;
            expected[7]  = 32'h80000000;
            expected[8]  = 32'h08888000;
            expected[9]  = 32'hf7778000;
            expected[10] = 32'h80000001;
            expected[11] = 32'h80000000;
            expected[12] = 32'h00000001;
            expected[14] = 32'h10000000;
            expected[15] = 32'h44444000;
            expected[16] = 32'h10000000;
            expected[17] = 32'heeef0000;
            expected[19] = 32'h00000001;
            expected[20] = 32'h00000001;
            expected[22] = 32'h08000000;
            expected[23] = 32'hf7778000;
            expected[24] = 32'h000000a0;
            expected[25] = 32'h000000a8;
            `elsif TEST_INT
            expected[1]  = 32'h80000000;
            expected[2]  = 32'h88888000;
            expected[3]  = 32'h80000000;
            expected[5]  = 32'h80000000;
            expected[6]  = 32'h88888000;
            expected[7]  = 32'h80000000;
            expected[8]  = 32'h08888000;
            expected[9]  = 32'h08888000;
            expected[10] = 32'h80000001;
            expected[11] = 32'h80000000;
            expected[12] = 32'h00000000;
            expected[13] = 32'h00000000;
            expected[14] = 32'h00000001;
            expected[15] = 32'h00000002;
            expected[16] = 32'h66666666;
            expected[17] = 32'h80000002;
            `else
            expected[1]  = 32'h00000001;
            expected[2]  = 32'h00000001;
            expected[3]  = 32'h00000002;
            expected[4]  = 32'h00000003;
            expected[5]  = 32'h00000005;
            expected[6]  = 32'h0000000a;
            expected[7]  = 32'h0000000f;
            expected[8]  = 32'h0000000a;
            expected[9]  = 32'h00000005;
            expected[10] = 32'h00000007;
            expected[11] = 32'h00000008;
            expected[12] = 32'hfffffffe;
            expected[13] = 32'h00000006;
            expected[14] = 32'h00000000;
            expected[15] = 32'h00000001;
            expected[16] = 32'h00000014;
            expected[17] = 32'h0000000b;
            expected[18] = 32'h0000000b;
            expected[19] = 32'h00000002;
            expected[20] = 32'h00000001;
            expected[22] = 32'h55555555;
            expected[23] = 32'haaaaaaaa;
            expected[24] = 32'h55555555;
            expected[25] = 32'haaaaaaaa;
            expected[26] = 32'h00000074;
            `endif
        end
    endtask

    task check_registers;
        input [8*16-1:0] name;
        begin
            for (i = 0; i < 32; i = i + 1) begin
                if (m0.debug_regs[i*32 +: 32] !== expected[i]) begin
                    errors = errors + 1;
                    $display("FAIL %0s x%0d: got %h, expected %h",
                             name, i, m0.debug_regs[i*32 +: 32], expected[i]);
                end
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        INT0 = 1'b0;
        errors = 0;
        checkpoint_seen = 0;
        ill_vector_ok = 1'b0;
        ecall_vector_ok = 1'b0;
        int_vector_ok = 1'b0;
        init_expected();

        #17 rst = 1'b0;
        #20000;

        $fatal(1, "FAIL timeout at pc=%h", m0.PC_out);
    end

    always @(negedge clk) begin
        if (!rst) begin
            `ifdef TEST_INT
            if (m0.PC_out == 32'h00000004 && m0.mepc_o == 32'h00000030) begin
                ill_vector_ok = 1'b1;
                $display("PASS illegal-instruction vector: pc=0x04, mepc=0x30");
            end
            if (m0.PC_out == 32'h00000008 && m0.mepc_o == 32'h00000078) begin
                ecall_vector_ok = 1'b1;
                $display("PASS ecall vector: pc=0x08, mepc=0x78");
            end
            if (m0.PC_out == 32'h00000050 && !INT0) begin
                INT0 = 1'b1;
                $display("INFO drive INT0 high at pc=0x50");
            end
            if (m0.PC_out == 32'h0000000c && m0.mepc_o == 32'h00000054) begin
                int_vector_ok = 1'b1;
                $display("PASS external interrupt vector: pc=0x0c, mepc=0x54");
            end
            `endif

            if (!checkpoint_seen && m0.PC_out == CHECK_PC) begin
                checkpoint_seen = 1;
                if (CHECK_PC == COMMIT_PC) begin
                    check_registers("checkpoint");
                    `ifdef TEST_INT
                    if (!ill_vector_ok || !ecall_vector_ok || !int_vector_ok) begin
                        errors = errors + 1;
                        $display("FAIL vector check: ill=%b ecall=%b int=%b",
                                 ill_vector_ok, ecall_vector_ok, int_vector_ok);
                    end
                    `endif
                    if (errors == 0) begin
                        $display("PASS Lab4 checkpoint pc=%h", CHECK_PC);
                        $finish;
                    end
                    else begin
                        $fatal(1, "FAIL Lab4 checkpoint pc=%h with %0d error(s)", CHECK_PC, errors);
                    end
                end
            end
            else if (checkpoint_seen && m0.PC_out == COMMIT_PC) begin
                // For the base and extended tests, the jump itself writes x26/x25.
                // Check one cycle after the PC checkpoint so that the write is visible.
                check_registers("checkpoint");
                if (errors == 0) begin
                    $display("PASS Lab4 checkpoint pc=%h (commit observed at pc=%h)", CHECK_PC, COMMIT_PC);
                    $finish;
                end
                else begin
                    $fatal(1, "FAIL Lab4 checkpoint pc=%h with %0d error(s)", CHECK_PC, errors);
                end
            end
        end
    end

endmodule
