#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>

/* NUCLEO-F401RE: user LED LD2 (green) on PA5. */
#define LED_PORT GPIOA
#define LED_PIN  GPIO5

static void delay(volatile uint32_t count)
{
	while (count--) {
		__asm__("nop");
	}
}

int main(void)
{
	rcc_periph_clock_enable(RCC_GPIOA);
	gpio_mode_setup(LED_PORT, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, LED_PIN);

	while (1) {
		gpio_toggle(LED_PORT, LED_PIN);
		delay(1000000);
	}
}
