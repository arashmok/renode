#!/bin/bash

# Verification script for memory exploration debugging setup
# This script verifies that all tools and files are working correctly

echo "=== Memory Exploration Setup Verification ==="
echo

# Check required files
echo "1. Checking required files..."
required_files=("memory_test.elf" "simple_m33.repl" "debug_session.resc" "LEARNING_MATERIAL.md")

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file found"
    else
        echo "  ✗ $file missing"
        exit 1
    fi
done

echo

# Check available tools
echo "2. Checking debugging tools..."

if command -v gdb > /dev/null; then
    echo "  ✓ gdb available: $(gdb --version | head -1)"
else
    echo "  ✗ gdb not found"
    exit 1
fi

if command -v objdump > /dev/null; then
    echo "  ✓ objdump available"
else
    echo "  ✗ objdump not found"
fi

if command -v size > /dev/null; then
    echo "  ✓ size available"
else
    echo "  ✗ size not found"
fi

echo

# Check Renode
echo "3. Checking Renode..."
if [ -f "/home/octets/renode_portable/renode" ]; then
    echo "  ✓ Renode found at /home/octets/renode_portable/renode"
else
    echo "  ✗ Renode not found at expected location"
    exit 1
fi

echo

# Check ELF file architecture
echo "4. Verifying ARM ELF file..."
file_output=$(file memory_test.elf)
if echo "$file_output" | grep -q "ARM"; then
    echo "  ✓ memory_test.elf is ARM architecture"
    echo "    $file_output"
else
    echo "  ✗ memory_test.elf is not ARM architecture"
    echo "    $file_output"
fi

echo

# Test GDB ARM support
echo "5. Testing GDB ARM support..."
gdb_test=$(echo -e "set architecture arm\nshow architecture\nquit" | gdb -q 2>&1)
if echo "$gdb_test" | grep -q "arm"; then
    echo "  ✓ GDB supports ARM architecture"
else
    echo "  ✗ GDB ARM support test failed"
    echo "$gdb_test"
fi

echo

# Summary
echo "=== Setup Instructions ==="
echo
echo "To start debugging:"
echo "1. Start Renode:     /home/octets/renode_portable/renode --console --disable-xwt"
echo "2. Load debug script: include @debug_session.resc"
echo "3. In another terminal, start GDB:"
echo "   gdb memory_test.elf"
echo "   (gdb) set architecture arm"
echo "   (gdb) target remote :2345"
echo
echo "=== Verification Complete ==="
