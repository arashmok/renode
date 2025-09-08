# Multi-Machine UART Hub Communication Demo

This project demonstrates inter-machine communication using Renode's UART hub functionality.

## Files

- `demo.resc` - Main demo script
- `simple_platform.repl` - Platform description for RISC-V machines
- `uart_test.elf` - Simple test program that outputs to UART0 and UART1
- `uart_test.c` - Source code for the test program
- `LEARNING_MATERIAL.md` - **Deep dive explanation of .resc and .repl files**

## How to Run

1. **Start the demo:**
   ```bash
   cd /home/octets/renode/multi-machine_demo
   renode demo.resc
   ```

2. **What you'll see:**
   - Two machines (machine1 and machine2) will start
   - UART analyzer windows will open automatically
   - Both machines will output console messages

## Expected Output

### UART0 Windows (Console Output)
- Machine1: "Machine starting..."
- Machine2: "Machine starting..."

### UART1 Windows (Hub Communication)
- Each UART1 window should show "Hello from machine!" **twice**:
  - Once from the local machine
  - Once from the remote machine via the hub

## What This Demonstrates

- ✅ Multi-machine setup in Renode
- ✅ UART hub connectivity between machines
- ✅ Bidirectional communication via shared UART hub
- ✅ Clean simulation without memory warnings
- ✅ Proper platform description and ELF loading

## Technical Details

- **Platform**: RISC-V 32-bit (rv32imac)
- **Memory**: DDR at 0x80000000, Flash at 0x20000000
- **UARTs**: UART0 for console, UART1 for hub communication
- **Hub**: Connects both machines' UART1 for inter-machine communication

## Notes

The test program sends one message and then goes into a wait-for-interrupt loop. For continuous communication, custom sender/receiver programs would be needed, but this demo proves the infrastructure works correctly.
