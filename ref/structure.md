# Project Structure

This document outlines the directory and file structure of the `e203_peripheral_example-main` project.

- **.gitignore**: Specifies intentionally untracked files to ignore.
- **BaiduShurufa_2024-1-17_22-32-5.png**: Image file.
- **LICENSE**: Project license file.
- **README.md**: Project's readme file.
- **structure.md**: This file.

## `firmware`

Contains the software that runs on the E203 core.

- **.gitkeep**: Placeholder file.
- **hello_world**: Example "Hello World" application.
  - **.gitignore**: Git ignore file for the firmware.
  - **README.md**: Readme for the "Hello World" example.
  - **Debug**: Contains compiled binaries and build artifacts.
    - **e203_my_periph_demo.bin**: Binary executable.
    - **e203_my_periph_demo.elf**: ELF executable.
    - **e203_my_periph_demo.map**: Memory map file.
    - **makefile**: Makefile for building the firmware.
    - **makehex64**: Utility to create hex files.
    - **makehex64.exe**: Windows executable for `makehex64`.
    - **objects.mk**: Makefile include for object files.
  - **src**: Source code for the "Hello World" application.

## `gowin_prj`

Gowin FPGA project files.

- **.gitkeep**: Placeholder file.
- **e203_basic_chip_lnx.gprj**: Gowin project file for Linux.
- **e203_basic_chip_lnx.gprj.user**: User-specific project settings for Linux.
- **e203_basic_chip.cst**: Pin constraints file.
- **e203_basic_chip.gprj**: Gowin project file.
- **e203_basic_chip.gprj.user**: User-specific project settings.
- **e203_uart_demo.sdc**: Synopsys Design Constraints file for the UART demo.
- **impl**: Implementation files.
  - **project_process_config.json**: Project process configuration.
- **src**: Source files for the Gowin project.
  - **e203_basic_chip_lnx.rao**: RAO file for the Linux project.

## `rtl`

Register Transfer Level (RTL) code for the E203 SoC.

- **.gitkeep**: Placeholder file.
- **core**: Core components of the E203 SoC.
  - **.gitkeep**: Placeholder file.
  - **config.v**: Configuration file.
  - **e203_biu.v**: Bus Interface Unit.
  - **e203_clk_ctrl.v**: Clock control module.
  - **e203_clk_unit.v**: Clock unit.
  - **e203_clkgate.v**: Clock gating module.
  - **e203_core.v**: Top-level core module.
  - **e203_cpu_top.v**: Top-level CPU module.
  - **e203_cpu.v**: CPU module.
  - **e203_defines.v**: Verilog defines.
  - **e203_dtcm_ctrl.v**: Data Tightly-Coupled Memory controller.
  - **e203_dtcm_ram.v**: Data Tightly-Coupled Memory RAM.
  - **e203_extend_csr.v**: Extended Control and Status Registers.
  - **e203_exu_alu_bjp.v**: ALU branch jump unit.
  - **e203_exu_alu_csrctrl.v**: ALU CSR control unit.
  - **e203_exu_alu_dpath.v**: ALU data path.
  - **e203_exu_alu_lsuagu.v**: ALU LSU address generation unit.
  - **e203_exu_alu_muldiv.v**: ALU multiply/divide unit.
  - **e203_exu_alu_rglr.v**: ALU regular unit.
  - **e203_exu_alu.v**: Arithmetic Logic Unit.
  - **e203_exu_branchslv.v**: Branch solver.
  - **e203_exu_commit.v**: Commit stage.
  - **e203_exu_csr.v**: Control and Status Registers.
  - **e203_exu_decode.v**: Decode stage.
  - **e203_exu_disp.v**: Dispatch stage.
  - **e203_exu_excp.v**: Exception handling.
  - **e203_exu_longpwbck.v**: Long pipeline write-back.
  - **e203_exu_oitf.v**: Out-of-order instruction track buffer.
  - **e203_exu_regfile.v**: Register file.
  - **e203_exu_wbck.v**: Write-back stage.
  - **e203_exu.v**: Execution unit.
  - **e203_ifu_ifetch.v**: Instruction fetch unit.
  - **e203_ifu_ift2icb.v**: Instruction fetch to ICB.
  - **e203_ifu_litebpu.v**: Lite branch prediction unit.
  - **e203_ifu_minidec.v**: Mini decoder.
  - **e203_ifu.v**: Instruction fetch unit.
  - **e203_irq_sync.v**: Interrupt synchronizer.
  - **e203_itcm_ctrl.v**: Instruction Tightly-Coupled Memory controller.
  - **e203_itcm_ram.v**: Instruction Tightly-Coupled Memory RAM.
  - **e203_lsu_ctrl.v**: Load/Store Unit controller.
  - **e203_lsu.v**: Load/Store Unit.
  - **e203_reset_ctrl.v**: Reset controller.
  - **e203_soc_demo.v**: SoC demo top-level.
  - **e203_soc_top.v**: SoC top-level.
  - **e203_srams.v**: SRAMs.
  - **e203_subsys_clint.v**: Core-Local Interrupter subsystem.
  - **e203_subsys_gfcm.v**: Generic Fabric Clock Management subsystem.
  - **e203_subsys_hclkgen_rstsync.v**: HCLK generator reset synchronizer.
  - **e203_subsys_hclkgen.v**: HCLK generator subsystem.
  - **e203_subsys_main.v**: Main subsystem.
  - **e203_subsys_mems.v**: Memory subsystem.
  - **e203_subsys_perips.v**: Peripherals subsystem.
  - **e203_subsys_plic.v**: Platform-Level Interrupt Controller subsystem.
  - **e203_subsys_pll.v**: PLL subsystem.
  - **e203_subsys_pllclkdiv.v**: PLL clock divider subsystem.
  - **e203_subsys_top.v**: Top-level subsystem.
  - **i2c_master_bit_ctrl.v**: I2C master bit controller.
  - **i2c_master_byte_ctrl.v**: I2C master byte controller.
  - **i2c_master_defines.v**: I2C master defines.
  - **i2c_master_top.v**: I2C master top-level.
  - **sirv_...**: Various SIRV components (AON, CLINT, debug, GPIO, etc.).
- **ip**: IP cores.
  - **.gitkeep**: Placeholder file.
  - **my_periph_example.v**: Example peripheral.

## `sim`

Simulation files.

- **gowin_sim_lib**: Gowin simulation libraries.
  - **gw2a**: Gowin GW2A library.
- **iverilog-lnx**: Icarus Verilog simulation for Linux.
  - **sim_run_sys_tb.sh**: Simulation run script.
  - **sys_tb_top.sv**: System testbench top-level.
- **iverilog-mac**: Icarus Verilog simulation for macOS.
  - **iverilog_sim_sys_tb**: Simulation executable.
  - **sys_tb_top.sv**: System testbench top-level.
- **iverilog-win**: Icarus Verilog simulation for Windows.
  - **sim_run_sys_tb.cmd**: Simulation run script.
  - **sys_tb_top.sv**: System testbench top-level.
- **verilator**: Verilator simulation.
  - **sim_main.cpp**: C++ main for Verilator simulation.
  - **tb_top.v**: Testbench top-level for Verilator.

## `tools`

Various tools.

- **makehex64**:
  - **makehex64.py**: Python script to create hex files.
  - **makehex64.spec**: Spec file for the `makehex64` utility.
