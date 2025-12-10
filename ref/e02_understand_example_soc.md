# 实验二 熟悉RISC-V SoC示例工程



## 一 摘要



## 二 实验目标与工作流程



## 三 示例工程解析

示例工程下载地址：

https://git.tongji.edu.cn/ichip/examples/e203_hello_world

可以在Linux系统的终端中使用以下命令从代码仓库复制源码副本：

```shell
git clone https://git.tongji.edu.cn/ichip/examples/e203_hello_world.git
```

代码树结构如下：

```
\firmware
----\hello_world\		
	----\src\						//固件源码所在目录
		----*.c/*.h					//C语言源码，详细清单略
	----\Debug\						//编译中间文件及生成的目标文件所在位置
\gowin_prj
----e203_hello_world.cst			//FPGA工程的物理约束文件，用以表明信号和引脚的对应关系
----e203_hello_world.sdc			//FPGA工程的时序约束文件
----e203_hello_world_win.gprj		//Gowin FPGA Designer工程文件(Windows)
----e203_hello_world_win.gprj.user	//Gowin FPGA Designer用户配置(Windows)
----e203_hello_world_lnx.gprj		//Gowin FPGA Designer工程文件(Linux)
----e203_hello_world_lnx.gprj.user	//Gowin FPGA Designer用户配置(Linux)
\rtl
----\core\							//Hummingbird E203源码，如果需要添加IP，需要做修改
----\ip\							//自行设计或第三方IP模块
\sim
----input.txt						//testbench用的激励数据文件，数据以hex形式输入
----run_iverilog.sh					//Linux下调用iverilog仿真的Shell脚本
----run_iverilog.cmd				//windows下调用iverilog仿真的cmd脚本
----sys_tb_top.sv					//testbench的顶层文件，仿真前要在这个文件里例化你的完整设计
\sim_lib
----\gw2a\
    ----prim_sim.v					//gowin FPGA原语仿真库
    ----prim_tsim.v					//含有时序参数的gowin FPGA原语仿真库
\tools
----\makehex64\
	----makehex64.py				//python脚本，用以将bin格式固件镜像转换为$readmemh系统函数能够使用的hex格式文本
```



## 四 为SoC构建固件镜像

### 4.1 编译工具准备

#### 4.1.0 安装前需要准备的软件

本课程的开发环境基于Ubuntu Linux Desktop 22.04.x，使用Minimal配置安装，**系统语言English**

> [!WARNING]
>
> 注意，系统语言选择中文的话，可能会引起编译失败、仿真错误等问题。

Ubuntu Linux桌面安装完成后，还需要安装必要的工具，可以执行以下命令：

```shell
sudo apt update
sudo apt upgrade
sudo apt install -y git vim cmake
```

另外，我们编写verilog和C代码需要用到VSCode，可以到以下网站下载最新的安装包：

