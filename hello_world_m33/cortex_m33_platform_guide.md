# ARM Cortex-M33 Platform Architecture Guide

## Overview

This guide provides an in-depth explanation of the ARM Cortex-M33 platform definition used in Renode simulation. It serves as both an embedded systems architecture reference and a Renode modeling tutorial for educational purposes.

## Platform Configuration File

The platform is defined in `cortex_m33_platform.repl`:

```repl
// Custom ARM Cortex-M33 Board Definition
// This file defines a custom embedded board with ARM Cortex-M33 CPU
// suitable for educational purposes and bare-metal programming

cpu: CPU.CortexM @ sysbus
    cpuType: "cortex-m33"
    nvic: nvic

flash: Memory.MappedMemory @ sysbus 0x00000000
    size: 0x00100000

sram: Memory.MappedMemory @ sysbus 0x20000000
    size: 0x00040000

uart: UART.PL011 @ sysbus 0x40000000
    -> nvic@5

nvic: IRQControllers.NVIC @ sysbus 0xE000E000
    -> cpu@0
    priorityMask: 0xF0
    systickFrequency: 1000000
```

## Component Analysis

### 1. CPU: ARM Cortex-M33 Core

```repl
cpu: CPU.CortexM @ sysbus
    cpuType: "cortex-m33"
    nvic: nvic
```

#### Embedded Systems Architecture
- **Architecture**: ARM Cortex-M33 is an ARMv8-M architecture processor designed for microcontrollers
- **Key Features**:
  - 32-bit RISC processor with Thumb-2 instruction set
  - Optional TrustZone security extensions
  - Floating-point unit (FPU) support
  - Memory protection unit (MPU)
  - Harvard architecture with separate instruction and data buses
- **Role**: The central processing unit that executes firmware instructions, manages memory access, and coordinates with peripherals
- **Boot Process**: 
  - On reset, reads initial stack pointer (SP) from address 0x00000000
  - Reads reset vector (initial PC) from address 0x00000004
  - Begins execution from the reset handler

#### Renode Modeling
- **Declaration**: `CPU.CortexM` creates a Cortex-M series CPU instance
- **Bus Attachment**: `@ sysbus` connects the CPU to the system bus for memory and peripheral access
- **Core Specification**: `cpuType: "cortex-m33"` specifies the exact ARM core variant with its specific feature set
- **NVIC Integration**: `nvic: nvic` establishes the connection to the interrupt controller
- **Simulation Features**: Provides cycle-accurate execution, debugging support, and peripheral interaction

### 2. Flash Memory: Non-Volatile Program Storage

```repl
flash: Memory.MappedMemory @ sysbus 0x00000000
    size: 0x00100000
```

#### Embedded Systems Architecture
- **Type**: Non-volatile memory (retains data when power is removed)
- **Capacity**: 1MB (0x00100000 = 1,048,576 bytes)
- **Base Address**: 0x00000000 (start of the memory map)
- **Contents**:
  - Vector table (interrupt and exception handlers)
  - Application code (.text section)
  - Read-only data (.rodata section)
  - Initial values for initialized variables
- **Boot Significance**: ARM Cortex-M cores boot from address 0x0, making this the critical boot memory
- **Access Characteristics**: 
  - Read access: Fast (typically 1-2 CPU cycles)
  - Write access: Slow (if supported) and typically requires special programming sequences

#### Renode Modeling
- **Memory Type**: `Memory.MappedMemory` creates a simple, direct-mapped memory region
- **Address Mapping**: `@ sysbus 0x00000000` places it at the beginning of the address space
- **Firmware Loading**: Compatible with `sysbus LoadELF` command for loading compiled firmware
- **Debug Access**: Allows read/write access for debugging purposes (more permissive than real hardware)
- **Simulation Benefits**: Instant programming, no wear limitations, perfect reliability

### 3. SRAM: Volatile Working Memory

```repl
sram: Memory.MappedMemory @ sysbus 0x20000000
    size: 0x00040000
```

#### Embedded Systems Architecture
- **Type**: Static Random Access Memory - fast, volatile memory
- **Capacity**: 256KB (0x00040000 = 262,144 bytes)
- **Base Address**: 0x20000000 (standard ARM Cortex-M SRAM region)
- **Usage**:
  - Stack memory (grows downward from high addresses)
  - Heap memory (dynamic allocation)
  - Global and static variables (.data and .bss sections)
  - Local variables and function parameters
  - Buffers and temporary storage
