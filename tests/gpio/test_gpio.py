# SPDX-License-Identifier: MIT
# Copyright (c) 2020-2025 RVX Project Contributors

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge


CLK_PERIOD_NS   = 100

REG_IN      = 0*4
REG_OE      = 1*4
REG_OUT     = 2*4
REG_CLR     = 3*4
REG_SET     = 4*4


def setup_dut(dut):
    cocotb.start_soon(Clock(dut.clock, CLK_PERIOD_NS, units='ns').start())


async def reset_dut(dut):
    dut.reset_n.value = 0
    await ClockCycles(dut.clock, 10)
    dut.reset_n.value = 1
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
async def test_input(dut):
    setup_dut(dut)
    await reset_dut(dut)
    await Timer(1, units='us')

    dut.gpio_input.value = 0x0
    await RisingEdge(dut.clock)
    assert 0x0 == await read_request(dut, add=REG_IN)

    dut.gpio_input.value = 0x3
    await RisingEdge(dut.clock)
    assert 0x3 == await read_request(dut, add=REG_IN)

    dut.gpio_input.value = 0x1
    await RisingEdge(dut.clock)
    assert 0x1 == await read_request(dut, add=REG_IN)

@cocotb.test()
async def test_output(dut):
    setup_dut(dut)
    await reset_dut(dut)
    await Timer(1, units='us')

    await write_request(dut, add=REG_OUT, value=0x0)
    assert 0x0 == dut.gpio_output.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

    await write_request(dut, add=REG_OUT, value=0x1)
    assert 0x1 == dut.gpio_output.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

    await write_request(dut, add=REG_OUT, value=0x3)
    assert 0x3 == dut.gpio_output.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

@cocotb.test()
async def test_enable(dut):
    setup_dut(dut)
    await reset_dut(dut)
    await Timer(1, units='us')

    await write_request(dut, add=REG_OE, value=0x0)
    assert 0x0 == dut.gpio_oe.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

    await write_request(dut, add=REG_OE, value=0x1)
    assert 0x1 == dut.gpio_oe.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

    await write_request(dut, add=REG_OE, value=0x3)
    assert 0x3 == dut.gpio_oe.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

@cocotb.test()
async def test_clear_mask(dut):
    setup_dut(dut)
    await reset_dut(dut)
    await Timer(1, units='us')

    # gpio_output=0x0
    await write_request(dut, add=REG_OUT, value=0x0)
    assert 0x0 == dut.gpio_output.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

    await write_request(dut, add=REG_CLR, value=0x0)
    assert 0x0 == dut.gpio_output.value

    await write_request(dut, add=REG_CLR, value=0x1)
    assert 0x0 == dut.gpio_output.value

    await write_request(dut, add=REG_CLR, value=0x3)
    assert 0x0 == dut.gpio_output.value

    # gpio_output=0x1
    await write_request(dut, add=REG_OUT, value=0x1)
    assert 0x1 == dut.gpio_output.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

    await write_request(dut, add=REG_CLR, value=0x0)
    assert 0x1 == dut.gpio_output.value

    await write_request(dut, add=REG_CLR, value=0x2)
    assert 0x1 == dut.gpio_output.value

    await write_request(dut, add=REG_CLR, value=0x1)
    assert 0x0 == dut.gpio_output.value

    await write_request(dut, add=REG_CLR, value=0x1)
    assert 0x0 == dut.gpio_output.value

    # gpio_output=0x3
    await write_request(dut, add=REG_OUT, value=0x3)
    assert 0x3 == dut.gpio_output.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

    await write_request(dut, add=REG_CLR, value=0x0)
    assert 0x3 == dut.gpio_output.value

    await write_request(dut, add=REG_CLR, value=0x2)
    assert 0x1 == dut.gpio_output.value

    await write_request(dut, add=REG_CLR, value=0x1)
    assert 0x0 == dut.gpio_output.value

    await write_request(dut, add=REG_CLR, value=0x1)
    assert 0x0 == dut.gpio_output.value

@cocotb.test()
async def test_set_mask(dut):
    setup_dut(dut)
    await reset_dut(dut)
    await Timer(1, units='us')

    # gpio_output=0x0
    await write_request(dut, add=REG_OUT, value=0x0)
    assert 0x0 == dut.gpio_output.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

    await write_request(dut, add=REG_SET, value=0x0)
    assert 0x0 == dut.gpio_output.value

    await write_request(dut, add=REG_SET, value=0x1)
    assert 0x1 == dut.gpio_output.value

    await write_request(dut, add=REG_SET, value=0x0)
    assert 0x1 == dut.gpio_output.value

    # gpio_output=0x2
    await write_request(dut, add=REG_OUT, value=0x2)
    assert 0x2 == dut.gpio_output.value

    await Timer(CLK_PERIOD_NS*3, units='ns')

    await write_request(dut, add=REG_SET, value=0x0)
    assert 0x2 == dut.gpio_output.value

    await write_request(dut, add=REG_SET, value=0x2)
    assert 0x2 == dut.gpio_output.value

    await write_request(dut, add=REG_SET, value=0x1)
    assert 0x3 == dut.gpio_output.value
