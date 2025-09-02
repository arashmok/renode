#!/bin/bash

# ARM Cortex-M33 Custom Board Demo Runner Script
# Builds and runs the educational custom ARM Cortex-M33 board in Renode

echo "========================================"
echo "ARM Cortex-M33 Custom Board Demo"
echo "========================================"
echo ""

# Check if required tools are available
if ! command -v arm-none-eabi-gcc &> /dev/null; then
    echo "Error: ARM toolchain (arm-none-eabi-gcc) not found!"
    echo "Please install the ARM embedded toolchain:"
    echo "  Ubuntu/Debian: sudo apt-get install gcc-arm-none-eabi"
    echo "  Fedora: sudo dnf install arm-none-eabi-gcc-cs arm-none-eabi-binutils-cs"
    exit 1
fi

if ! command -v renode &> /dev/null; then
    echo "Error: Renode not found!"
    echo "Please install Renode from: https://renode.io/"
    exit 1
fi

echo "Building ARM Cortex-M33 demo..."
make clean && make

if [ $? -ne 0 ]; then
    echo "Build failed! Please check the error messages above."
    exit 1
fi

echo ""
echo "Build successful! Starting Renode simulation..."
echo "The demo will show UART output with a counting demonstration."
echo "Press Ctrl+C to stop the simulation."
echo ""

# Run the demo in Renode
renode --console platform_startup_m33.resc -e "start"