- **Characteristics**:
  - Fast access (single cycle)
  - Volatile (loses data on power loss)
  - Limited capacity compared to flash
  - Full read/write access

#### Renode Modeling
- **Memory Type**: Same `Memory.MappedMemory` implementation as flash
- **Address Space**: `0x20000000` follows ARM's standard memory map conventions
- **Access Pattern**: Full read/write access for normal program execution
- **Initialization**: C runtime system initializes .data section and zeros .bss section here
- **Stack Simulation**: Stack pointer manipulation and overflow detection supported

### 4. UART: Serial Communication Peripheral

```repl
uart: UART.PL011 @ sysbus 0x40000000
    -> nvic@5
```

#### Embedded Systems Architecture
- **Function**: Universal Asynchronous Receiver/Transmitter for serial communication
- **Standard**: ARM PL011 UART (widely used in ARM-based systems)
- **Base Address**: 0x40000000 (peripheral memory region)
- **Register Interface**:
  - Data register (transmit/receive)
  - Control registers (baud rate, format, enable)
  - Status registers (busy, error flags)
  - Interrupt control registers
- **Communication Parameters**:
  - Configurable baud rate
  - Data bits (5-8)
  - Parity (none, odd, even)
  - Stop bits (1-2)
- **Interrupt Capability**: Generates interrupts for received data, transmission complete, errors

#### Renode Modeling
- **Peripheral Type**: `UART.PL011` provides authentic ARM PL011 UART register layout and behavior
- **Memory Mapping**: `@ sysbus 0x40000000` places control registers in standard peripheral space
- **Interrupt Connection**: `-> nvic@5` routes UART interrupts to NVIC interrupt line 5
- **Terminal Interface**: Use `showAnalyzer uart` command to open interactive console window
- **External Connections**: Can connect to host terminal, files, or other simulated devices
- **Protocol Support**: Full serial protocol simulation including timing and error conditions

### 5. NVIC: Nested Vectored Interrupt Controller

```repl
nvic: IRQControllers.NVIC @ sysbus 0xE000E000
    -> cpu@0
    priorityMask: 0xF0
    systickFrequency: 1000000
```

