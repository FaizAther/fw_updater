#include "libopencm3/stm32/f4/rcc.h"
#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>

/* NUCLEO-F401RE: user LED LD2 (green) on PA5. */
#define LED_PORT GPIOA
#define LED_PIN  GPIO5


static void rcc_setup(void) {
	// 84MHz clock from HSI (8MHz crystal)
	rcc_clock_setup_pll(&rcc_hsi_configs[RCC_CLOCK_3V3_84MHZ]);
	rcc_periph_clock_enable(RCC_GPIOA);
}

static void led_setup(void) {
	gpio_mode_setup(LED_PORT, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, LED_PIN);
}

static void delay(volatile uint32_t count)
{
	/*
	 * Cortex-M4 (Thumb): nop=1, subs=1, bne=1 → 3 cycles per iteration.
	 * Total delay ≈ 3 * count CPU cycles (+ a few cycles for call/return).
	 */
	__asm__ volatile(
		"loop:\n\t"
		"nop\n\t"
		"subs %0, %0, #1\n\t" // count = count - 1
		"bne loop\n\t" // if count != 0, goto loop
		: "+r"(count) // %0 = count, + read/write, r = register
		: // no input
		: "cc"); // clobber list
	// delay = clock cycles / 84MHz
	// delay = 3 * count / 84MHz
	// delay = 3 * count / 84000000 seconds
	// e.g 3 * 28000000 / 84000000 ~= 1 second
}

int main(void)
{
	rcc_setup();
	led_setup();

	while (1) {
		gpio_toggle(LED_PORT, LED_PIN);
		delay(28000000);
	}
}
