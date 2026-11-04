`timescale 1ns/1ps

module div_tb;

    localparam WIDTH = 16;

    reg                 clk;
    reg                 rst;
    reg  [WIDTH-1:0]    dividend;
    reg  [WIDTH-1:0]    divisor;
    reg                 start;
    wire [WIDTH-1:0]    quotient;
    wire [WIDTH-1:0]    remainder;
    wire                finish;

    div #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .dividend  (dividend),
        .divisor   (divisor),
        .finish    (finish),
        .quotient  (quotient),
        .remainder (remainder)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer i;
    reg [WIDTH-1:0] a_tab [0:2];
    reg [WIDTH-1:0] b_tab [0:2];

    initial begin
        a_tab[0] = 16'h0325;  b_tab[0] = 16'h0799;
        a_tab[1] = 16'hcafe;  b_tab[1] = 16'hbabe;
        a_tab[2] = 16'hffff;  b_tab[2] = 16'h0001;
    end

    initial begin
        $dumpfile("a.vcd");
        $dumpvars(0, div_tb);

        clk      = 0;
        rst      = 1;
        start    = 0;
        dividend = 0;
        divisor  = 0;

        repeat (3) @(negedge clk);
        rst = 0;

        for (i = 0; i < 3; i = i + 1) begin
            @(negedge clk);
            dividend = a_tab[i];
            divisor  = b_tab[i];
            start    = 1;

            @(negedge clk);
            start = 0;

            repeat (20) @(negedge clk);
        end

        $finish;
    end

endmodule
