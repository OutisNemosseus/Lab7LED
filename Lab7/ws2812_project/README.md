# WS2812 LED Driver - ENGR 110 Lab 6

## 项目概述

本项目实现了一个用于控制 WS2812 RGB LED 的数字驱动器，运行在 DE10-Lite FPGA 开发板上。

## 文件结构

```
ws2812_project/
├── LedDriver.sv        # 顶层模块
├── ShiftController.sv  # 发送控制器（整合 BitSender 和 ShiftRegister）
├── ShiftRegister.sv    # 24-bit 移位寄存器
├── BitSender.sv        # 单个 bit 时序生成器
├── Mapping.sv          # 3-bit 到 8-bit 映射
├── LedTestbench.sv     # 仿真测试平台
├── simulate.do         # ModelSim 仿真脚本
├── LedDriver.qpf       # Quartus 项目文件
├── LedDriver.qsf       # 引脚分配
├── LedDriver_settings.qsf  # Quartus 设置
└── LedDriver.sdc       # 时序约束
```

## 模块说明

### 1. Mapping 模块

**功能**: 将 3-bit 开关输入 (0-7) 映射到 8-bit 颜色值 (0-255)

**映射表**:
| 输入 (3-bit) | 输出 (8-bit) |
|--------------|--------------|
| 0 | 0   |
| 1 | 36  |
| 2 | 73  |
| 3 | 109 |
| 4 | 146 |
| 5 | 182 |
| 6 | 219 |
| 7 | 255 |

### 2. BitSender 模块

**功能**: 根据要发送的 bit 值 (0 或 1) 生成正确的 WS2812 时序波形

**WS2812 时序要求** (来自 datasheet):

| 参数 | 描述 | 时间 | 容差 | 50MHz 时钟周期数 |
|------|------|------|------|------------------|
| T0H | 0 码高电平 | 0.35µs | ±150ns | 18 cycles (360ns) |
| T1H | 1 码高电平 | 0.7µs | ±150ns | 35 cycles (700ns) |
| T0L | 0 码低电平 | 0.8µs | ±150ns | 40 cycles (800ns) |
| T1L | 1 码低电平 | 0.6µs | ±150ns | 30 cycles (600ns) |
| RES | 复位信号 | >50µs | - | 4000 cycles (80µs) |

**状态机**:
```
IDLE → HIGH → LOW → IDLE
         ↑        |
         └────────┘ (循环发送)
```

### 3. ShiftRegister 模块

**功能**: 24-bit 移位寄存器，存储 GRB 颜色数据并串行输出

**数据格式**: `[G7:G0, R7:R0, B7:B0]` - 绿色先发，MSB 先发

**操作**:
- `load`: 并行加载 24-bit 数据
- `shift_en`: 左移一位
- `bit_out`: 输出当前 MSB

### 4. ShiftController 模块

**功能**: 控制整个 24-bit 数据发送流程和 RESET 信号生成

**状态机**:
```
IDLE → SEND_BIT → WAIT_DONE → SHIFT → ... (重复 24 次) → RESET_LED → IDLE
```

**操作流程**:
1. 在 IDLE 状态加载 24-bit GRB 数据
2. 触发 BitSender 发送当前 bit
3. 等待 BitSender 完成
4. 移位寄存器左移，准备下一个 bit
5. 重复步骤 2-4，共 24 次
6. 发送完成后，保持低电平 80µs (RESET)
7. 返回 IDLE，开始新的帧

### 5. LedDriver 模块 (顶层)

**功能**: 整合所有子模块，提供外部接口

**接口**:
| 信号 | 方向 | 宽度 | 描述 |
|------|------|------|------|
| clk | 输入 | 1 | 50MHz 系统时钟 |
| reset_n | 输入 | 1 | 低电平有效复位 (KEY0) |
| red | 输入 | 3 | 红色强度 (SW[5:3]) |
| green | 输入 | 3 | 绿色强度 (SW[8:6]) |
| blue | 输入 | 3 | 蓝色强度 (SW[2:0]) |
| ws2812 | 输出 | 1 | WS2812 数据输出 |

## 时序图

### 单个 Bit 波形

```
0 码:
      ┌───┐
      │   │
──────┘   └──────────────
      T0H     T0L
     360ns   800ns

1 码:
      ┌───────┐
      │       │
──────┘       └──────────
        T1H      T1L
       700ns    600ns
```

