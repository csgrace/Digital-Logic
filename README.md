# Digital Logic / 数字逻辑 Project

> CS207 数字逻辑课程项目

## 📘 简介 About

这是 CS207 的数字逻辑（Digital Logic）课程项目。  
项目包含用 VHDL / Verilog / FPGA 工具（如 Vivado）设计、仿真与实现一系列数字逻辑电路与系统。  
目的是加深对组合逻辑、时序逻辑、状态机、硬件仿真以及 FPGA 实验流程的理解。

## 📂 仓库结构 Repository Structure
📁 Tesr.srcs/ 源文件目录，包含 VHDL 或 Verilog 源码

📁 Tesr.sim/ 仿真文件 / 仿真结果

│ 📁 sim_1/

│ │ 📁 behav/ behavioral 仿真

│ │ │ 📁 xsim Vivado 仿真输出

📄 Tesr.hw 硬件描述文件 / 项目设置

📄 Tesr.xpr Vivado 工程文件

📄 main_tb_behav.wcfg 仿真的配置文件

📁 最终答辩/ 项目最终答辩相关材料

📄 Ego1_用户手册_v2.21.pdf 用户手册 / 使用说明文档

📄 projects_introduction_中文.pdf 项目介绍（中文）

📄 README.md 本说明文件

📄 .gitattributes Git 属性文件

📄 vivado.log, vivado.jou Vivado 编译 / 实现日志文件


## 🔧 功能 Features

以下是项目中实现的一些主要功能/模块：

- 组合逻辑电路（加法器、多路选择器、译码器等）  
- 时序逻辑 / 寄存器与触发器设计  
- 状态机（FSM）设计与实现  
- 测试平台（Testbench）搭建及行为仿真  
- FPGA 综合与实现部署  
- 硬件 /软件交互（如果有的话）  

## 🛠 使用指南 How to Use

以下是将工程编译、仿真、部署的基本流程：

1. 安装必要工具与依赖环境，例如 Vivado，支持 VHDL / Verilog 的仿真器。  
2. 克隆仓库并进入项目目录：  
   ```bash
   git clone https://github.com/csgrace/Digital-Logic.git
   cd Digital-Logic
3. 打开 Vivado 工程文件 Tesr.xpr。
4. 在 Vivado 中执行行为仿真 (Behavioral Simulation)。
5. 若需要，可运行综合（Synthesis）与实现（Implementation）流程，然后生成比特流 (bitstream)。
6. 在 FPGA 板卡上下载比特流进行硬件验证（若支持）。

## 📋 文档 Documentation

`projects_introduction_中文.pdf` — 项目整体介绍与设计思路

`Ego1_用户手册_v2.21.pdf` — 用户手册 / 使用说明文档

仿真输出目录 `Tesr.sim/` 包含行为仿真结果（行为模型）

## ✅ 项目亮点 Highlights

使用 Vivado 完成从设计到仿真的全流程

模块化设计，方便不同子电路的复用与扩展

中文 / 英文文档齐备，方便跨语言阅读理解

仿真文件与日志保留，便于调试与验证

## 🚀 可能的改进方向 Future Improvements

增加更多 testbench 测试覆盖边缘条件

实现更复杂的状态机或流水线

如果有硬件平台，可加入板级测试与性能评测

优化时序性能与资源使用率
