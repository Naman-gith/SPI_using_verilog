# SPI_using_verilog# SPI Master (Verilog RTL)

## Overview

This project implements a configurable SPI Master in Verilog supporting all four SPI modes using CPOL and CPHA. It enables full-duplex communication with programmable clock division and flexible data width.

## Features

* Supports SPI Modes 0, 1, 2, 3
* Configurable clock divider
* Parameterized data width
* Full-duplex data transfer
* Synchronous design
* Start/Done handshake interface

## Parameters

* `CLK_DIV` : Controls SPI clock frequency relative to system clock
* `DATA_WIDTH` : Defines number of bits per transfer

## Ports

### Inputs

* `clk` : System clock
* `rst` : Asynchronous reset
* `start` : Initiates SPI transaction
* `data_in` : Data to be transmitted
* `miso` : Master Input Slave Output
* `cpol` : Clock polarity
* `cpha` : Clock phase

### Outputs

* `mosi` : Master Output Slave Input
* `sclk` : SPI clock
* `cs` : Chip select (active low)
* `data_out` : Received data
* `done` : Transfer completion flag

## Working

* When `start` is asserted, the module loads input data into a shift register
* SPI clock is generated using internal clock divider
* Data is shifted out on MOSI and sampled from MISO based on CPHA
* Chip Select is driven low during active transfer
* After all bits are transmitted, `done` is asserted and CS is deasserted

## SPI Mode Table

| Mode | CPOL | CPHA |
| ---- | ---- | ---- |
| 0    | 0    | 0    |
| 1    | 0    | 1    |
| 2    | 1    | 0    |
| 3    | 1    | 1    |

## Usage

1. Set parameters `CLK_DIV` and `DATA_WIDTH`
2. Provide input data on `data_in`
3. Assert `start` for one clock cycle
4. Wait for `done` signal
5. Read received data from `data_out`

## Timing Behavior

* Data is shifted MSB first
* Clock toggles based on divider
* Leading/trailing edges depend on CPHA
* CS remains low throughout transmission

## Limitations

* Single transaction at a time
* No FIFO buffering
* No multi-slave arbitration logic


