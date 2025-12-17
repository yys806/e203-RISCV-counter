/*
 ============================================================================
 Name        : main.c
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Hello RISC-V World in C
 ============================================================================
 */

#include <stdint.h>
#include <stdio.h>
#include <platform.h>
#include "init.h"

#define STRBUF_SIZE			256	// String buffer size

extern uint64_t get_timer_value(void);
extern unsigned long get_timer_freq(void);

static void delay_ms(uint32_t ms)
{
	uint64_t start = get_timer_value();
	uint64_t ticks = (get_timer_freq() * (uint64_t)ms) / 1000;

	while ((get_timer_value() - start) < ticks) {
	}
}

static uint32_t bcd_encode_4digits(uint32_t value)
{
	value %= 10000;
	return ((value / 1000) << 12)
		| (((value / 100) % 10) << 8)
		| (((value / 10) % 10) << 4)
		| (value % 10);
}

int main(void)
{
	_init();

	MY_PERIPH_REG(MY_PERIPH_REG_CTRL) = 0x0;
	MY_PERIPH_REG(MY_PERIPH_REG_IO) = 0x0000;

	uint32_t value = 0;
	while(1)
	{
		uint32_t bcd = bcd_encode_4digits(value);
		MY_PERIPH_REG(MY_PERIPH_REG_IO) = bcd;
		printf("set display = %04u (bcd=0x%04x)\n", value % 10000, bcd);
		value++;
		delay_ms(1000);
	}
	return 0;
}
