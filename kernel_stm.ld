/* Linker script to configure memory regions. */
MEMORY
{
   NS_CODE (rx)     : ORIGIN = 0x08000000, LENGTH = 512K
   S_CODE_BOOT (rx) : ORIGIN = 0x0C000000, LENGTH = 512k
   RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 274k
}

/* Entry Point */
ENTRY(Reset_Handler)


SECTIONS
{

    .text : 
    {
        KEEP(*(.isr_vector))
        *(.text)
    	*(.rodata) 
    } > NS_CODE

    .bss :
    {
        *(.bss)
        *(COMMON)
    } > RAM

    .data :
    {
        *(.data)
    } > RAM
    /* Set stack top to end of RAM. */
    __StackTop = ORIGIN(RAM) + LENGTH(RAM);
    

}


