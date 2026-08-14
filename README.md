# 抽油烟机控制电路 / FPGA-based Range Hood Controller

> CS207 数字逻辑课程项目 @ SUSTech  
> 开发板：EGO1（Xilinx Artix‑7） · 工具：Vivado · 语言：Verilog

**项目成员**：温一楠（12310841）· 李晏敏（12311022）· 魏宇晴（12311043）

---

## 1. 项目简介

本项目在 EGO1 开发板上使用 Verilog 实现了一个完整的**抽油烟机控制电路**。系统通过有限状态机（FSM）统一调度，在多种输入输出设备（按键、拨码开关、七段数码管、LED、蜂鸣器、蓝牙模块）上实现开关机、三档风力调节、自清洁、时间显示与校准、累计工作时长统计与智能清洁提醒、照明控制、手势开关等全部课程任务要求的功能，并完成蓝牙远程控制、蜂鸣器智能提醒两项 bonus。

---

## 2. 技术栈

| 类别 | 技术 / 工具 |
| --- | --- |
| 硬件描述语言 | Verilog HDL |
| 目标平台 | EGO1 开发板（Xilinx XC7A35T‑1CSG324C Artix‑7 FPGA） |
| 开发与仿真 | Vivado Design Suite（含 XSim 行为仿真） |
| 时钟管理 | Vivado Clocking Wizard IP（clk_core） |
| 数据缓冲 | Vivado FIFO Generator IP（char_fifo） |
| 版本控制 | Git / GitHub |
| 输入设备 | 按键、拨码开关、蓝牙串口模块 |
| 输出设备 | 七段数码管（6 位）、LED 指示灯、蜂鸣器 PWM、蓝牙模块 |

---

## 3. 实现功能

### 3.1 开关机

| 功能 | 说明 |
| --- | --- |
| 短按开机 | 按开关机键启动抽油烟机，进入待机模式，初始化当前时间为 00:00:00，累计使用时长清零 |
| 长按关机 | 长按开关机键 **3 秒** 关机，关机后所有按键均失效 |
| 手势开关（bonus） | 模拟红外手势：先按左键启动 5s 窗口，窗口内按右键 = 开机；先按右键再按左键 = 关机；超时则操作作废 |

### 3.2 模式切换

开机默认进入**待机模式**，所有模式切换均以待机模式为枢纽：

- 待机 → 抽油烟模式（1 / 2 / 3 档）
- 待机 → 自清洁模式
- 1 档 ↔ 2 档可相互切换
- 1 档 / 2 档按菜单键直接返回待机
- 3 档按菜单键启动 **60s 返回待机倒计时**，倒计时结束进入待机
- 自清洁按菜单键返回待机，结束后自动回待机

### 3.3 抽油烟功能

| 档位 | 行为 |
| --- | --- |
| 1 档 | 进入后持续抽油烟，可随时切换到 2 档，按菜单键回待机 |
| 2 档 | 进入后持续抽油烟，可随时切换到 1 档，按菜单键回待机 |
| **3 档（飓风模式）** | ① 每次开机最多使用一次，重复按 3 档键无效；② 进入即启动 **60s 倒计时**，倒计时结束自动降为 **2 档**；③ 倒计时期间按菜单键则启动「返回待机」倒计时，结束后进入待机 |

进入任意档位时自动开启**累计工作时长计时**，退出抽油烟模式时停止计时并存储。

### 3.4 自清洁功能

- 仅能从待机模式进入
- 启动 **3 分钟倒计时**，结束后蜂鸣器提示"自清洁完成"，自动返回待机模式
- 自清洁完成后**累计工作时长清零**

### 3.5 辅助功能

| 功能 | 说明 |
| --- | --- |
| **照明** | 任何开机模式下均可独立开关照明灯 |
| **时间显示** | 开机后在七段数码管动态显示当前时间（时 / 分 / 秒） |
| **时间设置** | 待机模式下进入编辑模式，可分别调整时、分、秒 |
| **智能提醒** | 累计抽油烟时长达到阈值（默认 **10 小时**），待机模式下通过蜂鸣器 + LED 提醒；可在高级设置中调整阈值；自清洁完成后清零 |
| **高级设置** | 在待机模式下可修改：① 累计时长提醒阈值；② 手势开关有效时间；③ 一键恢复出厂设置 |
| **查询功能** | 待机模式下可查询：① 累计抽油烟工作时长；② 手势开关有效时间 |

### 3.6 Bonus 加分项

