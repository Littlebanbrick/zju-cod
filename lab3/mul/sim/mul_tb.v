`timescale 1ns/1ps

module mul_tb;

    localparam WIDTH = 16;

    reg                 clk;
    reg                 rst;
    reg  [WIDTH-1:0]    multiplicand;
    reg  [WIDTH-1:0]    multiplier;
    reg                 start;
    wire [2*WIDTH-1:0]  product;
    wire                finish;

    mul #(.WIDTH(WIDTH)) dut (
        .clk          (clk),
        .rst          (rst),
        .multiplicand (multiplicand),
        .multiplier   (multiplier),
        .start        (start),
        .product      (product),
        .finish       (finish)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer i;
    reg [WIDTH-1:0] a_tab [0:2];
    reg [WIDTH-1:0] b_tab [0:2];

    initial begin
        a_tab[0] = 16'h0325;  b_tab[0] = 16'h0799;
        a_tab[1] = 16'hcafe;  b_tab[1] = 16'hbabe;
        a_tab[2] = 16'h0000;  b_tab[2] = 16'hffff;
    end

    initial begin
        // $dumpfile("a.vcd");
        // $dumpvars(0, mul_tb);

        clk          = 0;
        rst          = 1;
        start        = 0;
        multiplicand = 0;
        multiplier   = 0;

        repeat (3) @(negedge clk);
        rst = 0;

        for (i = 0; i < 3; i = i + 1) begin
            @(negedge clk);
            multiplicand = a_tab[i];
            multiplier   = b_tab[i];
            start        = 1;

            @(negedge clk);
            start = 0;

            repeat (20) @(negedge clk);

        end

        $finish;
    end

endmodule