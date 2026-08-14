# FPGA-based Range Hood Controller

> CS207 Digital Logic Course Project @ SUSTech  
> Board: EGO1 (Xilinx Artix‑7) · Tool: Vivado · Language: Verilog

**Team**: Wen Yinan (12310841) · Li Yanmin (12311022) · Wei Yuqing (12311043)

---

## 1. Project Overview

This project implements a complete **range hood controller** on the EGO1 development board using Verilog. A finite state machine (FSM) serves as the central scheduler, coordinating multiple I/O devices — push buttons, DIP switches, 7‑segment displays, LEDs, a buzzer, and a Bluetooth module — to deliver all required course features: power on/off, 3‑speed extraction, self‑cleaning, time display & adjustment, accumulated runtime tracking with smart cleaning alerts, lighting control, and gesture‑based switching. Two bonus features — Bluetooth remote control and buzzer smart alerts — are also included.

---

## 2. Technology Stack

| Category | Technology / Tool |
| --- | --- |
| Hardware Description Language | Verilog HDL |
| Target Platform | EGO1 (Xilinx XC7A35T‑1CSG324C Artix‑7 FPGA) |
| Development & Simulation | Vivado Design Suite (with XSim behavioral simulation) |
| Clock Management | Vivado Clocking Wizard IP (`clk_core`) |
| Data Buffering | Vivado FIFO Generator IP (`char_fifo`) |
| Version Control | Git / GitHub |
| Input Devices | Push buttons, DIP switches, Bluetooth serial module |
| Output Devices | 7‑segment displays (6‑digit), LED indicators, Buzzer PWM, Bluetooth module |

---

## 3. Implemented Features

### 3.1 Power On / Off

| Feature | Description |
| --- | --- |
| Short‑press power on | Press the power button to start the range hood; enters standby mode, initializes current time to 00:00:00, resets accumulated runtime |
| Long‑press power off | Hold the power button for **3 seconds** to shut down; all buttons are disabled after shutdown |
| Gesture switch (bonus) | Simulates IR gesture: press left button to start a 5s window, then press right = power on; press right first then left = power off; timeout cancels the operation |

### 3.2 Mode Switching

The system enters **standby mode** by default after power‑on. All mode transitions are routed through standby:

- Standby → Extraction mode (Level 1 / 2 / 3)
- Standby → Self‑cleaning mode
- Level 1 ↔ Level 2 can switch freely
- Level 1 / Level 2: press Menu key to return directly to standby
- Level 3: press Menu key to start a **60s countdown** back to standby
- Self‑cleaning: press Menu key to return to standby; auto‑returns when finished

### 3.3 Extraction Function

| Level | Behavior |
| --- | --- |
| Level 1 | Runs continuously; can switch to Level 2; press Menu to return to standby |
| Level 2 | Runs continuously; can switch to Level 1; press Menu to return to standby |
| **Level 3 (Hurricane Mode)** | ① Usable only **once per power‑on cycle** — repeated presses are ignored; ② Enters a **60s countdown** on activation, automatically downgrades to Level 2 when done; ③ If Menu is pressed during the countdown, a separate "return to standby" countdown starts and enters standby when it expires |

Entering any extraction level automatically starts **accumulated runtime tracking**; leaving extraction mode stops and stores the count.

### 3.4 Self‑Cleaning Function

- Can only be entered from standby mode
- Starts a **3‑minute countdown**; buzzer signals "self‑cleaning complete" and automatically returns to standby
- **Accumulated runtime is cleared** after self‑cleaning completes

### 3.5 Auxiliary Functions

| Feature | Description |
| --- | --- |
| **Lighting** | Lighting can be toggled independently in any powered‑on mode |
| **Time Display** | Dynamically shows current time (hours / minutes / seconds) on the 7‑segment display |
| **Time Setting** | In standby mode, enter edit mode to adjust hours, minutes, and seconds individually |
| **Smart Alert** | When accumulated extraction time reaches a threshold (**10 hours** by default), buzzer + LED alert is triggered in standby mode; threshold is adjustable in advanced settings; reset after self‑cleaning |
| **Advanced Settings** | In standby mode: ① Set accumulated‑runtime alert threshold; ② Set gesture switch window time; ③ Restore factory defaults |
| **Query Function** | In standby mode: ① Query accumulated extraction runtime; ② Query gesture switch window time |

### 3.6 Bonus Features

