`timescale 1ns / 1ps

module MUX2T1_32(
    input  wire [31:0] I0,
    input  wire [31:0] I1,
    input  wire        s,
    output wire [31:0] o
);

    assign o = s ? I1 : I0;

endmodule
