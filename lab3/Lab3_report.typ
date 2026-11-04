// COD 实验报告 —— Lab 3：复杂操作实现
// 本文件基于 report_template.typ 撰写

// ===== 全局样式 =====

// 代码块：浅灰底、小字号、等宽字体
#show raw.where(block: true): set block(
  fill: luma(250),
  inset: 6pt,
  radius: 3pt,
)
#show raw.where(block: true): set text(
  size: 9pt,
  font: ("Courier New", "NSimSun", "SimSun", "Microsoft YaHei UI"),
)
#show raw.where(block: false): set text(
  font: ("Courier New", "NSimSun", "SimSun", "Microsoft YaHei UI"),
)
#show raw.where(block: true): set par(leading: 1.15em)

// 表格：统一边框、字号与行距
#show table: set table(stroke: 0.2pt)
#show table.cell: set text(size: 12pt)
#show table.cell: set par(leading: 0.3em, spacing: 0.5em)
#show table.cell.where(y: 0): set block(above: 0.5em, below: 0.5em)

// 公式：块级公式加浅灰底、降字号；行内公式仅降字号
#show math.equation.where(block: true): set text(size: 12pt)
#show math.equation.where(block: true): it => block(
  fill: luma(245),
  inset: 8pt,
  radius: 3pt,
)[#it]
#show math.equation.where(block: false): set text(size: 12pt)

// 页面：A4、页码、页眉页脚
#set page(
  paper: "a4",
  margin: (left: 2.6cm, right: 2.6cm, top: 2.4cm, bottom: 2.8cm),
  numbering: "1",
  number-align: bottom + center,
  header: context [
    #text(size: 12pt, fill: gray.darken(25%))[ZJU / Computer Organization]
    #h(1fr)
    #text(size: 12pt, fill: gray.darken(25%))[#datetime.today().display("[month repr:short] [day], [year]")]
  ],
  footer: context align(center)[
    #text(size: 11pt, fill: gray.darken(50%))[#counter(page).display()]
  ],
)

// 正文：字体、字号、段落
#set text(
  font: ("Times New Roman", "Georgia"),
  size: 14pt,
  lang: "en",
)
#set par(
  justify: true,
  first-line-indent: 0em,
  leading: 0.75em,
  spacing: 1em,
)

// 标题层级
#set heading(numbering: "1.")
#show heading.where(level: 1): it => [
  #pagebreak(weak: true)
  #v(0.9em)
  #text(size: 20pt, weight: "bold", it.body)
  #v(0.35em)
]
#show heading.where(level: 2): it => [
  #v(0.55em)
  #text(size: 15pt, weight: "semibold", it.body)
  #v(0.25em)
]
#show heading.where(level: 3): it => [
  #v(0.35em)
  #text(size: 13pt, weight: "semibold", it.body)
  #v(0.15em)
]

// 图表标题
#show figure.caption: it => [
  #set text(size: 10pt, fill: gray.darken(40%))
  #it.supplement
  #context it.counter.display(it.numbering)
  #it.separator
  #it.body
]

// ===== 封面 =====
#align(center + horizon)[
  #v(0%)
  #text(size: 35pt, weight: "bold")[
    Lab 3
    \
    复杂操作实现
  ]
  #image("icon_ZJU.png", width: 40%)
  #v(2em)
  #text(size: 20pt)[作者：王传宇 3250102681]
  #v(0.5em)
  #text(size: 20pt)[指导教师：杨坤]
  #v(0.5em)
  #text(size: 20pt)[时间：2026-10-27]
  #v(0.5em)
]

#pagebreak()

// ===== 正文 =====

= 一、实验背景与目标

本实验实现三个多周期运算部件：无符号整数乘法器、无符号整数除法器和单精度浮点加法器（Bonus）。乘除法器采用"移位 + 迭代"的结构，用 16 个时钟周期完成一次运算；浮点加法器按 IEEE 754 的对阶、尾数求和、规格化流程实现。

本实验不上板，验证方式为模块仿真；器件为 xc7a100tcsg324-1，工具为 Vivado。

= 二、整数乘法器

== 1. 算法

