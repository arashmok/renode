# ARM Cortex-M33 Custom Board Educational Demo

This project demonstrates a **custom embedded board** equipped with an **ARM Cortex-M33 CPU**, simulated using Renode. It includes a complete bare-metal C program and serves as an educational example for understanding ARM-based embedded systems development and simulation.

## Project Overview

This custom board design features:
- **CPU**: ARM Cortex-M33 processor @ 100MHz
- **Memory**: 1MB Flash + 256KB SRAM
- **UART**: ARM PL011 UART for console communication
- **Software**: Custom bare-metal C program demonstrating UART communication and ARM concepts

The platform represents a typical ARM Cortex-M33 based microcontroller board that you might find in real embedded systems applications.

## Files Description

### Platform Definition
- **`cortex_m33_platform.repl`**: Renode platform description file defining the custom board's hardware components
- **`platform_startup_m33.resc`**: Renode script to load and configure the custom Cortex-M33 board

### Software
- **`hello_world_m33.c`**: Main C program demonstrating UART output and ARM Cortex-M33 concepts for the custom board
- **`startup_m33.S`**: ARM assembly startup code with vector table and system initialization for the custom board
- **`linker_m33.ld`**: Linker script defining memory layout for the custom ARM Cortex-M33 board

### Build System
- **`Makefile`**: Build configuration for compiling the ARM Cortex-M33 program

### Generated Files (after build)
- **`hello_world_m33.elf`**: Compiled ELF binary for the ARM platform
- **`hello_world_m33.bin`**: Raw binary output
- **`hello_world_m33.dump`**: Disassembly listing for debugging
- **`hello_world_m33.map`**: Memory map file showing symbol locations
- **`uart_output.log`**: Captured UART output from simulation

## Hardware Platform Details

### Memory Map
```
0x00000000 - 0x000FFFFF : Flash Memory (1MB)
0x20000000 - 0x2003FFFF : SRAM (256KB)
0x40000000              : UART (ARM PL011)
0xE000E000              : System Control Space (NVIC, SysTick, etc.)
```

### CPU Configuration
- Architecture: ARM Cortex-M33 (ARMv8-M Mainline)
- Clock Frequency: 100MHz
- Instruction Set: Thumb-2
- Features: NVIC, SysTick, Memory Protection Unit (MPU)
- Security: TrustZone capable (not used in this simple demo)

## Software Features

The demo program demonstrates:
1. **ARM Startup Sequence**: Proper vector table, reset handler, and memory initialization
2. **UART Communication**: PL011 UART driver for console output
3. **Bare-Metal Programming**: Direct hardware register access
4. **ARM Assembly**: Vector table and startup code in ARM assembly
5. **Memory Management**: Proper .data and .bss section handling
6. **Embedded C Patterns**: Volatile pointers, memory-mapped I/O

## Prerequisites

You need the following tools installed:
- **Renode**: For platform simulation
- **ARM GNU Toolchain**: `arm-none-eabi-gcc` and related tools for cross-compilation

### Installing ARM Toolchain

On Ubuntu/Debian:
```bash
sudo apt-get install gcc-arm-none-eabi
```

On Fedora:
```bash
sudo dnf install arm-none-eabi-gcc-cs arm-none-eabi-binutils-cs arm-none-eabi-newlib
```

## Building and Running

### 1. Build the Project
```bash
make clean && make
```

This will create:
- `hello_world_m33.elf` (main executable)
- `hello_world_m33.bin` (raw binary)
- `hello_world_m33.dump` (disassembly)

### 2. Run in Renode (Automated)
```bash
make run
```

### 3. Run in Renode (Interactive)
```bash
make debug
```

Then in the Renode console:
```
start
```

### 4. Manual Renode Execution
```bash
renode --console platform_startup_m33.resc
```

## Expected Output

The program will output:
```
===========================================
ARM Cortex-M33 Educational Demo
===========================================
Platform: Simple Cortex-M33 (Renode)
CPU: ARM Cortex-M33 @ 100MHz
Memory: 1MB Flash + 256KB SRAM
UART: PL011 @ 115200 baud
===========================================

Starting counter demonstration...
This demonstrates basic UART communication
and timing in a bare-metal ARM environment.

Counter: 0 - Cortex-M33 is running!
Counter: 1 - Cortex-M33 is running!
Counter: 2 - Cortex-M33 is running!
...
```

## Educational Value

This project teaches:

### ARM Cortex-M Concepts
- ARM Cortex-M33 architecture and features
- Vector table structure and interrupt handling
- Memory-mapped I/O and peripheral access
- ARM assembly language and calling conventions

### Embedded Systems Concepts
- Bare-metal programming without operating system
- Hardware abstraction through device drivers
- Memory layout and linker scripts
- Cross-compilation for ARM targets

### Renode Simulation
- Platform description language (.repl files)
- ARM processor simulation
- UART peripheral modeling
- Debugging embedded software

## ARM Cortex-M33 Specific Features

The Cortex-M33 includes several advanced features:
- **ARMv8-M Architecture**: Latest ARM microcontroller architecture
- **TrustZone**: Hardware security (not demonstrated in this simple example)
- **DSP Instructions**: Digital signal processing capabilities
- **Floating Point Unit**: Optional FPU support
- **Memory Protection Unit**: Enhanced memory protection

## Comparison with RISC-V Version

If you've seen the RISC-V version of this demo:

| Feature | ARM Cortex-M33 | RISC-V RV64IMAC |
|---------|----------------|-----------------|
| Architecture | ARMv8-M | RISC-V 64-bit |
| Instruction Set | Thumb-2 | RISC-V ISA |
| Interrupts | NVIC | PLIC/CLINT |
| Startup | Vector Table | Direct Jump |
| Toolchain | arm-none-eabi | riscv64-unknown-elf |
| Security | TrustZone | Custom Extensions |

## Troubleshooting

### Build Issues
- Ensure ARM toolchain is installed and in PATH
- Check that `arm-none-eabi-gcc` is available
- Verify Makefile paths are correct

### Simulation Issues
- Ensure Renode is installed and working
- Check that platform files are in the same directory
- Verify ELF file was built successfully

### No Output
- Check UART configuration in platform file
- Verify baud rate settings match
- Ensure UART is properly initialized in software

## Next Steps

To extend this educational platform:
1. Add GPIO control for LED blinking
2. Implement SysTick timer for precise timing
3. Add interrupt handlers for UART receive
4. Explore TrustZone security features
5. Add more peripherals (I2C, SPI, ADC)
6. Implement a simple RTOS on top

## Resources

- [ARM Cortex-M33 Technical Reference Manual](https://developer.arm.com/documentation/100235/latest/)
- [ARMv8-M Architecture Reference Manual](https://developer.arm.com/documentation/ddi0553/latest/)
- [Renode Documentation](https://renode.readthedocs.io/)
- [ARM Developer Documentation](https://developer.arm.com/documentation/)

This project provides a solid foundation for learning ARM Cortex-M embedded systems development and serves as a starting point for more complex projects.
