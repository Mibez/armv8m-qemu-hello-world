#include <stdint.h>

/* MPS-AN505 Memory mapped APB UART controller registers, see
 * https://developer.arm.com/documentation/ddi0479/d/apb-components/apb-uart/programmers-model
 */
static volatile uint32_t * const UART0_DATA_REG =   (uint32_t*)0x40200000;
static volatile uint32_t * const UART0_CTRL_REG =   (uint32_t*)0x40200008;

/* CTRL register control bits */
#define APB_UART_TX_EN      (1 << 0)
#define APB_UART_RX_EN      (1 << 1)
#define MPS_UART_ENABLE     (APB_UART_TX_EN)


/* STM32U545XX UART registers, see 
 * https://www.st.com/resource/en/reference_manual/rm0456-stm32u5-series-armbased-32bit-mcus-stmicroelectronics.pdf
 */
static volatile uint32_t * const UART0_CR1_REG =   (uint32_t*)0x40013800;
static volatile uint32_t * const UART0_TDR_REG =   (uint32_t*)0x40013828;

/* CTRL register control bits */
#define USART_CR1_UE    (uint32_t)(1 << 0)
#define USART_CR1_TE    (uint32_t)(1 << 3)
#define STM_UART_ENABLE (USART_CR1_TE | USART_CR1_UE)

#ifdef STM32U545XX
#define HAS_BOARD
static volatile uint32_t * const UART_DATA_REGISTER = UART0_TDR_REG;
static volatile uint32_t * const UART_CONTROL_REGISTER = UART0_CR1_REG;
#define UART_ENABLE STM_UART_ENABLE
#endif

#ifdef MPS2AN505
#define HAS_BOARD
static volatile uint32_t * const UART_DATA_REGISTER = UART0_DATA_REG;
static volatile uint32_t * const UART_CONTROL_REGISTER = UART0_CTRL_REG;
#define UART_ENABLE MPS_UART_ENABLE

#endif

#ifndef HAS_BOARD
#error "Please select either mps2-an505, stm32u545board as BOARD"
#endif



/**
 * @brief Setup UART0 for TX only
 */
void uart0_setup(void)
{
    *UART_CONTROL_REGISTER = UART_ENABLE;
}

/**
 * @brief Transmit a null-terminated string over UART0
 */
void uart0_print(const char *s)
{
    while(*s != '\0') {
        *UART_DATA_REGISTER = (unsigned int)(*s++);
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
    char * buffer = "Hello World!\n";

    uart0_setup();
    uart0_print(buffer);

    qemu_clean_exit();
}