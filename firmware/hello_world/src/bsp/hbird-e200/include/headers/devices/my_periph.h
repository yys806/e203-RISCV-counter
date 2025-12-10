/**
 * @file my_periph.h
 * @author your name (you@domain.com)
 * @brief 
 * @version 0.1
 * @date 2024-01-17
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#ifndef _MY_PERIPH__H
#define _MY_PERIPH__H


#define MY_PERIPH_REG_CTRL   0x00  // bit0: enable, bits[15:0]: scan divider
#define MY_PERIPH_REG_DATA   0x04  // packed digits and dp bits

#define MY_PERIPH_CTRL_EN        (1u << 0)
#define MY_PERIPH_CTRL_DIV_MASK  0xFFFFu

#define MY_PERIPH_DATA_DIGIT0(x)   ((uint32_t)((x) & 0xFu) << 0)
#define MY_PERIPH_DATA_DIGIT1(x)   ((uint32_t)((x) & 0xFu) << 4)
#define MY_PERIPH_DATA_DIGIT2(x)   ((uint32_t)((x) & 0xFu) << 8)
#define MY_PERIPH_DATA_DIGIT3(x)   ((uint32_t)((x) & 0xFu) << 12)
#define MY_PERIPH_DATA_DP_BITS(x)  ((uint32_t)((x) & 0xFu) << 16)
#endif  //_MY_PERIPH__H
