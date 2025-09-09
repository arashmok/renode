# Memory Exploration Project - GDB Debugging Guide

## Quick Start

1. **Start Renode with debug setup:**
   ```bash
   cd /home/octets/renode/memory_exploration
   /home/octets/renode_portable/renode --console --disable-xwt -e "include @debug_session.resc"
   ```

2. **Connect with GDB (in another terminal):**
   ```bash
   cd /home/octets/renode/memory_exploration
   gdb memory_test.elf
   (gdb) set architecture arm
   (gdb) target remote :2345
   ```

## Debugging Commands

Once connected, you can use these GDB commands:

```gdb
# View all registers
info registers

# Examine memory at different locations
x/4xw 0x20000000          # View direct memory writes (DEADBEEF, etc.)
x/16xw &global_var        # View global variable memory
x/16xw &test_array        # View test array memory

# Print variables
print global_var          # Should show incrementing value
print test_array[0]       # Should show calculated value (global_var * 2)

# Set breakpoints and watchpoints
break main                # Break at main function
break memory_exploration  # Break at memory exploration function
watch global_var          # Watch for changes to global_var

# Control execution
continue                  # Continue running
step                      # Step one line
next                      # Step over function calls
pause                     # Pause execution
```

## Memory Layout

The program uses this memory layout:
- **0x20000000**: Direct memory writes (DEADBEEF, CAFEBABE, FEEDFACE)
- **0x20000400**: Global variable (`global_var`)
- **0x20000404**: Test array (`test_array[16]`)

## Expected Behavior

- `global_var` continuously increments in an infinite loop
- `test_array[0]` contains `global_var * 2`
- Memory at 0x20000000 contains the test patterns written at startup

## Troubleshooting

If you get "Connection refused" error:
1. Make sure Renode is running with the debug script
2. Check that port 2345 is open: `netstat -tuln | grep 2345`
3. Try restarting Renode if needed