原始实现把部分积与被乘数分开存放，每拍判断乘数最低位、加一次、再各自移位：

```
O ← 0                                  // O 为 2N 位
for _ in 0..15:
    O ← O + A × B[0]
    A ← A << 1                          // A 已零扩展到 2N 位
    B ← B >> 1
```

优化实现把被乘数与部分积合并到一个 2N 位寄存器里，加法器只需 N 位：

```
O ← {0, A}
for _ in 0..15:
    O ← { left(O) + B × O[0], right(O) } >> 1
```

`left(O)` 是高 N 位（部分积），`right(O)` 是低 N 位（被乘数）。每拍把 `O[0]` 对应的位加到高半部分，再整体右移，下一位自然顶到 `O[0]`。

== 2. 实现

两版共用一个三状态机与 16 位计数器：`IDLE` 装载，`BUSY` 迭代 16 拍，`DONE` 保持结果并置 `finish`。两版差别只在 `BUSY`：

```verilog
// 原始实现
if (B[0])
    product <= product + A;
A <= A << 1;
B <= B >> 1;
```

```verilog
// 优化实现：高位条件加 B，与低半部分拼接后整体右移
product <= { ({1'b0, product[2*WIDTH-1:WIDTH]} + (product[0] ? {1'b0, B} : {(WIDTH+1){1'b0}})),
             product[WIDTH-1:0] } >> 1;
```

优化版的加法扩到 N+1 位，是为了保住 `left(O) + B` 的进位——这个进位右移后正好落在结果的最高位。

== 3. 仿真结果

图 1 是原始实现计算 `0x0325 × 0x0799` 的波形。`product` 不是一次得出，而是逐拍累加：

```
00000325 → 00001C4D → 00004E9D → 0001E11D → 0005061D → 000B501D → 0017E41D
```

共 7 次跳变，正好对应乘数 `0x0799` 二进制中的 7 个 1；两次跳变之间的平拍是 `B[0] = 0`，只移位不加。图 2 是优化版对同一组数据的波形，最终结果相同。

#figure(image("0325mul0799.png", width: 90%), caption: [原始实现的乘法波形（`0x0325 × 0x0799`）], supplement: [图])

#figure(image("0325mul0799_opt.png", width: 90%), caption: [优化实现的乘法波形（`0x0325 × 0x0799`）], supplement: [图])

#figure(image("cafemulbabe.png", width: 90%), caption: [乘法波形（`0xCAFE × 0xBABE`）], supplement: [图])

#figure(image("0000mulffff.png", width: 90%), caption: [乘法波形（`0x0000 × 0xFFFF`）], supplement: [图])

表 1 汇总三组用例。第三组 `0x0000 × 0xFFFF` 从第一拍起就显示 `00000000`：装载后 `product` 为 0，而被乘数为 0，每拍加的都是 0，寄存器始终不变，这是可以预料的。

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    table.header([被乘数], [乘数], [预期积], [实测积]),
    table.hline(),
    [`0x0325`], [`0x0799`], [`0x0017E41D`], [`0x0017E41D`],
    [`0xCAFE`], [`0xBABE`], [`0x94133484`], [`0x94133484`],
    [`0x0000`], [`0xFFFF`], [`0x00000000`], [`0x00000000`],
  ),
  caption: [乘法器的预期与实测结果],
  supplement: [表],
  kind: table,
)

= 三、整数除法器

== 1. 算法

寄存器 `O` 为 2N 位，高半部分存余数、低半部分存被除数（后来逐步被商占据）：

```
O ← {0, A}
for _ in 0..15:
    O ← O << 1
    if (left(O) ≥ B):
        O ← { left(O) − B, right(O) } + 1
output { r, q } = O                  // 高 N 位余数，低 N 位商
```

第 3 步左移把被除数的下一位拉进余数；第 4 步比较，够减就减，并在最低位补 1 作为商位（左移后最低位必为 0，所以置 1 就等于记商）。

== 2. 实现

```verilog
BUSY: begin
    O = O << 1;
    if (O[2*WIDTH-1:WIDTH] >= B)
        O = {O[2*WIDTH-1:WIDTH] - B, O[WIDTH-1:0]} + 1'b1;

    cnt <= cnt + 6'd1;
    if (cnt == WIDTH - 1)
        state <= DONE;
end
```

