# openocd的安装与使用



1. 使用CMSIS-DAP（带JTAG接口）连接Tang Primer20k，我们使用以下管脚引出内置调试JTAG信号：

TDO->R8

TMS->T6

TCK->P9

TDI->T8

GND

使用GPIO PMOD接口连接CMSIS-DAP调试器，并在FPGA的工程中修改引脚约束e203_basic_chip.cst文件，改好之后重新综合/布局布线，并使用Gowin Programmer下载到SRAM中

 

2. 下载安装openocd

下载链接：[xpack-openocd-0.12.0-4-linux-x64.tar.gz](https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-4/xpack-openocd-0.12.0-4-linux-x64.tar.gz)

安装方法参见：[https://xpack.github.io/dev-tools/openocd/install](https://xpack.github.io/dev-tools/openocd/install/)



推荐使用手动安装方式。

```
sudo mkdir -p /opt/xpack

tar zxvf ~/Downloads/xpack-openocd-0.12.0-4-linux-x64.tar.gz
sudo cp ~/Downloads/xpack-openocd-0.12.0-4-linux-x64 /opt/xpack/
```

接下来需要将openocd的udev规则文件复制到/etc/udev/rules.d，用来开放usb设备访问权限，方法是：

```
sudo cp /opt/xpack/xpack-openocd-0.12.0-4/openocd/contrib/60-openocd.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
```

openocd使用手册：[https://openocd.org/doc-release/pdf/openocd.pdf](https://openocd.org/doc-release/pdf/openocd.pdf)

3. 将openocd的可执行文件和脚本目录添加到系统环境变量中



3. 在openocd/scripts目录下执行：

```
openocd -f interface/cmsis-dap.cfg -c "transport select jtag"
```

应该能看到打印如下信息：

![Screenshot from 2024-01-02 21-52-25](./image/Screenshot from 2024-01-02 21-52-25.png)

至此我们就可以通过openocd控制cmsis-dap来访问e203的jtag端口进行在线调试了。