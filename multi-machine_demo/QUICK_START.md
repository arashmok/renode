# Renode Multi-Machine Demo - Quick Start Guide

## 🚀 Fastest Way to See It Working

### Step 1: Start Renode
```bash
cd /home/octets/renode_demo
/home/octets/renode_portable/renode --disable-xwt
```

### Step 2: Run the Communication Demo
```
(monitor) i @demo_communication.resc
(machine2) start
```

### Step 3: Watch the Output
You'll see two analyzer windows showing:
- **Machine1** sending: "MSG0 from Machine1", "MSG1 from Machine1", "MSG2 from Machine1"
- **Machine2** receiving each character and acknowledging

---

## 📊 What You Should See

### Console Output Flow
```
===================================
Multi-Machine Communication Demo
===================================
Machine1 will send messages via UART1
Machine2 will receive and acknowledge

Type 'start' to begin the demo
===================================

Starting emulation...
[INFO] machine1: Machine started.
[INFO] machine2: Machine started.
```

### Machine1_Console Analyzer
```
[Machine1] Starting...
[Machine1] Sending message 0
[Machine1] Sending message 1
[Machine1] Sending message 2
[Machine1] Done sending
```

### Machine2_Console Analyzer
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
[Machine2] Received: (space)
[Machine2] Received: M
[Machine2] Received: a
[Machine2] Received: c
[Machine2] Received: h
[Machine2] Received: i
[Machine2] Received: n
[Machine2] Received: e
[Machine2] Received: 1
[Machine2] Received: (newline)
```

---

## 🔧 Essential Commands

### In Renode Monitor
| Command | Purpose |
|---------|---------|
| `i @script.resc` | Load and execute a script |
| `start` | Begin emulation |
| `pause` | Pause emulation |
| `mach` | List all machines |
| `mach set "machine1"` | Switch to machine1 |
| `peripherals` | Show all peripherals |
| `quit` | Exit Renode |

### Debugging Commands
| Command | Purpose |
|---------|---------|
| `cpu PC` | Show program counter |
| `cpu Step 10` | Execute 10 instructions |
| `cpu Registers` | Display all CPU registers |
| `sysbus ReadByte 0x10013014` | Read UART status |
| `logLevel 0` | Reduce console noise |

---

## 🎯 Key Memory Addresses

| Component | Address | Purpose |
|-----------|---------|---------|
| DDR RAM Start | 0x80000000 | Program execution |
| Flash Start | 0x20000000 | Non-volatile storage |
| UART0 Base | 0x10013000 | Console output |
| UART1 Base | 0x10023000 | Inter-machine comm |
| GPIO Base | 0x10012000 | Digital I/O |
| CLINT Base | 0x02000000 | Timer interrupts |
| PLIC Base | 0x0C000000 | External interrupts |

---

## 📝 Communication Architecture

```
┌─────────────────────────────────────────────────┐
│                  UART HUB                        │
│  Bidirectional message passing between machines  │
└────────────┬───────────────────┬─────────────────┘
             │                   │
    ┌────────▼────────┐ ┌────────▼────────┐
    │   Machine 1     │ │   Machine 2     │
    ├─────────────────┤ ├─────────────────┤
    │ CPU: RISC-V 32  │ │ CPU: RISC-V 32  │
    │ RAM: 256MB      │ │ RAM: 256MB      │
    │ UART0: Console  │ │ UART0: Console  │
    │ UART1: To Hub   │ │ UART1: To Hub   │
    │ GPIO: 32 pins   │ │ GPIO: 32 pins   │
    └─────────────────┘ └─────────────────┘
           │                     │
           └──── GPIO Link ──────┘
         (Pin-to-pin connections)
```

---

## ⚡ Quick Tests

### Test 1: Simple Output
```
(monitor) mach create
(monitor) machine LoadPlatformDescription @simple_platform.repl
(monitor) sysbus LoadELF @test.elf
(monitor) showAnalyzer sysbus.uart0
(monitor) start
```
**Result**: See "Hi" in the analyzer

### Test 2: Check Platform
```
(monitor) i @setup_platform.resc
(monitor) peripherals
```
**Result**: List of all peripherals with addresses

### Test 3: Inter-Machine Message
```
(monitor) i @demo_communication.resc
(monitor) start
(monitor) sleep 1
(monitor) pause
```
**Result**: Messages exchanged between machines

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| No output | Check if analyzers are open: `showAnalyzer sysbus.uart0` |
| CPU abort | Load a program: `sysbus LoadELF @machine1.elf` |
| No communication | Verify UART hub: `emulation CreateUARTHub "uart_hub"` |
| Too many warnings | Reduce logging: `logLevel 0` |

---

## 📚 Files in This Demo

- **simple_platform.repl** - Hardware definition
- **demo_communication.resc** - Full demo script
- **machine1.elf** - Sender program
- **machine2.elf** - Receiver program
- **README.md** - Detailed documentation