左移用阻塞赋值，使紧随其后的比较读到移位后的值。若改用非阻塞赋值，比较读到的仍是移位前的旧值，逻辑就错了。余数与商直接由寄存器切片输出：

```verilog
assign quotient  = O[WIDTH-1:0];
assign remainder = O[2*WIDTH-1:WIDTH];
```

== 3. 仿真结果

#figure(image("0325div0799.png", width: 75%), caption: [除法波形（`0x0325 ÷ 0x0799`）], supplement: [图])

#figure(image("cafedivbabe.png", width: 75%), caption: [除法波形（`0xCAFE ÷ 0xBABE`）], supplement: [图])

#figure(image("ffffdiv0001.png", width: 75%), caption: [除法波形（`0xFFFF ÷ 0x0001`）], supplement: [图])

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    table.header([被除数], [除数], [预期商 / 余数], [实测商 / 余数]),
    table.hline(),
    [`0x0325`], [`0x0799`], [`0x0000` / `0x0325`], [`0x0000` / `0x0325`],
    [`0xCAFE`], [`0xBABE`], [`0x0001` / `0x1040`], [`0x0001` / `0x1040`],
    [`0xFFFF`], [`0x0001`], [`0xFFFF` / `0x0000`], [`0xFFFF` / `0x0000`],
  ),
  caption: [除法器的预期与实测结果],
  supplement: [表],
  kind: table,
)

第一组被除数小于除数，商为 0、余数即被除数本身，可用来自查。第三组 `0xFFFF ÷ 1` 首拍就得到最终结果：`O` 的初值是 `{0, 0xFFFF}`，低半部分本来就是 0xFFFF；而除数为 1 时每拍"左移—减 1—置商位"之后 `O` 恰好不变，所以波形上商自始至终是 `0xFFFF`、余数始终为 0。

= 四、浮点加法器

== 1. 算法

IEEE 754 单精度格式为 `S(1) | E(8) | M(23)`，规格数的真值为 $(-1)^S times 1.M times 2^(E-127)$。

运算在内部把尾数补回隐藏位扩展成 24 位，并多留 1 位进位，共 25 位：

+ 对阶：比较阶码，小阶向大阶看齐，其尾数右移 `|EA − EB|` 位，阶码统一为大者。
+ 尾数加减：同号直接相加；异号先比大小，用大的减小的，符号取大者，避免下溢。
+ 规格化：若 `bit24` 有进位，右移 1 位、阶码加 1；否则左移到 `bit23` 为 1，阶码减去左移位数。
+ 组装：`{S, E, M}`。

舍入采用直接截断；按实验要求只处理规格数，不处理非规格数、Inf、NaN 与溢出。

== 2. 实现

四步全部用组合逻辑在同一个时钟周期内完成，结果在时钟沿寄存输出：

```verilog
// 对阶：小阶的尾数右移，隐藏位已补在 bit23
wire [23:0] mae = a_big ? ma0 : (ma0 >> de);
wire [23:0] mbe = a_big ? (mb0 >> de) : mb0;

// 求和：同号相加，异号大减小
wire [24:0] sum = same        ? ({1'b0, mae} + {1'b0, mbe}) :
                  (mae >= mbe) ? ({1'b0, mae} - {1'b0, mbe}) :
                                 ({1'b0, mbe} - {1'b0, mae});

// 规格化：pos 为最高有效位位置
wire [4:0]  shl = 5'd23 - pos;
wire [7:0]  e1  = sum[24] ? (e0 + 8'd1) : (e0 - {3'b0, shl});
wire [23:0] m1  = sum[24] ? sum[24:1] : (sum[23:0] << shl);
```

最高有效位位置 `pos` 由一个 24 次循环的优先编码器给出：

```verilog
always @(*) begin
    pos = 5'd0;
    for (i = 0; i < 24; i = i + 1)
        if (sum[i]) pos = i;
end
```

== 3. 仿真结果

testbench 依次施加两次加法，间隔 80 ns。

