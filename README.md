# 基于 E203 的四位数码管计数器

本项目将四位数码管驱动器挂载到 E203 SoC 的 ICB 总线上，通过 CPU 软件写寄存器控制显示内容。

## 1. 项目概述

- SoC：Nuclei E203（Hummingbird E200 BSP）。
- 显示：四位七段数码管，200 Hz 动态扫描。
- 控制：CPU 通过 ICB 寄存器写入 BCD 数字。
- 外设 RTL：`rtl/ip/my_periph_example.v`。

## 2. 设计层级（从顶层到 IP）

数码管信号 `seg_out/cc` 的显式端口贯穿路径：

```
e203_soc_demo
  -> e203_soc_top
    -> e203_subsys_top
      -> e203_subsys_main
        -> e203_subsys_perips
          -> my_periph_example
```

RTL 层级表：

| 层级 | 模块 | 关键端口/信号 | 说明 |
| --- | --- | --- | --- |
| 1 | e203_soc_demo | seg_out[7:0], cc[3:0] | 顶层引脚输出 |
| 2 | e203_soc_top | seg_out[7:0], cc[3:0] | SoC 顶层封装 |
| 3 | e203_subsys_top | seg_out[7:0], cc[3:0] | 子系统顶层 |
| 4 | e203_subsys_main | seg_out[7:0], cc[3:0] | 主子系统 |
| 5 | e203_subsys_perips | seg_out[7:0], cc[3:0] | 外设汇聚与 ICB 挂载 |
| 6 | my_periph_example | seg_out[7:0], cc[3:0], i_icb_cmd_*, i_icb_rsp_* | ICB 数码管外设 |

端口说明：

- 在每一层新增并传递 `seg_out[7:0]` 与 `cc[3:0]`，最终连接到顶层 IO 引脚。

## 3. 外设设计（ICB 数码管驱动）

文件：`rtl/ip/my_periph_example.v`

### 3.1 寄存器映射

基地址（复用 QSPI0 空间）：

- `0x1001_4000`（见 `firmware/hello_world/src/bsp/hbird-e200/env/platform.h`）

寄存器映射表：

| 绝对地址 | 偏移 | 名称 | 位域 | 读写 | 复位 | 说明 |
| --- | --- | --- | --- | --- | --- | --- |
| 0x1001_4000 | 0x00 | CTRL | bit0: count_en | R/W | 0x0000_0001 | 1=1Hz 自动计数，0=软件控制 |
| 0x1001_4004 | 0x04 | DATA | [15:12]=d3 [11:8]=d2 [7:4]=d1 [3:0]=d0 | R/W | 0x0000_0000 | BCD 数字 |

BCD 示例：

- 显示 1234：写 `0x0000_1234` 到 DATA。
- 显示 0098：写 `0x0000_0098` 到 DATA。

### 3.2 时钟与极性

- 系统时钟 18 MHz（见 `firmware/hello_world/src/bsp/hbird-e200/env/board.h`
  与 `rtl/core/e203_clk_unit.v`）。
- 扫描频率 200 Hz，每位有效 50 Hz。
- 自动计数频率 1 Hz（CTRL[0] = 1 时）。
- `seg_out` 为段选高电平有效（与 `led_my` 逻辑一致）。
- `cc` 为位选高电平有效。
- 若板级接法相反，可在 `rtl/ip/my_periph_example.v` 里对 `seg_out` 或 `cc` 取反。

## 4. 固件使用

文件：`firmware/hello_world/src/main.c`

关键点：

- `MY_PERIPH_REG(MY_PERIPH_REG_CTRL) = 0x0;` 关闭自动计数。
- `MY_PERIPH_REG(MY_PERIPH_REG_IO) = bcd;` 写入 BCD 数字。
- `delay_ms()` 使用 CLINT 计时器（`get_timer_value`、`get_timer_freq`）。

## 5. 编译固件（生成 ram.hex）

前置条件：`riscv-none-elf-gcc` 已加入 PATH。

在固件构建目录执行：

```shell
cd firmware/hello_world/Debug
make clean
make
```

产物：

- `firmware/hello_world/Debug/e203_my_periph_demo.elf`
- `firmware/hello_world/Debug/e203_my_periph_demo.bin`
- `firmware/hello_world/Debug/ram.hex`

如果之前遇到 `undefined reference to usleep`，当前 `main.c` 已改为 `delay_ms`。

## 6. 将固件挂载到 RTL

ITCM 通过 `ram.hex` 预加载程序（`E203_LOAD_PROGRAM` 已打开）：

- 宏定义：`rtl/core/config.v` 中 `` `define E203_LOAD_PROGRAM ``。
- 加载文件：`rtl/core/e203_itcm_ram.v` 读取
  `../firmware/hello_world/Debug/ram.hex`。

重新生成 `ram.hex` 后，需要重新综合/实现，确保新固件进 bitstream。

## 7. FPGA 构建（Gowin）

1. 打开 `gowin_prj/e203_basic_chip.gprj`（Linux 用 `_lnx` 项目）。
2. 确认 `gowin_prj/e203_basic_chip.cst` 引脚约束正确。
   本工程将 `seg_out[7:0]` 和 `cc[3:0]` 映射到 `led_my/src/led_seg_display.cst` 的引脚。
3. 执行 Synthesis -> Place & Route -> Generate Bitstream。
4. 下载 bitstream 到开发板。

## 8. 运行与预期结果

1. 下载 bitstream 到板子。
2. 打开 UART0，波特率 115200（见 `firmware/hello_world/src/bsp/hbird-e200/env/init.c`）。
3. 数码管每秒更新一次（软件写 BCD）。
4. 串口输出示例：`set display = XXXX (bcd=0xYYYY)`。

## 9. 常见问题

- 无显示：检查 `gowin_prj/e203_basic_chip.cst` 引脚映射与极性。
- 扫描速度异常：确认 `rtl/ip/my_periph_example.v` 中 `CLK_HZ` 与系统时钟一致（默认 18 MHz）。
- 显示错乱：确认 DATA 为 BCD，顺序 d3 d2 d1 d0。

## 10. 图片占位（请自行替换）

把你的截图/照片放到以下位置：

- 系统框图：
![](img/block_diagram.png)

- 仿真波形：
![](img/waveform.png)

- 显示结果：
![](img/display_result.png)
