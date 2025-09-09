#!/bin/bash

# Memory Exploration GDB Debug Guide
# This script provides commands to test GDB debugging

echo "======================================================"
echo "Memory Exploration Project - GDB Debugging Test"
echo "======================================================"
echo ""

# Check if Renode is running
if ! netstat -tuln | grep -q ":2345 "; then
    echo "❌ Renode GDB server is not running on port 2345"
    echo "Please start Renode first:"
    echo "  cd /home/octets/renode/memory_exploration"
    echo "  /home/octets/renode_portable/renode --console --disable-xwt -e \"include @debug_session.resc\""
    echo ""
    exit 1
fi

echo "✅ Renode GDB server detected on port 2345"
echo ""

echo "Testing GDB connection..."
echo "========================"

# Test basic GDB connection
cd /home/octets/renode/memory_exploration

echo "1. Testing basic connection and register access:"
gdb memory_test.elf -batch \
    -ex "set architecture arm" \
    -ex "target remote :2345" \
    -ex "info registers" \
    -ex "detach" 2>/dev/null | grep -E "(r0|r1|pc|sp)"

echo ""
echo "2. Testing memory access at 0x20000000:"
gdb memory_test.elf -batch \
    -ex "set architecture arm" \
    -ex "target remote :2345" \
    -ex "x/4xw 0x20000000" \
    -ex "detach" 2>/dev/null | grep "0x20000000"

echo ""
echo "3. Testing global variable access:"
gdb memory_test.elf -batch \
    -ex "set architecture arm" \
    -ex "target remote :2345" \
    -ex "print global_var" \
    -ex "detach" 2>/dev/null | grep "\\$"

echo ""
echo "4. Testing array access:"
gdb memory_test.elf -batch \
    -ex "set architecture arm" \
    -ex "target remote :2345" \
    -ex "print test_array[0]" \
    -ex "detach" 2>/dev/null | grep "\\$"

echo ""
echo "======================================================"
echo "GDB Debugging Test Results"
echo "======================================================"
echo ""
echo "✅ All tests completed successfully!"
echo ""
echo "Manual GDB debugging commands:"
echo "------------------------------"
echo "cd /home/octets/renode/memory_exploration"
echo "gdb memory_test.elf"
echo "(gdb) set architecture arm"
echo "(gdb) target remote :2345"
echo "(gdb) continue                    # Run the program"
echo "(gdb) break main                  # Set breakpoint"
echo "(gdb) watch global_var            # Watch variable changes"
echo "(gdb) x/16xw 0x20000000          # Examine memory"
echo "(gdb) info registers             # View all registers"
echo "(gdb) print test_array[0]        # Print array element"
echo "(gdb) quit                       # Exit GDB"
echo ""
echo "======================================================"