#figure(image("floatadd.png", width: 100%), caption: [浮点加法波形（`−5.0 + (−4.5)` 与 `5.0 + 4.5`）], supplement: [图])

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    table.header([`A`], [`B`], [预期 `result`], [实测 `result`]),
    table.hline(),
    [`0xC0A00000`（−5.0）], [`0xC0900000`（−4.5）], [`0xC1180000`（−9.5）], [`0xC1180000`],
    [`0x40A00000`（5.0）], [`0x40900000`（4.5）], [`0x41180000`（9.5）], [`0x41180000`],
  ),
  caption: [浮点加法器的预期与实测结果],
  supplement: [表],
  kind: table,
)

`−5.0 + (−4.5)` 的结果为 $-1.1875 times 2^3$，尾数相加时产生进位，走的是右规路径（`bit24 = 1`，尾数右移 1 位、阶码由 129 变 130），因此结果阶码为 130、尾数字段为 `0x180000`。

= 五、问题与总结

== 1. 遇到的问题

无。

== 2. 实验总结

迭代式乘除法的本质是"一个移位寄存器加一个加法器，用 16 个周期换面积"，三者的状态机、计数器与握手信号几乎完全相同，改动集中在每拍的那一条运算语句上。

位宽是这类设计的核心：乘法优化版的进位、除法器的余数字段、浮点加法的 25 位中间结果，任何一处少留一位都会在特定数据上出错。

浮点加法的主要工作量在对阶与规格化：对阶要做一次最多 24 位的右移，规格化要做一次最多 23 位的左移，两者都需要配套的阶码加减，这正是它与整数加减最大的区别。

#pagebreak(weak: true)
= 六、思考题

== 1. 乘法器优化前后，内部分别用了多少位宽来存储输入与输出？

设 $N$ 为位宽，本实验 $N = 16$。

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left + horizon, left + horizon, left + horizon),
    table.header([项目], [原始实现], [优化实现]),
    table.hline(),
    [被乘数], [$2N = 32$ 位，零扩展后逐次左移], [不单独存储，占积寄存器的低 $N$ 位],
    [乘数], [$N = 16$ 位，逐次右移], [$N = 16$ 位],
    [部分积 / 积], [$2N = 32$ 位], [$2N = 32$ 位（高 $N$ 位部分积 + 低 $N$ 位被乘数）],
    [加法器], [$2N = 32$ 位], [$N + 1 = 17$ 位，保留进位],
    [寄存器合计], [$2N + N + 2N = 80$ 位], [$2N + N = 48$ 位],
  ),
  caption: [两种乘法实现的位宽对比],
  supplement: [表],
  kind: table,
)

原始实现的被乘数要左移 15 次，最高位会移到第 31 位，所以必须用 $2N$ 位存放；部分积与它同宽，加法器也只能是 $2N$ 位。优化实现让被乘数随积寄存器一起右移，省掉了一个 $2N$ 位寄存器；加法器只处理高半部分与乘数，但要接住 `left(O) + B` 的进位，因此是 $N + 1$ 位。

== 2. 如果除数是 0，除法器会输出什么样的商与余数？为什么？

商为全 1（`0xFFFF`），余数为被除数本身。
比较条件是 `left(O) >= B`。$B = 0$ 时该条件恒成立，每一拍都会执行"减 0 并把最低位置 1"。减 0 不改变余数，于是 16 拍下来商位累积成全 1；与此同时寄存器每拍左移一位，被除数的 16 位恰好在这 16 次左移中全部进入余数的高半部分。整个过程不会死锁，也不会产生任何异常信号。

== 3. 对阶时为什么让小阶向大阶看齐？尾数右移时隐藏位应如何处理？

若反过来让大阶向小阶看齐，大数的尾数就要左移。尾数只有 24 位（含隐藏位），左移会把最高位挤出寄存器，直接丢失有效数字，误差更大。

隐藏位的处理则是"先补回、再移位"：

```verilog
wire [23:0] ma0 = {1'b1, mA};                    // 先补回隐藏位
wire [23:0] mae = a_big ? ma0 : (ma0 >> de);     // 再右移
```
