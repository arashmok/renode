# Renode Multi-Machine Platform Demo

This directory contains a complete Renode platform setup demonstrating inter-machine communication with RISC-V processors.

## Files

### Platform Description
- `simple_platform.repl` - RISC-V platform with CPU, memory, UARTs, GPIO, and interrupt controllers

### Renode Scripts
- `setup_platform.resc` - Basic multi-machine setup with communication links
- `test_with_program.resc` - Script that loads test program
- `demo_communication.resc` - Full demo with two communicating machines

### Firmware
- `machine1.c/elf` - Sender firmware that transmits messages via UART
- `machine2.c/elf` - Receiver firmware that acknowledges messages
- `test.elf` - Simple "Hi" test program
- `uart_test.elf` - Basic UART communication test

## Platform Features

### Hardware Components
- **CPU**: RISC-V 32-bit (rv32imac)
- **Memory**: 256MB DDR @ 0x80000000, 16MB Flash @ 0x20000000
- **UART0**: Console output @ 0x10013000
- **UART1**: Inter-machine communication @ 0x10023000
- **GPIO**: 32 pins @ 0x10012000
- **Interrupts**: CLINT (timer/software) and PLIC (external)

### Communication Methods
1. **UART Hub** - Serial communication between machines
2. **GPIO Connectors** - Direct pin-to-pin connections
3. **Network** - Ethernet connectivity (can be added)
4. **CAN Bus** - Industrial communication (can be added)

## Running the Demos

### Demo 1: Simple Test Program
This demonstrates basic UART output from a single machine.

```bash
cd /home/octets/renode_demo
/home/octets/renode_portable/renode --disable-xwt
```

In Renode console:
```
(monitor) i @test_with_program.resc
(machine2) mach set "machine1"
(machine1) start
```

**Expected Output:**
```
11:55:51.8629 [INFO] machine1/uart0: [host: 0.56s (+0.56s)|virt: 0s (+0s)] Hi
```

Note: You may also see a CPU abort error from machine2 since it doesn't have a program loaded. This is expected and can be ignored for this simple test.

The test program prints "Hi" to UART0 (console) and then enters a wait-for-interrupt loop.

### Demo 2: Basic Platform Setup
This creates two machines with interconnected UARTs and GPIOs.

```bash
cd /home/octets/renode_demo
/home/octets/renode_portable/renode --disable-xwt
```

In Renode console:
```
(monitor) i @setup_platform.resc
(machine2) peripherals
```

**Expected Output:**
```
Machine1 peripherals:
Available peripherals:
  sysbus (SystemBus)
  ├── clint (CoreLevelInterruptor)
  │       <0x02000000, 0x0200FFFF>
  ├── cpu (RiscV32)
  │       Slot: 0
  ├── ddr (MappedMemory)
  │       <0x80000000, 0x8FFFFFFF>
  ├── flash (MappedMemory)
  │       <0x20000000, 0x20FFFFFF>
  ├── gpio (SiFive_GPIO)
  │       <0x10012000, 0x10012FFF>
  ├── plic (PlatformLevelInterruptController)
  │       <0x0C000000, 0x0FFFFFFF>
  ├── uart0 (NS16550)
  │       <0x10013000, 0x100130FF>
  └── uart1 (NS16550)
          <0x10023000, 0x100230FF>

Multi-machine platform setup complete!
```

### Demo 3: Inter-Machine Communication
This demonstrates two machines communicating via UART hub.

```bash
cd /home/octets/renode_demo
/home/octets/renode_portable/renode --disable-xwt
```

In Renode console:
```
(monitor) i @demo_communication.resc
(machine2) start
```

**Expected Output:**

Two analyzer windows will open:
- **Machine1_Console**: Shows sender activity
- **Machine2_Console**: Shows receiver activity

**Machine1_Console will display:**
```
[Machine1] Starting...
[Machine1] Sending message 0
[Machine1] Sending message 1
[Machine1] Sending message 2
[Machine1] Done sending
```

**Machine2_Console will display:**
```
[Machine2] Starting as receiver...
[Machine2] Received: M
[Machine2] Received: S
[Machine2] Received: G
[Machine2] Received: 0
[Machine2] Received: (space)
[Machine2] Received: f
[Machine2] Received: r
[Machine2] Received: o
[Machine2] Received: m
...
```

Machine2 receives each character from Machine1's UART1 transmission and echoes it to its console. When it receives a newline, it sends back "ACK\n" through the UART hub.

### Demo 4: Custom UART Test
This shows basic message transmission from one machine.

```bash
cd /home/octets/renode_demo
/home/octets/renode_portable/renode --disable-xwt
```

In Renode console:
```
(monitor) mach create
(monitor) machine LoadPlatformDescription @simple_platform.repl
(monitor) sysbus LoadELF @uart_test.elf
(monitor) showAnalyzer sysbus.uart0
(monitor) showAnalyzer sysbus.uart1
(monitor) start
```

