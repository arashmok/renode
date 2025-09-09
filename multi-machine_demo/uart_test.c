// Simple UART test for Renode multi-machine communication demo
// This bare-metal C program demonstrates embedded systems fundamentals:
// - Memory-mapped I/O for UART communication
// - Direct hardware register manipulation
// - Minimal runtime environment without standard library

// Type definitions for exact-width integers
// These ensure consistent behavior across different architectures
typedef unsigned int uint32_t;   // 32-bit unsigned integer for addresses and large values
typedef unsigned char uint8_t;   // 8-bit unsigned integer for register values and characters

// UART Memory-Mapped I/O Base Addresses
// These addresses correspond to the peripheral memory regions defined in simple_platform.repl
// Memory-mapped I/O allows us to control hardware by reading/writing to specific memory addresses
#define UART0_BASE 0x10013000  // Console UART for debug output and system messages
#define UART1_BASE 0x10023000  // Communication UART for inter-machine messaging via hub

// UART Register Offsets (from NS16550 UART specification)
// These offsets are added to the base address to access specific UART control registers
#define UART_THR   0x00  // Transmit Holding Register - where we write data to send
#define UART_LSR   0x14  // Line Status Register - shows UART transmission status

// UART Line Status Register Bit Definitions
// Individual bits in the LSR register indicate different UART states
#define UART_LSR_THRE 0x20  // Transmit Holding Register Empty - bit 5, indicates TX ready  

// Function: uart_putc - Send a single character via UART
// This function demonstrates the fundamental embedded systems concept of polling I/O
// Parameters:
//   base: UART base address (UART0_BASE or UART1_BASE)
//   c: Character to transmit
static void uart_putc(uint32_t base, char c) {
    // Create volatile pointers to UART registers
    // 'volatile' keyword prevents compiler optimization - essential for memory-mapped I/O
    // The compiler must read the actual hardware register every time, not cache the value
    volatile uint8_t *lsr = (uint8_t*)(base + UART_LSR);  // Line Status Register pointer
    volatile uint8_t *thr = (uint8_t*)(base + UART_THR);  // Transmit Holding Register pointer
    
    // Polling loop: Wait until transmit holding register is empty
    // This implements busy-waiting - CPU repeatedly checks hardware status
    // Alternative approach would be interrupt-driven I/O (more complex but more efficient)
    while (!(*lsr & UART_LSR_THRE));  // Loop while THRE bit is 0 (transmitter busy)
    
    // Write character to transmit holding register
    // This triggers the UART hardware to begin serial transmission
    // Hardware will shift out bits according to configured baud rate, data format
    *thr = c;
}

// Function: uart_puts - Send a null-terminated string via UART
// This function builds on uart_putc to provide string transmission capability
// Demonstrates string processing in embedded systems without standard library
// Parameters:
//   base: UART base address (UART0_BASE or UART1_BASE)
//   s: Pointer to null-terminated string to transmit
static void uart_puts(uint32_t base, const char *s) {
    // Iterate through string until null terminator
    // This is a manual implementation of string traversal (no strlen() available)
    while (*s) {
        // Handle newline character for proper terminal display
        // Convert Unix LF (\n) to Windows CRLF (\r\n) for terminal compatibility
        // Many terminal emulators expect carriage return before line feed
        if (*s == '\n') uart_putc(base, '\r');  // Send carriage return first
        
        // Send the current character and advance string pointer
        // Post-increment operator: use current value of s, then increment pointer
        uart_putc(base, *s++);
    }
}

// Function: _start - Entry point for bare-metal program
// This replaces the typical main() function used in hosted environments
// The linker looks for _start as the program entry point in embedded systems
// No operating system or C runtime library is present to call main()
void _start(void) {
    // Initialize stack pointer to a safe memory location
    // Stack grows downward from high memory addresses in RISC-V
    // 0x80100000 = 256MB RAM base (0x80000000) + 1MB offset
    // This provides 1MB for program code/data, rest for stack/heap
    // Inline assembly ensures direct control over stack pointer register
    __asm__ volatile("li sp, 0x80100000");
    
    // Send startup message to console UART (UART0)
    // This demonstrates local system status reporting
    // UART0 is typically used for debug output and system console
    uart_puts(UART0_BASE, "Machine starting...\n");
    
    // Send greeting message to communication UART (UART1)
    // This demonstrates inter-machine communication capability
    // UART1 is connected to the UART hub for multi-machine messaging
    // Other machines connected to the hub will receive this message
    uart_puts(UART1_BASE, "Hello from machine!\n");
    
    // Main program loop: Enter low-power wait state
    // WFI (Wait For Interrupt) instruction puts CPU in sleep mode
    // CPU will wake up when an interrupt occurs, then immediately sleep again
    // This demonstrates power-efficient embedded programming
    // In a real application, interrupt handlers would process events
    while(1) {
        __asm__ volatile("wfi");  // Wait for interrupt - low power mode
    }
    
    // Note: This function never returns because:
    // 1. No operating system to return to
    // 2. Embedded systems typically run forever
    // 3. Power-down or reset are the only ways to stop execution
}
