# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2025 RVX Project Contributors

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge


CLK_PERIOD_NS   = 100

REG_CR          = 0*4
REG_MTIMEL      = 1*4
REG_MTIMEH      = 2*4
REG_MTIMECMPL   = 3*4
REG_MTIMECMPH   = 4*4


def setup_dut(dut):
    cocotb.start_soon(Clock(dut.clock, CLK_PERIOD_NS, units='ns').start())


async def reset_dut(dut):
    dut.reset.value = 1
    await ClockCycles(dut.clock, 10)
    dut.reset.value = 0
    await ClockCycles(dut.clock, 10)


async def write_request(dut, add, value, strobe=0xf):
    await RisingEdge(dut.clock)
    dut.rw_address.value = add
    dut.write_data.value = value
    dut.write_strobe.value = strobe
    dut.write_request.value = 1
    await RisingEdge(dut.write_response)
    dut.write_request.value = 0
    await RisingEdge(dut.clock)


async def read_request(dut, add):
    await RisingEdge(dut.clock)
    dut.rw_address.value = add
    dut.read_request.value = 1
    await RisingEdge(dut.read_response)
    data = dut.read_data.value
    dut.read_request.value = 0
    await RisingEdge(dut.clock)
    return data


@cocotb.test()
async def test_irq(dut):
    setup_dut(dut)
    await reset_dut(dut)
    await Timer(1, units='us')

    # Reset, mtime != mtimecmp and irq out == 0
    assert dut.mtime.value != dut.mtimecmp.value
    assert dut.irq.value == 0

    await write_request(dut, add=REG_MTIMEL, value=10)
    await write_request(dut, add=REG_MTIMEH, value=0)

    await write_request(dut, add=REG_MTIMECMPL, value=20)
    await write_request(dut, add=REG_MTIMECMPH, value=0)

    # Reset, mtime > mtimecmp and irq out == 0
    assert dut.irq.value == 0

    await Timer(CLK_PERIOD_NS*10*2, units='ns')

    # Reset, mtime > mtimecmp and irq out == 0, mtimer disable
    assert dut.irq.value == 0

    # mtimer enable
    await write_request(dut, add=REG_CR, value=1)
    await Timer(CLK_PERIOD_NS*11, units='ns')

    # Reset, mtime >= mtimecmp and irq out == 1, mtimer enable
    assert dut.irq.value == 1


@cocotb.test()
async def test_address_misaligned(dut):
    setup_dut(dut)
    await reset_dut(dut)
    await Timer(1, units='us')

    await write_request(dut, add=REG_CR, value=1)
    await Timer(CLK_PERIOD_NS*11, units='ns')

    cr = await read_request(dut, add=REG_CR)
    assert cr == 1

    # misaligned
    await write_request(dut, add=REG_CR+1, value=0)

    # TODO: use it later
    # assert dut.access_fault.value == 1

    cr = await read_request(dut, add=REG_CR)
    assert cr == 1