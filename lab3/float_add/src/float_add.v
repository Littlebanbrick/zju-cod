`timescale 1ns / 1ps

module float_add(
	input clk, 
	input rst,
	input [31:0] A,
	input [31:0] B,
	input [1:0] c,      // 00 +, 01 -, 10 *, 11 /
	input en,			// en = 1, begin
	output reg [31:0] result,
	output reg fin		// fin = 1 when finish
);

    wire        sA = A[31];
    wire [7:0]  eA = A[30:23];
    wire [22:0] mA = A[22:0];

    wire        sB = B[31];
    wire [7:0]  eB = B[30:23];
    wire [22:0] mB = B[22:0];

    wire        a_big = (eA >= eB);
    wire [7:0]  e0    = a_big ? eA : eB;
    wire [7:0]  de    = a_big ? (eA - eB) : (eB - eA);

    wire [23:0] ma0 = {1'b1, mA};
    wire [23:0] mb0 = {1'b1, mB};

    wire [23:0] mae = a_big ? ma0 : (ma0 >> de);
    wire [23:0] mbe = a_big ? (mb0 >> de) : mb0;

    wire        same = (sA == sB);

    wire [24:0] sum = same        ? ({1'b0, mae} + {1'b0, mbe}) :
                      (mae >= mbe) ? ({1'b0, mae} - {1'b0, mbe}) :
                                     ({1'b0, mbe} - {1'b0, mae});

    wire        s0 = same ? sA : ((mae >= mbe) ? sA : sB);

    integer i;
    reg [4:0] pos;

    always @(*) begin
        pos = 5'd0;
        for (i = 0; i < 24; i = i + 1)
            if (sum[i])
                pos = i;
    end

    wire [4:0]  shl = 5'd23 - pos;
    wire [7:0]  e1  = sum[24] ? (e0 + 8'd1) : (e0 - {3'b0, shl});
    wire [23:0] m1  = sum[24] ? sum[24:1] : (sum[23:0] << shl);

    wire [31:0] res_c = (sum == 25'd0) ? 32'd0 : {s0, e1, m1[22:0]};

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 32'd0;
            fin    <= 1'b0;
        end
        else begin
            result <= res_c;
            fin    <= en;
        end
    end

endmodule