#### Embedded Systems Architecture
- **Purpose**: Manages all interrupts and exceptions in ARM Cortex-M systems
- **Location**: Fixed at 0xE000E000 (part of ARM's Private Peripheral Bus region)
- **Key Features**:
  - Nested interrupt support (higher priority interrupts can preempt lower priority ones)
  - Automatic context saving/restoration
  - Priority-based interrupt handling
  - Interrupt masking capabilities
  - Built-in SysTick timer
- **Priority System**: Configurable priority levels with preemption and sub-priority grouping
- **Vector Table Integration**: Works with firmware's interrupt vector table to dispatch handlers
- **SysTick Timer**: 24-bit down-counter for system timing and RTOS scheduling

#### Renode Modeling
- **Controller Type**: `IRQControllers.NVIC` implements full ARM NVIC specification
- **CPU Connection**: `-> cpu@0` connects NVIC output to CPU interrupt input line 0
- **Priority Configuration**: `priorityMask: 0xF0` specifies 4-bit priority resolution (16 priority levels)
- **SysTick Timing**: `systickFrequency: 1000000` sets SysTick clock to 1MHz (1μs resolution)
- **Interrupt Routing**: All peripheral interrupts connect to specific NVIC input lines
- **Debug Features**: Interrupt pending/active status visible in Renode monitor

## System Integration

### Memory Map

| Address Range | Component | Size | Purpose |
|---------------|-----------|------|---------|
| `0x00000000-0x000FFFFF` | Flash | 1MB | Program code and constants |
| `0x20000000-0x2003FFFF` | SRAM | 256KB | Runtime data and stack |
| `0x40000000-0x40000FFF` | UART | 4KB | Serial communication registers |
| `0xE000E000-0xE000EFFF` | NVIC | 4KB | Interrupt controller registers |

### Boot Sequence

1. **System Reset**: CPU begins execution at reset
2. **Vector Table Access**: 
   - Read initial stack pointer from `flash[0x0]`
   - Read reset vector (initial PC) from `flash[0x4]`
3. **Stack Initialization**: Set stack pointer to top of SRAM
4. **C Runtime Setup**: 
   - Copy .data section from flash to SRAM
   - Zero .bss section in SRAM
   - Call constructors for global objects
5. **Main Execution**: Jump to main() function
6. **Peripheral Initialization**: Configure UART, enable interrupts

### Interrupt Flow

1. **Event Trigger**: Peripheral (e.g., UART) detects an event requiring attention
2. **Interrupt Assertion**: Peripheral asserts its interrupt line to NVIC
3. **Priority Evaluation**: NVIC compares interrupt priority with current execution priority
4. **Context Switch**: If interrupt has higher priority:
   - Save current CPU context to stack
   - Look up handler address in vector table
   - Jump to interrupt service routine (ISR)
5. **Handler Execution**: ISR processes the interrupt and clears the interrupt flag
6. **Return**: CPU restores context and returns to interrupted code

### Communication Workflow

1. **Initialization**: Configure UART baud rate, format, and enable interrupts
2. **Transmission**: Write data to UART data register
3. **Reception**: UART receives data and triggers interrupt
4. **Interrupt Handling**: NVIC routes UART interrupt to CPU
5. **Data Processing**: ISR reads received data and processes it
6. **Response**: Optionally send response data back through UART

## Usage in Renode

### Loading the Platform

```bash
# Start Renode
renode

# Load the platform definition
(monitor) include @cortex_m33_platform.repl

# Load your firmware
(monitor) sysbus LoadELF @path/to/your/firmware.elf

# Open UART terminal
(monitor) showAnalyzer uart

# Start simulation
(monitor) start
```

### Common Commands

```bash
# Reset the system
(monitor) sysbus Reset

# Pause execution
(monitor) pause

# Single step execution
(monitor) sysbus Step

# Set breakpoint
(monitor) cpu SetBreakpoint 0x12345678

# Examine memory
(monitor) sysbus ReadDoubleWord 0x20000000

# Monitor CPU registers
(monitor) cpu PC
(monitor) cpu SP
```

## Educational Applications

### Learning Objectives

This platform setup enables students to:

1. **Understand ARM Cortex-M Architecture**:
   - Memory-mapped I/O concepts
   - Interrupt-driven programming
   - Stack and heap management
   - Boot process and vector tables

2. **Practice Bare-Metal Programming**:
   - Direct register manipulation
   - Interrupt service routine development
   - Memory management without OS
   - Real-time constraints and timing

3. **Debug Embedded Systems**:
   - Use of debugger and breakpoints
   - Memory and register inspection
   - Interrupt flow analysis
   - Performance profiling

4. **Explore System Integration**:
   - Peripheral initialization and configuration
   - Communication protocol implementation
   - System-level debugging techniques
   - Hardware-software interaction

### Example Projects

1. **Hello World**: Basic UART output using polling
2. **Interrupt-Driven UART**: Echo server using interrupt handling
3. **SysTick Timer**: LED blinking with precise timing
4. **Command Parser**: Interactive command-line interface
5. **Data Logger**: Collect and store sensor data
6. **Real-Time System**: Task scheduling with interrupts

## Advanced Topics

### Security Features (TrustZone)

The Cortex-M33 includes TrustZone security extensions:
- Secure and non-secure memory regions
- Secure function calls
- Interrupt security attribution
- Secure boot capabilities

### Performance Optimization

- Understanding instruction timing
- Memory access patterns
- Interrupt latency optimization
- Power management techniques

### Debug and Trace

- ITM (Instrumentation Trace Macrocell) usage
- ETM (Embedded Trace Macrocell) for program flow
- Breakpoint and watchpoint strategies
- Statistical profiling

## Conclusion

This ARM Cortex-M33 platform provides a comprehensive foundation for embedded systems education. It combines the essential components of a microcontroller system in a simulation environment that allows safe experimentation and learning. The platform accurately models real hardware behavior while providing the convenience and flexibility needed for educational purposes.

The combination of ARM's industry-standard architecture with Renode's powerful simulation capabilities creates an ideal learning environment for students and professionals