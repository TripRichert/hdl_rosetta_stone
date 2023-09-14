#! /bin/env python3

import cocotb
from cocotb.triggers import RisingEdge, Timer

async def generate_clock(dut):
    for cycle in range(100):
        dut.clk.value = 0
        await Timer(5, units="ns")
        dut.clk.value = 1
        await Timer(5, units="ns")

@cocotb.test()
async def basictest_bram_std_fifo(dut):
    await cocotb.start(generate_clock(dut))
    dut.rst.value = 0
    dut.rd_en.value = 0
    dut.wr_en.value = 0
    dut.src_data.value = 0

    for cycle in range(5):
        await RisingEdge(dut.clk)
    dut.rst.value = 1
    for cycle in range(5):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    for cycle in range(5):
        await RisingEdge(dut.clk)
    
    wr_cnt = 0
    wr_toggle = 0
    wr_vals = []
    for cycle in range(10):
        dut.wr_en.value = wr_toggle
        dut.src_data.value = wr_cnt
        wr_toggle = (wr_toggle + 1) % 2
        await RisingEdge(dut.clk)
        if dut.wr_en.value:
            wr_vals.append(dut.src_data.value)
            wr_cnt = wr_cnt + 1
    dut.wr_en.value = 0
    await RisingEdge(dut.clk)
    data_cnt = dut.data_cnt.value
    assert(data_cnt == wr_cnt)
            
    wr_toggle = 0
    rd_toggle = 0
    rd_vals = []
    rd_cnt = 0
    last_rd_en = 0
    for cycle in range(10):
        if last_rd_en == 1:
            rd_vals.append(dut.dest_data.value)
            rd_cnt = rd_cnt + 1
            last_rd_en = dut.rd_en.value
        dut.rd_en.value = rd_toggle
        value = dut.src_data.value
        rd_toggle = (rd_toggle + 1) % 2
        await RisingEdge(dut.clk)

    assert rd_cnt == rd_cnt
    pairs = zip(rd_vals, wr_vals)
    for pair in pairs:
        assert(pair[0] == pair[1])