[https://code.visualstudio.com](https://code.visualstudio.com)

> [!WARNING]
>
> 注意：不要用Ubuntu自带的软件商店安装VSCode，会有问题。



#### 4.1.1 安装xpack-riscv-none-elf-gcc

我们使用的版本是xpack-riscv-none-elf-gcc，版本13.3.0-2。

> [!IMPORTANT]
>
> 这是针对RISC-V微控制器的gcc，请勿使用其他架构的gcc，以免镜像无法运行。



校内下载链接：

[https://git.tongji.edu.cn/ichip/asset/-/package_files/8/download](https://git.tongji.edu.cn/ichip/asset/-/package_files/8/download)

下载后，在tar.gz文件所在目录下打开Linux Terminal（或者先开Linux Terminal，然后cd到该目录下），执行以下命令对压缩包解压：

```
tar zxvf xpack-riscv-none-elf-gcc-13.3.0-2-linux-x64.tar.gz
```

解压后，将该目录移动到合适的位置，比如/opt下，可使用以下命令：

```
sudo mv ./xpack-riscv-none-elf-gcc-13.3.0-2 /opt
```



#### 4.1.2 配置环境变量

需要在系统环境变量中添加xpack-riscv-none-elf-gcc所在路径，才能在Linux中任何一个位置调用riscv-none-elf-gcc，否则make将无法执行编译任务。

在Linux终端输入：

```
vim ~/.bashrc
```

此时，会在终端中打开vim编辑界面，vim打开时默认是移动模式，需要按<kbd>i</kbd>键切换到插入模式，然后在文件前部空白处，插入以下内容：

```
export PATH=/opt/xpack-riscv-none-elf-gcc-13.3.0-2/bin:$PATH
```

输入完成后，按<kbd>ESC</kbd>关闭插入模式，再直接输入“:wq”保存退出。

接下来，在终端中执行以下命令，更新系统环境变量，使刚才的改动生效。

```
source ~/.bashrc
```



#### 4.1.3 测试

完成上述步骤后，可以在Linux系统中任意位置打开终端，尝试执行一下命令：

```
riscv-none-elf-gcc -v
```

运行结果应如下图所示：

![image-20251125213345390](image/image-20251125213345390.png)



#### 4.1.4 检查系统Python是否能正常运行

本实验中需要python来执行makehex64程序，或者将makehex64.py打包为单个可执行文件。通常Ubuntu Linux系统里默认安装了Python3，可以通过以下命令检查Python的安装情况：

```
python3 -V
```

运行结果如下图所示：

![image-20251125213640459](image/image-20251125213640459.png)

如果你的系统里没有python，可以通过以下命令安装Python及pip：

```
sudo apt install python3
sudo apt install python3-pip
```



#### 4.1.5 安装openocd并配置（可选，待补充）



### 4.2 编写程序

实验/大作业中，尽量保持本例的目录结构不变。新增加的.c和.h文件可以放在\src\main.c同级目录，makefile会自行添加。



### 4.3 编译

程序编写完成后，在终端中找到你的工程所在文件夹。例如在本实验中，C语言代码的目录位于`your_working_folder/firmware/hello_world/`

编译控制用到makefile位于Debug目录下，首先使用文本编辑器或者VSCode检查makefile，确认以下几行：

PREFIX := riscv-none-elf-

ARCH := rv32ima_zicsr

接着检查makefile中目标可执行文件是否为e203_hello_world.elf，正确的内容应该如下图所示：

![image-20251125214635817](image/image-20251125214635817.png)

![image-20251125214712929](image/image-20251125214712929.png)

检查无误就可以准备编译了。

在Linux终端中，切换你的当前目录到Debug目录，执行以下命令：

```
make
```

如果出现以下错误：

![image-20251125214905186](image/image-20251125214905186.png)

其原因是makehex64没有执行权限，可在命令行中（当前目录还是在Debug\下）运行以下命令：

```
chmod +x makehex64
```

为makehex64增加执行权限。

重新make前，需要清除上次编译的中间结果，可执行：

```
make clean
```

再次编译：

```
make
```

如果没有错误，应该显示以下结果：

![image-20251125215243033](image/image-20251125215243033.png)

支持，应该在Debug目录下存在以下文件：

- e203_hello_world.bin
- e203_hello_world.elf
- ram.hex

其中bin文件是经过链接器定位的可执行镜像，用于烧写在Flash里，这里我们使用verilog直接在综合阶段将程序加载，用到的是ram.hex。

至此，软件部分的编译工作基本完成。



## 五 修改RTL代码，为E203 SoC Demo添加外设

### 5.1 RTL代码结构

`your_working_folder/rtl/core/`目录下为E203 SoC的完整demo，包含顶层，辅助的时钟，CPU核心，总线多路器和外设。

需要修改的主要几个文件如下：

- config.v	           一些系统参数预设，用以调整CPU配置，使能一些IP模块，调整存储空间大小、地址等
- e203_clk_unit.v      系统时钟模块，主要是针对FPGA实现，需要将外部时钟27MHz通过片内PLL改为可以运行CPU的频率（比如18MHz），或者为其他模块提供FPGA内部时钟。
- e203_soc_demo.v  系统顶层模块，与外接交互的信号都要通过这个顶层模块引出，FPGA引脚约束需要对照本模块的信号定义。
- e203_subsys_perips.v  外设互联模块，在这里，外设IP与ICB总线多路开关sirv_icb1to16_bus进行连接，我们自己设计的外设通过这里与整个系统连接，实例化也是在这里。

当你的模块需要连接FPGA外部引脚时，需要从e203_subsys_perips.v向它的上层逐层引出信号。

为了尽量减小对E203 SoC Demo的修改，我们自己设计的外设模块的RTL代码放在`your_working_folder/rtl/ip/`目录下。

### 5.2 E203 SoC Demo的层次结构

E203 SoC Demo的层次结构见下图：





### 5.3 实现一个兼容ICB总线的简单外设

这里给大家展示一个简单的ICB外设，代码如下：

```verilog
//=====================================================================
//
// Designer   : Jiang Lei
//
// Description:
//  Example for an e203 icb peripheral
//
// ====================================================================

module my_periph_example(
    input                   clk,
    input                   rst_n,

    input                   i_icb_cmd_valid,
    output                  i_icb_cmd_ready,
    input  [32-1:0]         i_icb_cmd_addr, 
    input                   i_icb_cmd_read, 
    input  [32-1:0]         i_icb_cmd_wdata,

    output                  i_icb_rsp_valid,
    input                   i_icb_rsp_ready,
    output [32-1:0]         i_icb_rsp_rdata,

    output                  io_interrupts_0_0,                
    output                  io_pad_out
);

    //define a 32-bit register for operating your module
    reg [31:0] io_value_reg;

    reg [31:0] icb_data_out;
    reg        icb_rsp_valid;

    wire reset;
    wire clock;
    //read enable signal for register reading, this signal assert when proper address issued.
    wire io_value_reg_rd_en;

    //write enable signal for register writting, this signal assert when proper address issued.
    wire io_value_reg_wr_en;


    assign reset = ~rst_n;
    assign clock = clk;
    
    //judge if register is selected for read, 3'h4 is the offset address of the register
    assign io_value_reg_rd_en = i_icb_cmd_valid && i_icb_cmd_read && (i_icb_cmd_addr[11:0] == 3'h4);
    //for write
    assign io_value_reg_wr_en = i_icb_cmd_valid && (~i_icb_cmd_read) && (i_icb_cmd_addr[11:0] == 3'h4);

    //no wait state, so direct connect valid to ready signal
    assign i_icb_cmd_ready = i_icb_cmd_valid;

    assign i_icb_rsp_valid = i_icb_rsp_ready && icb_rsp_valid;

    assign i_icb_rsp_rdata = icb_data_out;

    //connect io pad to register
    assign io_pad_out = io_value_reg[0];


    always @(posedge clock or posedge reset) begin
        if (reset) begin
            io_value_reg <= 32'h12345678;
            icb_rsp_valid <= 1'b0;
        end 
        else begin
            if (io_value_reg_rd_en) begin
                icb_data_out <= io_value_reg;
                icb_rsp_valid <= 1'b1;
            end
            else begin
                icb_rsp_valid <= 1'b0;
            end

            if(io_value_reg_wr_en) begin
                io_value_reg <= i_icb_cmd_wdata;
                icb_rsp_valid <= 1'b1;
            end
        end
    end

endmodule

```

在这个外设中，具有一个标准的E203 ICB总线接口，定义了一个32bit寄存器，该寄存器的偏移地址为**OFFSET_ADDR** = 0x04，基地址**BASE_ADDR**根据集成时所挂载的ICB分支决定，会在下一节详细介绍。该寄存器在复位后会加载默认值0x12345678，端口信号io_pad_out将该寄存器bit0的输出引出至系统引脚。

软件通过向寄存器所在地址(BASE_ADDR + OFFSET_ADDR)的bit0写入1使引脚输出高电平，写入0使引脚输出低电平。

### 5.4 将自研的外设集成至E203 SoC Demo

由于E203 SoC Demo中，ICB总线多路开关的16个通道都有连接，但是我们的系统中很多外设是不使用的，为了减少RTL代码修改，我们使用替换法，用自研模块去替换掉ICB总线上不使用的模块。这里，挂载外设主要修改`your_working_folder/rtl/core/e203_subsys_perips.v`，具体修改方法如下：

#### 5.4.1 确认地址空间分配

在e203_subsys_perips.v的第1506行开始，有ICB总线外设的地址分配表:

```verilog
  // The total address range for the PPI is from/to
  //  **************0x1000 0000 -- 0x1FFF FFFF
  // There are several slaves for PPI bus, including:
  //  * AON       : 0x1000 0000 -- 0x1000 7FFF
  //  * HCLKGEN   : 0x1000 8000 -- 0x1000 8FFF
  //  * OTP       : 0x1001 0000 -- 0x1001 0FFF
  //  * GPIO      : 0x1001 2000 -- 0x1001 2FFF
  //  * UART0     : 0x1001 3000 -- 0x1001 3FFF
  //  * QSPI0     : 0x1001 4000 -- 0x1001 4FFF
  //  * PWM0      : 0x1001 5000 -- 0x1001 5FFF
  //  * UART1     : 0x1002 3000 -- 0x1002 3FFF
  //  * QSPI1     : 0x1002 4000 -- 0x1002 4FFF
  //  * PWM1      : 0x1002 5000 -- 0x1002 5FFF
  //  * QSPI2     : 0x1003 4000 -- 0x1003 4FFF
  //  * PWM2      : 0x1003 5000 -- 0x1003 5FFF
  //  * Example-AXI      : 0x1004 0000 -- 0x1004 0FFF
  //  * Example-APB      : 0x1004 1000 -- 0x1004 1FFF
  //  * Example-WishBone : 0x1004 2000 -- 0x1004 2FFF
  //  * SysPer    : 0x1100 0000 -- 0x11FF FFFF

```



#### 5.4.2 确认ICB空闲端口



#### 5.4.3 根据需要修改ICB地址分配

如果你的外设需要一个比较大的地址空间，可选择地址空间较大的空闲外设，也可根据需求修改外设的基地址与地址空间范围。

在e203_subsys_perips.v中的第1528行开始的sirv_icb1to16_bus实例化部分，包含了例化参数传递的部分，如下所示：

```verilog
sirv_icb1to16_bus # (
  .ICB_FIFO_DP        (2),// We add a ping-pong buffer here to cut down the timing path
  .ICB_FIFO_CUT_READY (1),// We configure it to cut down the back-pressure ready signal

  .AW                   (32),
  .DW                   (`E203_XLEN),
  .SPLT_FIFO_OUTS_NUM   (1),// The peirpherals only allow 1 oustanding
  .SPLT_FIFO_CUT_READY  (1),// The peirpherals always cut ready
  //  * AON       : 0x1000 0000 -- 0x1000 7FFF
  .O0_BASE_ADDR       (32'h1000_0000),       
  .O0_BASE_REGION_LSB (15),
  //  * HCLKGEN   : 0x1000 8000 -- 0x1000 8FFF
  .O1_BASE_ADDR       (32'h1000_8000),       
  .O1_BASE_REGION_LSB (12),
  //  * OTP       : 0x1001 0000 -- 0x1001 0FFF
  .O2_BASE_ADDR       (32'h1001_0000),       
  .O2_BASE_REGION_LSB (12),
  //  * GPIO      : 0x1001 2000 -- 0x1001 2FFF
  .O3_BASE_ADDR       (32'h1001_2000),       
  .O3_BASE_REGION_LSB (12),
  //  * UART0     : 0x1001 3000 -- 0x1001 3FFF
  .O4_BASE_ADDR       (32'h1001_3000),       
  .O4_BASE_REGION_LSB (12),
  //  * QSPI0     : 0x1001 4000 -- 0x1001 4FFF
  .O5_BASE_ADDR       (32'h1001_4000),       
  .O5_BASE_REGION_LSB (12),
  //  * PWM0      : 0x1001 5000 -- 0x1001 5FFF
  .O6_BASE_ADDR       (32'h1001_5000),       
  .O6_BASE_REGION_LSB (12),
  //  * UART1     : 0x1002 3000 -- 0x1002 3FFF
  .O7_BASE_ADDR       (32'h1002_3000),       
  .O7_BASE_REGION_LSB (12),
  //  * QSPI1     : 0x1002 4000 -- 0x1002 4FFF
  .O8_BASE_ADDR       (32'h1002_4000),       
  .O8_BASE_REGION_LSB (12),
  //  * PWM1      : 0x1002 5000 -- 0x1002 5FFF
  .O9_BASE_ADDR       (32'h1002_5000),       
  .O9_BASE_REGION_LSB (12),
  //  * QSPI2     : 0x1003 4000 -- 0x1003 4FFF
  .O10_BASE_ADDR       (32'h1003_4000),       
  .O10_BASE_REGION_LSB (12),
  //  * PWM2      : 0x1003 5000 -- 0x1003 5FFF
  .O11_BASE_ADDR       (32'h1003_5000),       
  .O11_BASE_REGION_LSB (12),
  //  * SysPer    : 0x1100 0000 -- 0x11FF FFFF
  .O12_BASE_ADDR       (32'h1100_0000),       
  .O12_BASE_REGION_LSB (24),

      // * Here is an example AXI Peripheral
  .O13_BASE_ADDR       (32'h1004_0000),       
  .O13_BASE_REGION_LSB (12),
  
      // * Here is an example APB Peripheral
  .O14_BASE_ADDR       (32'h1004_1000),       
  .O14_BASE_REGION_LSB (12),
  
      // * Here is an I2C WishBone Peripheral
  .O15_BASE_ADDR       (32'h1004_2000),       
  .O15_BASE_REGION_LSB (3)// I2C only have 3 bits address width

)u_sirv_ppi_fab(...)
```

这里，Ox_BASE_ADDR为ICB端口Ox对应的基地址，Ox_BASE_REGION_LSB为该外设地址空间位数，如12表示的是地址空间为12bit，即此外设能够使用的地址范围为2^12 Byte = 4KB。这里可以根据需求修改。但是修改后，后面的外设基地址应该按照空间分配顺延。这里需要仔细计算，防止地址空间重叠。



#### 5.4.3 例化自研IP



#### 5.4.4 声明自研IP的ICB信号线及引出线



#### 5.4.5 映射ICB信号



#### 5.4.6 向上层模块添加必要的引出信号



### 5.5 编写C代码控制io_pad_out



### 5.6 在RTL中加载固件

比较简单的方法是在RTL综合/仿真时直接将固件镜像加载到CPU的code空间。在本实验中，E203的code空间在e203_itcm_ram.v中实现，因此，可以直接在综合/仿真时，利用verilog中的$readmemh系统函数，加载固件镜像。在your_working_folder/rtl/core中找到e203_itcm_ram.v文件，在146行开始的一段代码中引用了$readmemh函数，具体代码如下：

```verilog
`ifdef E203_LOAD_PROGRAM
    initial begin
`ifdef USING_IVERILOG   //simulation
        $display("loading firmware from simulator\n");
        $readmemh("../firmware/hello_world/Debug/ram.hex", mem_r);
`else                   //implementation
        $display("loading firmware from sythesizer\n");
        $readmemh("../firmware/hello_world/Debug/ram.hex", mem_r);
`endif
    end
`endif

```

这里是条件编译，当定义了**E203_LOAD_PROGRAM**宏后，会使能该代码块。然后判断是使用iverilog进行仿真，还是使用gowin FPGA designer进行综合。根据实际情况，调用$readmemh系统函数进行镜像加载。这里，$readmemh的第一个参数为要加载到文件路径，第二个参数为加载到目的内存实现。这里mem_r在e203_itcm_ram.v中第136行声明，如下：

```verilog
  reg [63:0] mem_r [0:DP-1] /*synthesis syn_ramstyle = "block_ram"*/;
```

这里，mem_r是一个64bit宽度，深度为DP的一块存储单元。因为其宽度为64bit，因此，在ram.hex文件中，一行的数据宽度也应该对应64bit，如下所示：

![image-20251125222256466](image/image-20251125222256466.png)

ram.hex中，每一行为16位十六进制数，对应二进制正好是64bit宽。

> [!IMPORTANT]
>
> 这里之所以将iverilog仿真和gowin FPGA Designer综合分开调用$readmemh，是因为两者执行的路径不同。注意到$readmemh的第一个参数使用的是相对路径，而iverilog仿真和gowin FPGA Designer综合在执行时，相对ram.hex文件的相对路径可能是不同的。必须检查这个相对路径。在iverilog仿真时，这个路径的参考目录是你执行仿真脚本的位置，比如`your_working_folder/sim`/，而综合时，路径的参考目录是`your_working_folder/gowin_prj/`。请根据实际情况检查并修改这个路径。在仿真/综合时，注意观察$display函数的输出，以确认当前处于哪种模式。仿真生成波形后，还可以观察e203_itcm_ram.v中的mem_r是否被正确填充固件镜像。



## 六 结合固件进行SoC仿真（软硬件协同验证）

### 6.1 为E203 SoC Demo建立顶层Testbench

### 6.2 使用iverilog仿真，生成波形

### 6.3 如何看你的固件是否正确访问了自研外设

### 6.4 如何利用System Verilog系统函数，在顶层Testbench中自动保存数据



## 七 针对FPGA实现的后端流程

### 7.1 FPGA实现中需要进行的修改

### 7.2 FPGA工程搭建

### 7.3 FPGA综合及综合后的时序仿真

### 7.4 下载到开发板



## 八 拓展任务

