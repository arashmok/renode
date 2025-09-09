// Memory addresses for exploration
#define SRAM_BASE    0x20000000
#define SRAM_SIZE    0x00010000

// Type definitions
typedef unsigned int uint32_t;

// Simple variables in different memory locations
volatile uint32_t global_var = 0x12345678;
volatile uint32_t test_array[16];

void memory_exploration() {
    // Direct memory manipulation using pointers
    volatile uint32_t *sram_ptr = (volatile uint32_t *)SRAM_BASE;
    
    // Write some test patterns to memory
    *sram_ptr = 0xDEADBEEF;
    *(sram_ptr + 1) = 0xCAFEBABE;
    *(sram_ptr + 2) = 0xFEEDFACE;
    
    // Fill test array with pattern
    for (int i = 0; i < 16; i++) {
        test_array[i] = 0x1000 + i;
    }
    
    // Infinite loop to keep the program running for debugging
    while (1) {
        global_var++;
        
        // Some register manipulation that can be observed
        volatile uint32_t temp = global_var;
        temp = temp * 2;
        test_array[0] = temp;
        
        // Add a small delay loop
        for (volatile int delay = 0; delay < 1000; delay++);
    }
}

int main() {
    memory_exploration();
    // Never return - infinite loop
    while(1);
}