- ✅ 手势开关机（使用左键 + 右键序列模拟红外手势，5s 有效窗口）
- ✅ 蓝牙远程控制照明（基于 EGO1 蓝牙实验模块改装，串口通信）
- ✅ 蜂鸣器智能提醒（PWM 驱动无源蜂鸣器，累计时长超阈值时报警）

---

## 4. 系统架构

### 4.1 顶层设计

整个系统由顶层模块 `Main.v` 作为主控，内嵌一个**有限状态机（FSM）**负责模式切换，并通过例化以下子模块完成具体功能：

```
┌──────────────────────────────────────────────────────┐
│                      Main.v                          │
│                                                      │
│   ┌──────────┐   ┌───────────┐   ┌───────────────┐  │
│   │  FSM      │   │ 按键输入  │   │  蓝牙输入     │  │
│   │ 状态机    │   │ (消抖)    │   │  (bt_uart)    │  │
│   └─────┬─────┘   └─────┬─────┘   └───────┬───────┘  │
│         │               │                │           │
│   ┌─────▼───────────────────────────────────────┐   │
│   │              功能调度                        │   │
│   └──┬─────────┬──────────┬──────────┬─────────┘   │
│      │         │          │          │              │
│  ┌───▼──┐ ┌────▼────┐ ┌──▼───┐ ┌───▼────┐         │
│  │segment│ │extract- │ │self- │ │accumu- │         │
│  │显示   │ │ion_mode │ │clean │ │late_   │         │
│  │       │ │         │ │      │ │time    │         │
│  └───┬──┘ └────┬────┘ └──┬───┘ └───┬────┘         │
│      │         │          │          │              │
│      └─────────┴──────────┴──────────┼──→ audio   │
│                                      │   (蜂鸣器)  │
└──────────────────────────────────────────────────────┘
```

### 4.2 主要子模块

| 模块 | 文件 | 职责 |
| --- | --- | --- |
| segment | segment.v | 6 位七段数码管动态扫描显示，将「总秒数」转换为时 / 分 / 秒显示 |
| extraction_mode | extraction_mode.v | 1/2/3 档抽油烟调度：飓风模式单次限制、60s 倒计时、强制返回待机逻辑 |
| self_cleaning_module | self_cleaning_module.v | 自清洁 3 min 倒计时与完成信号生成 |
| accumulate_time | accumulate_time.v | 累计抽油烟工作时长统计，达阈值后输出蜂鸣器启动信号 |
| audio_output | audio_output.v | 蜂鸣器 PWM 驱动，产生指定频率方波 |
| hand | hand.v | 手势开关：左键 / 右键序列检测 + 可配置窗口倒计时 |
| bt_uart | 源码内 | 蓝牙串口通信，解析指令并控制照明灯 |
| countdown / countdown_advanced | countdown.v / countdown_advanced.v | 通用倒计时 / 带预置功能倒计时 |
| current_time | current_time.v | 当前时钟走时（时 / 分 / 秒循环） |
| is_button_pressed | is_button_pressed.v | 按键消抖 |
| clock_divider1 | clock_divider1.v | 时钟分频（产生 1Hz 时基等） |
| clk_core | IP | Vivado Clocking Wizard，生成系统所需时钟 |
| char_fifo | IP | Vivado FIFO Generator，跨时钟域数据缓冲 |

### 4.3 顶层端口

| 方向 | 信号 | 说明 |
| --- | --- | --- |
| input | clk, rst | 系统时钟、复位 |
| input | btn1 ~ btn5 | 5 路按键输入 |
| input | sw | 手势开关 |
| input | rst_n, sw_pin, rxd_pin, lb_sel_pin | 蓝牙模块输入 |
| output | bt_pw_on, bt_master_slave, bt_sw_hw, bt_rst_n, bt_sw, bl_power_on | 蓝牙模块控制 |
| output | sw_light, light | 照明灯控制 / 输出 |
| output | segment1_control ~ segment6_control | 6 位数码管位选 |
| output | segments | 数码管段码 |
| output | beelight | 工作上限指示灯 |
| output | edit_index_light, setting_page_index_light, query_page_index_light | 编辑 / 设置 / 查询状态指示灯 |
| output | audio_sd, audio_pwm | 蜂鸣器 SD / PWM 控制 |

---

## 5. 四种主要模式界面（EGO1 实拍）

