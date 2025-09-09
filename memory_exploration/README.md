# Memory Exploration Project for Renode

This is a minimal Cortex-M33 project designed for exploring memory and CPU registers using VSCode debugging tools with Renode.

## Project Structure

- `simple_m33.repl` - Minimal platform definition with Cortex-M33 CPU and SRAM
- `memory_test.c` - Simple C program that manipulates memory using pointers
- `startup.S` - Minimal startup assembly code
- `linker.ld` - Simple linker script mapping everything to SRAM
- `Makefile` - Build configuration

## Platform Features

The platform contains only the essential components:
- ARM Cortex-M33 CPU
- 64KB SRAM at 0x20000000
- NVIC (required for Cortex-M33)

No peripherals like UART, timers, or other I/O devices are included to keep it minimal.

## Building

Make sure you have the ARM GCC toolchain installed:

```bash
make clean
make all
```

This will generate:
- `memory_test.elf` - ELF file for debugging
- `memory_test.bin` - Binary file
- `memory_test.dump` - Disassembly dump

## Running in Renode

1. Start Renode
2. Load the platform and run:

```
(monitor) include @simple_m33.repl
(monitor) sysbus LoadELF @memory_test.elf
(monitor) start
```

## VSCode Debugging

1. Connect VSCode to Renode using the appropriate Renode extension
2. Set breakpoints in `memory_test.c`
3. Use the memory viewer to observe:
   - SRAM content at 0x20000000
   - Global variables and arrays
   - Register values in the CPU

## Memory Layout

- **SRAM**: 0x20000000 - 0x2000FFFF (64KB)
- **Stack**: Top of SRAM (0x20010000)
- **Variables**: Located in SRAM

The program writes test patterns to memory that you can observe through the debugger:
- 0xDEADBEEF at SRAM base
- 0xCAFEBABE at SRAM base + 4
- 0xFEEDFACE at SRAM base + 8
- Pattern data in test_array[]
