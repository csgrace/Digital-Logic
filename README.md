# FPGA-based Range Hood Controller

> **CS202 Digital Logic Course Project**
>
> Complete range hood controller implemented on EGO1 FPGA — FSM-driven, 4 main modes, 10+ sub-modules, multi-device I/O.

---

## Overview

This project implements a full-featured **range hood controller** on the **EGO1 development board** (Xilinx Artix-7). A finite state machine (FSM) serves as the central scheduler, coordinating multiple I/O devices: push buttons, DIP switches, 7-segment displays, LEDs, a buzzer, and a Bluetooth module.

Implemented features: power on/off (short/long press), 3-speed extraction (with hurricane mode lock & 60s countdown), self-cleaning (3-min countdown with runtime reset), time display & adjustment, accumulated runtime tracking with smart cleaning alerts, lighting control, and gesture-based switching. Two bonus features — Bluetooth remote control and buzzer smart alerts — are also included.

Design flow:

```
Spec Analysis -> FSM Design -> Sub-Module Development -> Integration -> Simulation -> FPGA Validation
```

---

## Architecture

### Top-Level Design

The top-level module `Main.v` hosts a finite state machine (FSM) at its core, coordinating all sub-modules through instantiation:

```
+--------------------------------------------------------------------+
|                        Main.v (Top)                                |
|  clk | rst | btn1~btn5 | sw | Bluetooth inputs                      |
|                             |                                      |
|                  +---------------------+                           |
|                  |    FSM (Core)       | <-- clk_core, char_fifo   |
|                  | Standby|Menu|Query   |                           |
|                  | Setting|L1|L2|L3     |                           |
|                  | Self-cleaning       |                           |
|                  +----------+----------+                           |
|                             |                                      |
|            +----------------+-------------------+                  |
|            v                v                   v                  |
|  +----------------+  +-------------+  +---------------------+      |
|  | Timing /       |  | Mode        |  | Output              |      |
|  | Display        |  | Control     |  | Drivers             |      |
|  |                |  |             |  |                     |      |
|  | countdown      |  | extraction  |  | segment.v           |      |
|  | countdown_adv  |  | _mode       |  | (7-segment)         |      |
|  | current_time   |  |             |  |                     |      |
|  | accumulate_time|  | self_       |  | audio_output.v      |      |
|  |                |  | cleaning    |  | (buzzer PWM)        |      |
|  |                |  | _module     |  |                     |      |
|  |                |  |             |  | Lighting / LEDs     |      |
|  |                |  | hand.v      |  | Bluetooth ctrl      |      |
|  |                |  | (gesture)   |  |                     |      |
|  +----------------+  +-------------+  +---------------------+      |
|                                                                    |
|  segments | segment_control | audio_sd/pwm | light | bt_*        |
+--------------------------------------------------------------------+
```

### Sub-Modules

| Module | File | Responsibility |
|--------|------|----------------|
| `segment` | `segment.v` | 6-digit 7-segment display driver; converts total seconds to HH:MM:SS |
| `extraction_mode` | `extraction_mode.v` | Level 1/2/3 scheduling: hurricane single-use lock, 60s countdown, forced-return-to-standby logic |
| `self_cleaning_module` | `self_cleaning_module.v` | Self-cleaning 3-min countdown and done signal |
| `accumulate_time` | `accumulate_time.v` | Accumulated extraction runtime; triggers buzzer signal when threshold reached |
| `audio_output` | `audio_output.v` | Buzzer PWM driver; generates the target frequency |
| `hand` | `hand.v` | Gesture switch: left/right button sequence detection + configurable window countdown |
| `bt_uart` | source tree | Bluetooth UART communication; parses commands and controls lighting |
| `countdown` / `countdown_advanced` | `countdown.v` / `countdown_advanced.v` | General-purpose countdown / preset-capable countdown |
| `current_time` | `current_time.v` | Current clock (hours / minutes / seconds cycling) |
| `is_button_pressed` | `is_button_pressed.v` | Button debounce |
| `clock_divider1` | `clock_divider1.v` | Clock divider (generates 1Hz time base etc.) |
| `clk_core` | IP | Vivado Clocking Wizard -- generates system clocks |
| `char_fifo` | IP | Vivado FIFO Generator -- cross-clock-domain data buffer |

### Top-Level Ports

| Direction | Signal | Description |
|-----------|--------|-------------|
| input | `clk`, `rst` | System clock, reset |
| input | `btn1` ~ `btn5` | 5 push-button inputs |
| input | `sw` | Gesture switch |
| input | `rst_n`, `sw_pin`, `rxd_pin`, `lb_sel_pin` | Bluetooth module inputs |
| output | `bt_pw_on`, `bt_master_slave`, `bt_sw_hw`, `bt_rst_n`, `bt_sw`, `bl_power_on` | Bluetooth module control |
| output | `sw_light`, `light` | Lighting control / output |
| output | `segment1_control` ~ `segment6_control` | 6-digit display digit enable |
| output | `segments` | 7-segment segment data |
| output | `beelight` | Work-threshold LED indicator |
| output | `edit_index_light`, `setting_page_index_light`, `query_page_index_light` | Edit / Setting / Query status LEDs |
| output | `audio_sd`, `audio_pwm` | Buzzer SD / PWM control |