| 待机模式 | 菜单模式 | 查询模式 | 设置模式 |
| --- | --- | --- | --- |
| ![待机](https://raw.githubusercontent.com/csgrace/Digital-Logic/main/最终答辩/待机模式.jpg) | ![菜单](https://raw.githubusercontent.com/csgrace/Digital-Logic/main/最终答辩/菜单模式.jpg) | ![查询](https://raw.githubusercontent.com/csgrace/Digital-Logic/main/最终答辩/查询模式.jpg) | ![设置](https://raw.githubusercontent.com/csgrace/Digital-Logic/main/最终答辩/设置模式.jpg) |

---

## 6. Repository Structure

```
Digital-Logic/
├── Tesr.xpr                      # Vivado 工程文件
├── Main.v                        # 顶层模块（FSM + 子模块互联）
├── segment.v                     # 七段数码管显示
├── extraction_mode.v             # 抽油烟机 1/2/3 档调度
├── self_cleaning_module.v        # 自清洁倒计时
├── accumulate_time.v             # 累计工作时长统计
├── audio_output.v                # 蜂鸣器 PWM 驱动
├── hand.v                        # 手势开关
├── countdown.v                   # 通用倒计时
├── countdown_advanced.v          # 带预置功能倒计时
├── current_time.v                # 当前走时
├── is_button_pressed.v           # 按键消抖
├── clock_divider1.v              # 时钟分频
├── char_fifo/                    # Vivado FIFO IP
├── clk_core/                     # Vivado Clocking Wizard IP
├── Tesr.srcs/                    # 源码 / 约束 / 仿真
├── Tesr.sim/                     # Vivado 仿真输出
├── Tesr.ip_user_files/           # IP 用户文件
├── Tesr.hw/                      # 硬件描述
├── main_tb_behav.wcfg            # 行为仿真波形配置
├── 最终答辩/                     # 答辩 PDF 与四种模式实拍图
│   ├── 温一楠&&魏宇晴&&李晏敏的抽油烟机.pdf
│   ├── 待机模式.jpg / 菜单模式.jpg
│   ├── 查询模式.jpg / 设置模式.jpg
├── Ego1_用户手册_v2.21.pdf       # 开发板用户手册
├── projects_introduction_中文.pdf # 课程项目任务书
├── vivado.log / vivado.jou       # Vivado 实现日志
└── README.md                     # 本文件
```

---

## 7. 使用说明

1. 安装 Vivado（支持 Xilinx Artix‑7 的版本）并克隆仓库：
   ```bash
   git clone https://github.com/csgrace/Digital-Logic.git
   cd Digital-Logic
   ```
2. 双击 `Tesr.xpr` 打开 Vivado 工程
3. **行为仿真**：点击 Run Behavioral Simulation，波形配置已保存在 `main_tb_behav.wcfg`
4. **上板验证**：依次运行 Synthesis → Implementation → Generate Bitstream，下载到 EGO1 开发板
5. 约束文件位于 `Tesr.srcs/constrs_1/`，包含所有引脚分配

> **注意**：提交代码中自清洁时间已调整为 **3 秒**便于演示。原始出厂参数（自清洁 3 min、飓风倒计时 60s、手势窗口 5s、累计提醒阈值 10 小时）可在代码中通过宏定义恢复。

---

## 8. 项目亮点

- **模块化设计**：将复杂的抽油烟机控制拆分为 10 + 个子模块，职责单一、复用方便；早期倒计时与显示高度耦合导致仿真失败，拆分后成功解决
- **状态机驱动**：顶层 FSM 统一调度所有模式切换，切换逻辑清晰、易于扩展
- **多设备交互**：同时使用按键、拨码开关、蓝牙串口作为输入，七段数码管、LED、蜂鸣器作为输出
- **跨时钟域处理**：使用 Vivado Clocking Wizard 与 FIFO IP 解决蓝牙串口与系统主时钟的异步通信
- **板级调试方法**：添加辅助信号实时监控状态机跳转与计时器触发，便于现场调试

### 开发日志概览

| 周次 | 进展 |
| --- | --- |
| Week 11 | 选题确认、Git 仓库搭建、状态机初步设计方案讨论 |
| Week 12 | 模块分工开发：倒计时 / 显示 / 按键 / 状态机 |
| Week 13 | 初次合并，发现状态机时序冲突，重新设计 FSM |
| Week 14 | 拆分倒计时与显示模块，实现蓝牙额外输入方案 |
| Week 15 | 终版合并，修复飓风模式与高级设置 bug，集成蜂鸣器提醒 |

---

**课程**：CS207 数字逻辑 · SUSTech · 2024 Fall
