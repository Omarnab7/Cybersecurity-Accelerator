# Cryptographic Accelerator for AI-at-the-Edge

This project is a hardware-accelerated implementation of the **Tiny Encryption Algorithm (TEA)**, designed for **AI-at-the-edge** systems. It is implemented in **SystemVerilog** and verified on a **NexysA7 FPGA development board**. The accelerator uses a **Wishbone bus** interface for seamless integration with a **RISC-V core**, providing a complete hardware/software co-design solution for securing data in resource-constrained edge devices.

## Key Features
* **Hardware Acceleration**: A dedicated hardware core to perform TEA encryption, offloading the computationally intensive task from the main processor.
* **Wishbone Bus Interface**: The design adheres to the **Wishbone bus protocol**, a widely used standard in SoC (System-on-Chip) development for connecting IP cores.
* **FPGA Implementation**: The design has been successfully implemented on the **Digilent NexysA7 FPGA board**, demonstrating its viability for prototyping and deployment.
* **RISC-V Integration**: The accelerator is designed to interface with a **RISC-V processor**, enabling a flexible and open-source computing platform for edge AI applications.
* **Low-Latency Design**: The architecture is optimized for performance, ensuring that cryptographic operations are completed with minimal delay, which is vital for real-time edge computing.
* **Hardware/Software Co-design**: The register-based interface enables a clear separation of hardware and software tasks, allowing software running on the RISC-V core to control the accelerator via memory-mapped I/O.
* **Secure IoT Applications**: The accelerator is ideal for **securing data at the sensor level** in IoT and edge AI applications, where data privacy and integrity are paramount.

## Module Descriptions

### 1. `accelerator_top.sv`
This is the top-level module that instantiates and connects all sub-modules. It serves as the primary interface between the external **Wishbone bus** and the internal logic of the accelerator.

### 2. `accelerator_wb.sv`
This module provides the **Wishbone bus interface**. It handles bus handshaking signals (`wb_stb_i`, `wb_cyc_i`, `wb_ack_o`) and manages the data flow between the bus and the internal registers. This module is based on a standard Wishbone interface, ensuring compatibility with a wide range of systems.

### 3. `accelerator_regs.sv`
This module defines the memory-mapped registers for controlling the accelerator. It manages reads and writes to and from these registers based on Wishbone addresses.
The module defines the following registers:
* **`ACCELERATOR_REG_A` (8'h0)**: Input register for the first 16-bit operand.
* **`ACCELERATOR_REG_B` (8'h4)**: Input register for the second 16-bit operand.
* **`ACCELERATOR_REG_RESULT` (8'h8)**: Output register for the 16-bit result.
* **`ACCELERATOR_REG_STATUS` (8'hc)**: Status register that contains the `overflow` bit.

### 4. `accelerator_core.sv`
This module contains the core arithmetic logic of the accelerator. Its primary function is to perform a signed multiplication of two 16-bit inputs (`reg_a` and `reg_b`) as part of the TEA algorithm. The result is a 32-bit value, which is then truncated to 16 bits for the `reg_result` output. The module also includes logic to detect **overflow**, a crucial feature for data integrity.

## Getting Started

To test and deploy this project, you will need a **SystemVerilog-compatible toolchain** and a **Digilent NexysA7 FPGA board**.

1.  Clone this repository.
2.  Add the four `.sv` files to your FPGA project.
3.  Ensure your **RISC-V** soft core is configured to interface with the accelerator via the Wishbone bus.
4.  Set `accelerator_top.sv` as the top-level module for synthesis and implementation.
5.  Generate the bitstream and program the **NexysA7 card**.
6.  Use a bare-metal or embedded Linux program on the RISC-V core to write and read from the accelerator's memory-mapped registers.