**Expected Output:**
- **UART0 Analyzer**: "Machine starting..."
- **UART1 Analyzer**: "Hello from machine!"

## Understanding the Communication Flow

### UART Hub Connection
```
Machine1 UART1 ─┐
                ├─ UART Hub ─── Messages flow bidirectionally
Machine2 UART1 ─┘
```

### GPIO Connection
```
Machine1 GPIO[0] ──→ Machine2 GPIO[0]  (One-way)
Machine2 GPIO[1] ──→ Machine1 GPIO[1]  (One-way, reverse)
```

### Message Flow Example
1. Machine1 writes "MSG0 from Machine1\n" to UART1
2. UART Hub receives the message
3. UART Hub forwards to Machine2's UART1
4. Machine2 reads from UART1, displays on UART0
5. Machine2 sends "ACK\n" back through UART1
6. Machine1 could receive the ACK (if programmed to do so)

## Program Behavior Details

### Machine1 (Sender) Program Flow
```c
1. Initialize stack pointer
2. Print "[Machine1] Starting..." to console
3. Loop 3 times:
   a. Print sending status to console
   b. Send "MSGx from Machine1\n" to UART1
   c. Delay ~100,000 cycles
4. Print "[Machine1] Done sending" to console
5. Enter WFI (Wait For Interrupt) loop
```

### Machine2 (Receiver) Program Flow
```c
1. Initialize stack pointer
2. Print "[Machine2] Starting as receiver..." to console
3. Infinite loop:
   a. Check if UART1 has data (non-blocking)
   b. If data available:
      - Read character
      - Echo to console with "[Machine2] Received: "
      - If newline, send "ACK\n" back
   c. Small delay ~1,000 cycles
```

## Common Issues and Solutions

### Issue: Programs execute but no communication
**Solution**: Ensure UART hub is created and both machines are connected:
```
emulation CreateUARTHub "uart_hub"
mach set "machine1"
connector Connect sysbus.uart1 uart_hub
mach set "machine2"
connector Connect sysbus.uart1 uart_hub
```

### Issue: Memory access warnings
**Cause**: The delay loops in the C code may access stack addresses.
**Solution**: These are harmless for the demo. Use `logLevel 0` to suppress.

### Issue: Machine2 shows CPU abort
**Cause**: Machine2 doesn't have a program loaded in some scripts.
**Solution**: Load a program or use demo_communication.resc which loads both.

### Issue: GPIO warnings about pins not configured for writing
**Cause**: The GPIO connector tries to drive pins before firmware configures them.
**Solution**: These warnings are expected and harmless. Firmware should configure GPIO direction registers if actual GPIO functionality is needed.

## Building Custom Firmware

### Requirements
- RISC-V GCC toolchain (riscv64-linux-gnu-gcc)

### Compile Example
```bash
riscv64-linux-gnu-gcc -march=rv32imac -mabi=ilp32 \
    -nostdlib -nostartfiles -ffreestanding \
    -Ttext=0x80000000 your_code.c -o your_code.elf
```

### Minimal UART Code Template
```c
typedef unsigned int uint32_t;
typedef unsigned char uint8_t;

#define UART0_BASE 0x10013000
#define UART_THR   0x00  
#define UART_LSR   0x14  
#define UART_LSR_THRE 0x20  

static void uart_putc(uint32_t base, char c) {
    volatile uint8_t *lsr = (uint8_t*)(base + UART_LSR);
    volatile uint8_t *thr = (uint8_t*)(base + UART_THR);
    while (!(*lsr & UART_LSR_THRE));
    *thr = c;
}

void _start(void) {
    __asm__ volatile("li sp, 0x80100000");
    uart_putc(UART0_BASE, 'A');
    while(1) __asm__ volatile("wfi");
}
```

## Verification Results

✅ Platform loads successfully in Renode
✅ Two machines can be created and configured
✅ UART communication hub connects machines
✅ GPIO connectors can be established
✅ Test programs execute and output to console
✅ Inter-machine message passing works
✅ Character-by-character reception confirmed

## Next Steps

- Add interrupt-driven UART handling instead of polling
- Implement proper message framing and protocols
- Add DMA controllers for efficient data transfer
- Implement bidirectional communication with ACK handling
- Add network stack for TCP/IP communication
- Create more complex multi-node topologies

## Tips for Exploration

1. **Monitor Communication**: Use `sysbus.uart1 AddLineHook "UART1" WriteLineToConsole` to see all UART1 traffic
2. **Step Through Code**: Use `cpu Step 10` to execute 10 instructions at a time
3. **Check Registers**: Use `cpu PC` to see program counter, `cpu Registers` for all registers
4. **Set Breakpoints**: Use `cpu AddHook 0x80000100 "break"` to stop at specific addresses
5. **Time Analysis**: Check virtual vs host time in analyzer outputs
