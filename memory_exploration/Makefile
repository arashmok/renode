# Makefile for minimal Cortex-M33 memory exploration project

TARGET = memory_test
SOURCES = memory_test.c startup.S

# Toolchain
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
AS = $(PREFIX)as
LD = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
OBJDUMP = $(PREFIX)objdump

# Compiler flags
CFLAGS = -mcpu=cortex-m33 -mthumb -g -O0 -Wall -nostdlib -ffreestanding
ASFLAGS = -mcpu=cortex-m33 -mthumb -g
LDFLAGS = -T linker.ld -nostdlib

# Build targets
all: $(TARGET).elf $(TARGET).bin $(TARGET).dump

$(TARGET).o: memory_test.c
	$(CC) $(CFLAGS) -c $< -o $@

startup.o: startup.S
	$(CC) $(ASFLAGS) -c $< -o $@

$(TARGET).elf: $(TARGET).o startup.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).dump: $(TARGET).elf
	$(OBJDUMP) -D $< > $@

clean:
	rm -f *.o *.elf *.bin *.dump

.PHONY: all clean
