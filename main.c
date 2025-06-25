#include <stdint.h>

/* Memory mapped APB UART controller registers, see
 * https://developer.arm.com/documentation/ddi0479/d/apb-components/apb-uart/programmers-model
 */
static volatile uint32_t * const UART0_DATA_REG =   (uint32_t*)0x40200000;
static volatile uint32_t * const UART0_STATE_REG =  (uint32_t*)0x40200004;
static volatile uint32_t * const UART0_CTRL_REG =   (uint32_t*)0x40200008;

/* CTRL register control bits */
#define APB_UART_TX_EN      (1 << 0)
#define APB_UART_RX_EN      (1 << 1)

/**
 * @brief Setup UART0 for TX only
 */
void uart0_setup(void)
{
    *UART0_CTRL_REG = (unsigned int)0x1;
}

/**
 * @brief Transmit a null-terminated string over UART0
 */
void uart0_print(const char *s)
{
    while(*s != '\0') {
        *UART0_DATA_REG = (unsigned int)(*s++);
    }
}

/** 
 * @brief Gently exit the QEMU through a semihosting call
*/
void qemu_clean_exit(void)
{
    register int reg0 asm("r0");
    register int reg1 asm("r1");

    reg0 = 0x18;        // angel_SWIreason_ReportException
    reg1 = 0x20026;     // ADP_Stopped_ApplicationExit

    asm("bkpt #0xAB");  // make semihosting call
}

/**
 * @brief Entrypoint
 */
void main()
{
    char *buffer = "Hello World!\n";

    uart0_setup();
    uart0_print(buffer);

    qemu_clean_exit();
}