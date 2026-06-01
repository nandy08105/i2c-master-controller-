# I2C Master Controller for TinyTapeout

## Overview

This project implements a simple I2C Master Controller in Verilog for the TinyTapeout platform. The controller can initiate single-byte I2C read and write transactions to a slave device.

The design generates the I2C START condition, transmits the slave address and R/W bit, handles ACK cycles, transfers one data byte, and generates the STOP condition.

---

## Features

* Single-byte I2C write operation
* Single-byte I2C read operation
* I2C START and STOP generation
* ACK handling
* TinyTapeout compatible interface
* Implemented in Verilog RTL

---

## Pin Mapping

### Inputs (`ui_in[7:0]`)

| Bit        | Function                      |
| ---------- | ----------------------------- |
| ui_in[7]   | cmd_valid (start transaction) |
| ui_in[6]   | rw (0 = write, 1 = read)      |
| ui_in[5:0] | I2C slave address bits        |

### Outputs (`uo_out[7:0]`)

| Bit         | Function                    |
| ----------- | --------------------------- |
| uo_out[7:0] | Received data byte / status |

### Bidirectional Pins (`uio`)

| Pin           | Function |
| ------------- | -------- |
| uio[0]        | I2C SCL  |
| uio[1]        | I2C SDA  |
| uio[2]–uio[7] | Unused   |

---

## Clock

* System Clock: 10 MHz
* Configured using TinyTapeout clock input (`clk`)

---

## Simulation

Run the simulation using Icarus Verilog:

```bash
iverilog -g2012 -o sim test/tb.v src/project.v
vvp sim
```

View waveforms:

```bash
gtkwave tb.vcd
```

---

## Cocotb Test

Run the TinyTapeout cocotb test:

```bash
pytest
```

or use the TinyTapeout GitHub Actions workflow.

---

## File Structure

```text
src/
├── project.v
├── config.json

test/
├── tb.v
├── test.py

info.yaml
README.md
```

---

## Author

Your Name

## License

MIT License


