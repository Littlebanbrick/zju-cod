`ifndef LAB4_DEFINES_VH
`define LAB4_DEFINES_VH

// RV32I opcodes
`define OP_LOAD     7'b0000011
`define OP_ALU_IMM  7'b0010011
`define OP_ALU      7'b0110011
`define OP_STORE    7'b0100011
`define OP_BRANCH   7'b1100011
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_LUI      7'b0110111
`define OP_SYSTEM   7'b1110011

// ImmSel
`define IMM_U 3'b000
`define IMM_I 3'b001
`define IMM_S 3'b010
`define IMM_B 3'b011
`define IMM_J 3'b100

// ALU_Control
`define ALU_AND  4'b0000
`define ALU_OR   4'b0001
`define ALU_ADD  4'b0010
`define ALU_SUB  4'b0110
`define ALU_SLT  4'b0111
`define ALU_SLTU 4'b1001
`define ALU_XOR  4'b1100
`define ALU_SRL  4'b1101
`define ALU_SLL  4'b1110
`define ALU_SRA  4'b1111

// Jump
`define JUMP_NONE 2'b00
`define JUMP_JAL  2'b01
`define JUMP_JALR 2'b10

// MemtoReg
`define MEM_ALU  2'b00
`define MEM_RAM  2'b01
`define MEM_PC4  2'b10
`define MEM_IMM  2'b11

`endif
