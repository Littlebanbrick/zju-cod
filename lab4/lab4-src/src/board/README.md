# 上板包装

`CSSTE_lab4.v` 复用 Lab 2 的板级外设，保留 `CSSTE` 的引脚接口；`VGA_lab4.v` 只把 `debug_regs` 拆成 VGA 调试器需要的 32 个寄存器端口。

把本目录文件、`lab4/src` 中的 CPU 文件，以及 Lab 2 中以下源文件加入 Vivado 工程：

- `04-MIO_BUS`
- `05-Multi_8CH32`
- `06-Seg7_Dev`
- `07-SPIO`
- `08-clk_div`
- `09-SAnti_jitter`
- `10-Counter_x`
- `11-VGA/Hex2Ascii.v`
- `11-VGA/VgaController.v`
- `11-VGA/VgaDisplay.v`
- `11-VGA/VgaDebugger.v`

不要同时加入 Lab 2 的 `01-SCPU/SCPU.v`、`02-ROM_D/ROM_D.v`、`03-RAM_B/RAM_B.v`、`11-VGA/VGA.v` 和 `CSSTE.v`，否则会与本工程模块重名。

Vivado 的 `$readmemh` 相对于仿真/综合运行目录查找文件。因此 `CSSTE_lab4.v` 顶部使用不带 `program/` 的宏：

```verilog
`ifndef LAB4_ROM_FILE
`define LAB4_ROM_FILE "I_mem_INT.mem"
`endif
`ifndef LAB4_RAM_FILE
`define LAB4_RAM_FILE "D_mem.mem"
`endif
```

把 `program/*.mem` 复制到 Vivado 运行目录（如 `<工程名>.sim/sim_1/behav/xsim/`），或把宏改成绝对路径。`font_8x16.mem` 和 `vga_debugger.mem` 同理：放到运行目录，或修改 `VgaDisplay.v` 中的 `$readmemh` 路径。