- ✅ Gesture power on/off (left + right button sequence simulates IR gesture, 5s window)
- ✅ Bluetooth remote lighting control (modified from EGO1 Bluetooth lab module, UART communication)
- ✅ Buzzer smart alert (PWM‑driven passive buzzer sounds when accumulated runtime exceeds threshold)

---

## 4. System Architecture

### 4.1 Top‑Level Design

The top‑level module `Main.v` hosts a finite state machine (FSM) at its core, coordinating all sub‑modules through instantiation:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Main.v (Top)                             │
│  clk │ rst │ btn1~btn5 │ sw │ Bluetooth inputs                 │
│                          ▼                                       │
│               ┌──────────────────────┐                          │
│               │   FSM (Core)         │ ◄── clk_core, char_fifo  │
│               │ Standby│Menu│Query   │                          │
│               │ Setting│L1│L2│L3     │                          │
│               │ Self‑cleaning        │                          │
│               └──────────┬───────────┘                          │
│                          │                                       │
│         ┌────────────────┼───────────────────┐                  │
│         ▼                ▼                    ▼                  │
│  ┌─────────────┐  ┌────────────┐  ┌──────────────────┐          │
│  │ Timing /    │  │ Mode       │  │ Output           │          │
│  │ Display     │  │ Control    │  │ Drivers          │          │
│  │             │  │            │  │                  │          │
│  │ countdown   │  │ extraction │  │ segment.v        │          │
│  │ countdown_  │  │ _mode      │  │ (7‑segment)      │          │
│  │  advanced   │  │            │  │                  │          │
│  │ current_time│  │ self_      │  │ audio_output.v   │          │
│  │ accumulate_ │  │ cleaning   │  │ (buzzer PWM)     │          │
│  │  time       │  │ _module    │  │                  │          │
│  │             │  │            │  │ Lighting / LEDs  │          │
│  │             │  │ hand.v     │  │ Bluetooth ctrl   │          │
│  │             │  │ (gesture)  │  │                  │          │
│  └─────────────┘  └────────────┘  └──────────────────┘          │
│                                                                  │
│  segments │ segment_control │ audio_sd/pwm │ light │ bt_*     │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Sub‑Modules

| Module | File | Responsibility |
| --- | --- | --- |
| `segment` | `segment.v` | 6‑digit 7‑segment display driver; converts total seconds to HH:MM:SS |
| `extraction_mode` | `extraction_mode.v` | Level 1/2/3 scheduling: hurricane single‑use lock, 60s countdown, forced‑return‑to‑standby logic |
| `self_cleaning_module` | `self_cleaning_module.v` | Self‑cleaning 3‑min countdown and done signal |
| `accumulate_time` | `accumulate_time.v` | Accumulated extraction runtime; triggers buzzer signal when threshold reached |
| `audio_output` | `audio_output.v` | Buzzer PWM driver; generates the target frequency |
| `hand` | `hand.v` | Gesture switch: left/right button sequence detection + configurable window countdown |
| `bt_uart` | source tree | Bluetooth UART communication; parses commands and controls lighting |
| `countdown` / `countdown_advanced` | `countdown.v` / `countdown_advanced.v` | General‑purpose countdown / preset‑capable countdown |
| `current_time` | `current_time.v` | Current clock (hours / minutes / seconds cycling) |
| `is_button_pressed` | `is_button_pressed.v` | Button debounce |
| `clock_divider1` | `clock_divider1.v` | Clock divider (generates 1Hz time base etc.) |
| `clk_core` | IP | Vivado Clocking Wizard — generates system clocks |
| `char_fifo` | IP | Vivado FIFO Generator — cross‑clock‑domain data buffer |

### 4.3 Top‑Level Ports

| Direction | Signal | Description |
| --- | --- | --- |
| input | `clk`, `rst` | System clock, reset |
| input | `btn1` ~ `btn5` | 5 push‑button inputs |
| input | `sw` | Gesture switch |
| input | `rst_n`, `sw_pin`, `rxd_pin`, `lb_sel_pin` | Bluetooth module inputs |
| output | `bt_pw_on`, `bt_master_slave`, `bt_sw_hw`, `bt_rst_n`, `bt_sw`, `bl_power_on` | Bluetooth module control |
| output | `sw_light`, `light` | Lighting control / output |
| output | `segment1_control` ~ `segment6_control` | 6‑digit display digit enable |
| output | `segments` | 7‑segment segment data |
| output | `beelight` | Work‑threshold LED indicator |
| output | `edit_index_light`, `setting_page_index_light`, `query_page_index_light` | Edit / Setting / Query status LEDs |
| output | `audio_sd`, `audio_pwm` | Buzzer SD / PWM control |

