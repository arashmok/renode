# ARM Cortex-M33 Educational Demo Makefile
# Builds a bare-metal program for ARM Cortex-M33 simulation in Renode

# Project Configuration
PROJECT_NAME = hello_world_m33
TARGET_CPU = cortex-m33
TARGET_ARCH = armv8-m.main

# Toolchain Configuration
CROSS_COMPILE = arm-none-eabi-
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
SIZE = $(CROSS_COMPILE)size

# Source Files
C_SOURCES = hello_world_m33.c
ASM_SOURCES = startup_m33.S
LINKER_SCRIPT = linker_m33.ld

# Output Files
ELF_FILE = $(PROJECT_NAME).elf
BIN_FILE = $(PROJECT_NAME).bin
DUMP_FILE = $(PROJECT_NAME).dump
MAP_FILE = $(PROJECT_NAME).map

# Compiler Flags
CFLAGS = -mcpu=$(TARGET_CPU) \
         -mthumb \
         -mfloat-abi=soft \
         -Wall \
         -Wextra \
         -Wstrict-prototypes \
         -Wmissing-prototypes \
         -Wold-style-definition \
         -Wno-unused-parameter \
         -fno-common \
         -ffunction-sections \
         -fdata-sections \
         -std=c99 \
         -Os \
         -g3 \
         -DCORTEX_M33

# Assembler Flags
ASFLAGS = -mcpu=$(TARGET_CPU) \
          -mthumb

# Linker Flags
LDFLAGS = -mcpu=$(TARGET_CPU) \
          -mthumb \
          -mfloat-abi=soft \
          -T $(LINKER_SCRIPT) \
          -Wl,--gc-sections \
          -Wl,--print-memory-usage \
          -Wl,-Map=$(MAP_FILE) \
          -nostartfiles \
          -specs=nosys.specs

# Object Files
C_OBJECTS = $(C_SOURCES:.c=.o)
ASM_OBJECTS = $(ASM_SOURCES:.S=.o)
OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

# Default Target
all: $(ELF_FILE) $(BIN_FILE) $(DUMP_FILE) size

# Build ELF file
$(ELF_FILE): $(OBJECTS) $(LINKER_SCRIPT)
	@echo "Linking $@..."
	$(LD) $(OBJECTS) $(LDFLAGS) -o $@

# Build binary file
$(BIN_FILE): $(ELF_FILE)
	@echo "Creating binary $@..."
	$(OBJCOPY) -O binary $< $@

# Create disassembly dump
$(DUMP_FILE): $(ELF_FILE)
	@echo "Creating disassembly $@..."
	$(OBJDUMP) -D -S $< > $@

# Compile C source files
%.o: %.c
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble assembly source files
%.o: %.S
	@echo "Assembling $<..."
	$(AS) $(ASFLAGS) -c $< -o $@

# Show memory usage
size: $(ELF_FILE)
	@echo ""
	@echo "Memory Usage:"
	@$(SIZE) $<

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(OBJECTS) $(ELF_FILE) $(BIN_FILE) $(DUMP_FILE) $(MAP_FILE)

# Run the simulation in Renode
run: all
	@echo "Starting Renode simulation..."
	renode --console platform_startup_m33.resc -e "start"

# Run Renode in interactive mode
debug: all
	@echo "Starting Renode in debug mode..."
	renode --console platform_startup_m33.resc

# Show build information
info:
	@echo "Project: $(PROJECT_NAME)"
	@echo "Target CPU: $(TARGET_CPU)"
	@echo "Target Architecture: $(TARGET_ARCH)"
	@echo "Toolchain: $(CROSS_COMPILE)"
	@echo "C Sources: $(C_SOURCES)"
	@echo "ASM Sources: $(ASM_SOURCES)"
	@echo "Linker Script: $(LINKER_SCRIPT)"

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Build all output files (default)"
	@echo "  clean   - Remove all build artifacts"
	@echo "  run     - Build and run in Renode"
	@echo "  debug   - Build and start Renode in interactive mode"
	@echo "  size    - Show memory usage of built ELF file"
	@echo "  info    - Display build configuration"
	@echo "  help    - Show this help message"

# Declare phony targets
.PHONY: all clean run debug size info help

# Dependencies
$(C_OBJECTS): $(C_SOURCES)
$(ASM_OBJECTS): $(ASM_SOURCES)
