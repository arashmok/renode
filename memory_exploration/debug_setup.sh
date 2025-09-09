#!/bin/bash

# Memory Exploration Debug Setup Script
# This script sets up Renode for GDB debugging of the memory exploration project

echo "Starting Renode debug session for memory exploration..."

# Start Renode in background with the memory exploration setup
/home/octets/renode_portable/renode --console --disable-xwt << 'EOF'
# Clear any existing machines
mach clear

# Create machine for memory exploration
mach create "memory_explorer"

# Load platform description
machine LoadPlatformDescription @simple_m33.repl

# Load the ELF file
sysbus LoadELF @memory_test.elf

# Start GDB server on port 3333
machine StartGdbServer 3333

# Display setup information
echo "========================================"
echo "Memory Exploration Debug Setup Complete"
echo "========================================"
echo "Platform: ARM Cortex-M33 with 64KB SRAM"
echo "Program: memory_test.elf loaded"
echo "GDB Server: Started on port 3333"
echo ""
echo "To connect with GDB, run in another terminal:"
echo "  cd /home/octets/renode/memory_exploration"
echo "  gdb memory_test.elf"
echo "  (gdb) set architecture arm"
echo "  (gdb) target remote :3333"
echo "  (gdb) continue"
echo "========================================"

# Start the simulation
start

# Keep Renode running
EOF
