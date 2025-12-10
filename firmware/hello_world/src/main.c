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
#include <unistd.h>
#include <stdio.h>
#include <platform.h>
#include "init.h"

#define STRBUF_SIZE			256	// String buffer size


int main(void)
{
    uint32_t i = 0;
    _init();

    // Enable display with a moderate scan divider (matches RTL reset default)
    MY_PERIPH_REG(MY_PERIPH_REG_CTRL) = MY_PERIPH_CTRL_EN | 0x0400;

    while (1)
    {
        uint16_t val = i % 10000;
        uint8_t d0 = val % 10;
        uint8_t d1 = (val / 10) % 10;
        uint8_t d2 = (val / 100) % 10;
        uint8_t d3 = (val / 1000) % 10;

        uint32_t packed =
            MY_PERIPH_DATA_DIGIT0(d0) |
            MY_PERIPH_DATA_DIGIT1(d1) |
            MY_PERIPH_DATA_DIGIT2(d2) |
            MY_PERIPH_DATA_DIGIT3(d3) |
            MY_PERIPH_DATA_DP_BITS(0); // no decimal points

        MY_PERIPH_REG(MY_PERIPH_REG_DATA) = packed;
        printf("7seg display = %04u\r\n", val);

        i = (i + 1) % 10000;
    }
    return 0;
}