---

## 5. Four Main Modes (EGO1 Captures)

| Standby | Menu | Query | Setting |
| --- | --- | --- | --- |
| ![Standby](https://raw.githubusercontent.com/csgrace/Digital-Logic/main/最终答辩/待机模式.jpg) | ![Menu](https://raw.githubusercontent.com/csgrace/Digital-Logic/main/最终答辩/菜单模式.jpg) | ![Query](https://raw.githubusercontent.com/csgrace/Digital-Logic/main/最终答辩/查询模式.jpg) | ![Setting](https://raw.githubusercontent.com/csgrace/Digital-Logic/main/最终答辩/设置模式.jpg) |

---

## 6. Repository Structure

```
Digital-Logic/
├── Tesr.xpr                      # Vivado project file
├── Main.v                        # Top‑level module (FSM + sub‑module interconnection)
├── segment.v                     # 7‑segment display driver
├── extraction_mode.v             # Extraction Level 1/2/3 scheduling
├── self_cleaning_module.v        # Self‑cleaning countdown
├── accumulate_time.v             # Accumulated runtime tracking
├── audio_output.v                # Buzzer PWM driver
├── hand.v                        # Gesture switch
├── countdown.v                   # General‑purpose countdown
├── countdown_advanced.v          # Preset‑capable countdown
├── current_time.v                # Current clock
├── is_button_pressed.v           # Button debounce
├── clock_divider1.v              # Clock divider
├── char_fifo/                    # Vivado FIFO IP
├── clk_core/                     # Vivado Clocking Wizard IP
├── Tesr.srcs/                    # Sources / Constraints / Simulation
├── Tesr.sim/                     # Vivado simulation output
├── Tesr.ip_user_files/           # IP user files
├── Tesr.hw/                      # Hardware description
├── main_tb_behav.wcfg            # Behavioral simulation waveform config
├── 最终答辩/                     # Defense PDF & mode captures
│   ├── 温一楠&&魏宇晴&&李晏敏的抽油烟机.pdf
│   ├── 待机模式.jpg / 菜单模式.jpg
│   ├── 查询模式.jpg / 设置模式.jpg
├── Ego1_用户手册_v2.21.pdf       # Board user manual
├── projects_introduction_中文.pdf # Course project spec
├── vivado.log / vivado.jou       # Vivado implementation logs
└── README.md                     # This file
```

---

## 7. Getting Started

1. Install Vivado (version supporting Xilinx Artix‑7) and clone the repo:
   ```bash
   git clone https://github.com/csgrace/Digital-Logic.git
   cd Digital-Logic
   ```
2. Open `Tesr.xpr` to launch the Vivado project
3. **Behavioral Simulation**: click **Run Behavioral Simulation**; waveform config is saved in `main_tb_behav.wcfg`
4. **On‑Board Verification**: run **Synthesis → Implementation → Generate Bitstream** in sequence, then program the EGO1
5. Constraint files are in `Tesr.srcs/constrs_1/` — includes all pin assignments

> **Note**: In the submitted code, the self‑cleaning time has been shortened to **3 seconds** for demonstration purposes. Original factory parameters (self‑cleaning 3 min, hurricane countdown 60s, gesture window 5s, runtime alert threshold 10 hours) can be restored via `define` macros.

---

## 8. Project Highlights

- **Modular design**: Complex range hood control decomposed into 10+ single‑responsibility sub‑modules. An early attempt tightly coupling countdown and display caused simulation failures; separating them resolved the issue cleanly.
- **FSM‑driven**: A top‑level state machine centrally schedules all mode transitions — clear, predictable, and easy to extend.
- **Multi‑device I/O**: Simultaneously uses push buttons, DIP switches, and Bluetooth UART as inputs; 7‑segment displays, LEDs, and buzzer as outputs.
- **Cross‑clock‑domain handling**: Vivado Clocking Wizard and FIFO IP bridge the Bluetooth UART and main system clock domains.
- **On‑board debugging**: Auxiliary observation signals were added to monitor FSM transitions and timer triggers in real time.

### Development Log

| Week | Milestone |
| --- | --- |
| Week 11 | Topic selection, Git repo setup, initial FSM design discussion |
| Week 12 | Parallel module development: countdown / display / buttons / FSM |
| Week 13 | First integration — FSM timing conflict discovered; redesigned FSM |
| Week 14 | Split countdown and display into separate modules; implemented Bluetooth input |
| Week 15 | Final integration; fixed hurricane mode and advanced settings bugs; integrated buzzer alert |
