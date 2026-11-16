`timescale 1ns / 1ps

// Small gate wrappers needed by the legacy MC_14495 seven-segment decoder.
module INV(input wire I, output wire O);
    assign O = ~I;
endmodule

module AND2(input wire I0, input wire I1, output wire O);
    assign O = I0 & I1;
endmodule

module AND3(input wire I0, input wire I1, input wire I2, output wire O);
    assign O = I0 & I1 & I2;
endmodule

module AND4(input wire I0, input wire I1, input wire I2, input wire I3, output wire O);
    assign O = I0 & I1 & I2 & I3;
endmodule

module OR2(input wire I0, input wire I1, output wire O);
    assign O = I0 | I1;
endmodule

module OR3(input wire I0, input wire I1, input wire I2, output wire O);
    assign O = I0 | I1 | I2;
endmodule

module OR4(input wire I0, input wire I1, input wire I2, input wire I3, output wire O);
    assign O = I0 | I1 | I2 | I3;
endmodule
