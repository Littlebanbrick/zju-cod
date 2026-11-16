`timescale 1ns / 1ps

module RAM_B #(
    parameter AW = 10,
    parameter DW = 32,
    parameter INIT_FILE = "D_mem.mem"
)(
    input  wire          clka,
    input  wire          wea,
    input  wire [AW-1:0] addra,
    input  wire [DW-1:0] dina,
    output wire [DW-1:0] douta
);

    reg [DW-1:0] ram [0:(1<<AW)-1];
    integer i;

    initial begin
        for (i = 0; i < (1<<AW); i = i + 1)
            ram[i] = {DW{1'b0}};
        $readmemh(INIT_FILE, ram);
    end

    always @(posedge clka) begin
        if (wea)
            ram[addra] <= dina;
    end

    assign douta = ram[addra];

endmodule