### Technology Stack

| Category | Technology / Tool |
|----------|-------------------|
| Hardware Description Language | Verilog HDL |
| Target Platform | EGO1 (Xilinx XC7A35T-1CSG324C Artix-7 FPGA) |
| Development & Simulation | Vivado Design Suite (with XSim behavioral simulation) |
| Clock Management | Vivado Clocking Wizard IP (`clk_core`) |
| Data Buffering | Vivado FIFO Generator IP (`char_fifo`) |
| Version Control | Git / GitHub |

---

## Key Features

### Mode Switching

The system enters **standby mode** by default after power-on. All mode transitions are routed through standby:

- Standby -> Extraction mode (Level 1 / 2 / 3)
- Standby -> Self-cleaning mode
- Level 1 <-> Level 2 can switch freely
- Level 1 / Level 2: press Menu key to return directly to standby
- Level 3: press Menu key to start a **60s countdown** back to standby
- Self-cleaning: press Menu key to return to standby; auto-returns when finished

### Extraction Levels

| Level | Behavior |
|-------|----------|
| Level 1 | Runs continuously; can switch to Level 2; press Menu to return to standby |
| Level 2 | Runs continuously; can switch to Level 1; press Menu to return to standby |
| **Level 3 (Hurricane Mode)** | 1) Usable only **once per power-on cycle** -- repeated presses are ignored; 2) Enters a **60s countdown** on activation, automatically downgrades to Level 2 when done; 3) If Menu is pressed during the countdown, a separate "return to standby" countdown starts and enters standby when it expires |

### Bonus Features

- Gesture power on/off (left + right button sequence simulates IR gesture, 5s window)
- Bluetooth remote lighting control (modified from EGO1 Bluetooth lab module, UART communication)
- Buzzer smart alert (PWM-driven passive buzzer sounds when accumulated runtime exceeds threshold)

---

## Getting Started

**Tools:** Vivado (supports Xilinx Artix-7)

```bash
git clone https://github.com/csgrace/Digital-Logic.git
cd Digital-Logic
vivado Tesr.xpr
```

Then run **Synthesis -> Implementation -> Generate Bitstream** in sequence, then program the EGO1. Constraint files are in `Tesr.srcs/constrs_1/`.

> **Note:** In the submitted code, the self-cleaning time has been shortened to **3 seconds** for demonstration purposes. Original factory parameters (self-cleaning 3 min, hurricane countdown 60s, gesture window 5s, runtime alert threshold 10 hours) can be restored via `define` macros.

---

## Repository

```
Digital-Logic/
  Tesr.xpr                      # Vivado project file
  Main.v                        # Top-level module (FSM + sub-module interconnection)
  segment.v                     # 7-segment display driver
  extraction_mode.v             # Extraction Level 1/2/3 scheduling
  self_cleaning_module.v        # Self-cleaning countdown
  accumulate_time.v             # Accumulated runtime tracking
  audio_output.v                # Buzzer PWM driver
  hand.v                        # Gesture switch
  countdown.v                   # General-purpose countdown
  countdown_advanced.v          # Preset-capable countdown
  current_time.v                # Current clock
  is_button_pressed.v           # Button debounce
  clock_divider1.v              # Clock divider
  char_fifo/                    # Vivado FIFO IP
  clk_core/                     # Vivado Clocking Wizard IP
  Tesr.srcs/                    # Sources / Constraints / Simulation
  Tesr.sim/                     # Vivado simulation output
  main_tb_behav.wcfg            # Behavioral simulation waveform config
  Ego1_手册.pdf                  # Board user manual
  README.md
```

---

## Highlights

- **Modular design**: Complex range hood control decomposed into 10+ single-responsibility sub-modules. An early attempt tightly coupling countdown and display caused simulation failures; separating them resolved the issue cleanly.
- **FSM-driven**: A top-level state machine centrally schedules all mode transitions -- clear, predictable, and easy to extend.
- **Multi-device I/O**: Simultaneously uses push buttons, DIP switches, and Bluetooth UART as inputs; 7-segment displays, LEDs, and buzzer as outputs.
- **Cross-clock-domain handling**: Vivado Clocking Wizard and FIFO IP bridge the Bluetooth UART and main system clock domains.
- **On-board debugging**: Auxiliary observation signals were added to monitor FSM transitions and timer triggers in real time.

---

*CS207 @ SUSTech*
