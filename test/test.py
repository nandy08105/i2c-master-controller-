import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def test_i2c_master_transaction(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, units="ns").start()
    )

    dut.ena.value = 1
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await Timer(100, units="ns")

    dut.rst_n.value = 1

    for _ in range(5):
        await RisingEdge(dut.clk)

    # Start command
    dut.ui_in.value = 0x94

    await RisingEdge(dut.clk)

    # Data byte
    dut.ui_in.value = 0x55

    await RisingEdge(dut.clk)

    dut.ui_in.value = 0

    # Observe bus activity
    saw_scl_toggle = False
    previous_scl = int(dut.uio_out.value[0])

    for _ in range(5000):

        # Generate ACK when SDA released
        if int(dut.uio_oe.value[1]) == 0:
            dut.uio_in.value = 0b00000000

        current_scl = int(dut.uio_out.value[0])

        if current_scl != previous_scl:
            saw_scl_toggle = True

        previous_scl = current_scl

        await RisingEdge(dut.clk)

    assert saw_scl_toggle, "SCL never toggled"

    dut._log.info("PASS: I2C activity detected")

