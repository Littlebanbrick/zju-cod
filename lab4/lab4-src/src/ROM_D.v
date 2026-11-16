`timescale 1ns / 1ps

module ROM_D #(
    parameter AW = 10,
    parameter DW = 32,
    parameter INIT_FILE = "I_mem_4.mem"
)(
    input  wire [AW-1:0] a,
    output wire [DW-1:0] spo
);

    reg [DW-1:0] rom [0:(1<<AW)-1];
    integer i;

    initial begin
        for (i = 0; i < (1<<AW); i = i + 1)
            rom[i] = {DW{1'b0}};
        $readmemh(INIT_FILE, rom);
    end

    assign spo = rom[a];

endmodule
