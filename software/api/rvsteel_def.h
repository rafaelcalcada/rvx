// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __RVSTEEL_DEF__
#define __RVSTEEL_DEF__

#include "rvsteel_gcc.h"

#define __NOP() __ASM_VOLATILE("nop")

#define __ECALL() __ASM_VOLATILE("ecall")

#define __EBREAK() __ASM_VOLATILE("ebreak")

#define SET_FLAG(REG, FLAG) ((REG) |= (FLAG))

#define CLR_FLAG(REG, FLAG) ((REG) &= ~(FLAG))

#define INVERT_FLAG(REG, FLAG) ((REG) ^= (FLAG))

#define SET_BIT(REG, BIT) ((REG) |= (1 << (BIT)))

#define CLR_BIT(REG, BIT) ((REG) &= ~(1 << (BIT)))

#define INVERT_BIT(REG, BIT) ((REG) ^= (1 << (BIT)))

#define READ_BIT(REG, BIT) (((REG) >> BIT) & 1)

#define MODIFY_REG(REG, CLEARMASK, SETMASK) ((REG) = (REG & (~(CLEARMASK))) | (SETMASK))

#define NUMBER_OF(a) (sizeof a / sizeof a[0])

#endif // __RVSTEEL_DEF__