### 24-bit 帧

```
|← G7 →|← G6 →|...|← B0 →|←──── RESET ────→|← G7 →|...
                          >50µs (我们用80µs)
```

## 硬件连接

### DE10-Lite 引脚分配

| FPGA 引脚 | 信号 | 连接 |
|-----------|------|------|
| PIN_P11 | clk | 板载 50MHz 时钟 |
| PIN_B8 | reset_n | KEY0 按钮 |
| PIN_C10 | blue[0] | SW0 |
| PIN_C11 | blue[1] | SW1 |
| PIN_D12 | blue[2] | SW2 |
| PIN_C12 | red[0] | SW3 |
| PIN_A12 | red[1] | SW4 |
| PIN_B12 | red[2] | SW5 |
| PIN_A13 | green[0] | SW6 |
| PIN_A14 | green[1] | SW7 |
| PIN_B14 | green[2] | SW8 |
| PIN_V10 | ws2812 | Arduino Header GPIO_0 |

### WS2812 接线

```
DE10-Lite                    WS2812
┌─────────┐                 ┌──────┐
│ 5V (Ard)├─────────────────┤ VDD  │
│ GND     ├─────────────────┤ VSS  │
│ GPIO_0  ├─────────────────┤ DIN  │
│         │                 │ DOUT │─── (不要连接回 FPGA!)
└─────────┘                 └──────┘
```

⚠️ **警告**: 
- WS2812 必须使用 5V 供电 (Arduino 排针上的 5V)
- 绝对不要将 WS2812 的 DOUT 连接回 FPGA，因为它是 5V 逻辑电平！

## 仿真

### 使用 ModelSim

1. 打开 ModelSim
2. 切换到项目目录: `cd <project_path>`
3. 运行仿真脚本: `do simulate.do`
4. 查看波形，验证时序

### 关键验证点

1. **T0H 时序**: 0 码高电平应为 ~360ns
2. **T1H 时序**: 1 码高电平应为 ~700ns
3. **24-bit 帧**: 应该连续发送 24 个 bit
4. **RESET**: 24 bit 后应有 >50µs 的低电平
5. **数据顺序**: GRB 顺序，MSB 先发

## Prelab 问题答案

### 问题 1: 时序表

| 时间名 | Bit类型/电平 | 时间 (µs) | 误差范围 (ns) |
|--------|--------------|-----------|---------------|
| T0H | 0码, 高电平 | 0.35 | ±150 |
| T1H | 1码, 高电平 | 0.7 | ±150 |
| T0L | 0码, 低电平 | 0.8 | ±150 |
| T1L | 1码, 低电平 | 0.6 | ±150 |
| RESET | 复位, 低电平 | >50 | - |

### 问题 2: 时钟周期计算

50MHz 时钟周期 = 20ns

- **0 码**: T0H + T0L = 0.35µs + 0.8µs = 1.15µs
  - 周期数: 1.15µs / 20ns = 57.5 cycles ≈ 58 cycles
  
- **1 码**: T1H + T1L = 0.7µs + 0.6µs = 1.3µs
  - 周期数: 1.3µs / 20ns = 65 cycles

详细:
- T0H: 0.35µs / 20ns = 17.5 ≈ 18 cycles
- T1H: 0.7µs / 20ns = 35 cycles
- T0L: 0.8µs / 20ns = 40 cycles
- T1L: 0.6µs / 20ns = 30 cycles

### 问题 3: 3-bit 到 8-bit 映射

见 `Mapping.sv` 模块

## Postlab 问题提示

### 问题 1: 最大 LED 数量 @60Hz

- 每个 LED: 24 bits × 1.25µs = 30µs
- RESET: 50µs
- 60Hz 帧周期: 1/60 = 16.67ms = 16670µs
- 最大 LED 数: (16670 - 50) / 30 ≈ 554 个

### 问题 2: 10MHz 时钟

- 时钟周期: 100ns
- T0H 最小需要 350ns - 150ns = 200ns = 2 cycles
- 精度下降，但仍可满足要求
- 需要调整计数器参数

### 问题 3: 多 LED 控制

需要扩展设计，加入:
- 多个 24-bit 数据寄存器
- LED 计数器
- 按顺序发送多个 LED 数据后再发 RESET

## 作者

ENGR 110 Lab 6 - WS2812 LED Driver
