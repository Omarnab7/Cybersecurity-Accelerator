# Cryptographic Accelerator for AI-at-the-Edge

This project is a hardware-accelerated implementation of the **Tiny Encryption Algorithm (TEA)**, designed for **AI-at-the-edge** systems. It is built in **SystemVerilog** and utilizes a **Wishbone bus** interface for seamless integration with embedded systems and RISC-V platforms. The design focuses on providing low-latency, energy-efficient data encryption, a critical requirement for securing data in resource-constrained edge devices.

## Key Features
* **Hardware Acceleration**: A dedicated hardware core to perform TEA encryption, offloading the computationally intensive task from the main processor.
* **Wishbone Bus Interface**: The design adheres to the **Wishbone bus protocol**, a widely used standard in SoC (System-on-Chip) development for connecting IP cores.
* **Low-Latency Design**: The architecture is optimized for performance, ensuring that cryptographic operations are completed with minimal delay, which is vital for real-time edge computing applications.
* **Scalability & Reusability**: The modular design allows for easy integration into various hardware platforms, including **FPGAs** and **ASICs**.
* **Hardware/Software Co-design**: The register-based interface enables a clear separation of hardware and software tasks, allowing software to control the accelerator via memory-mapped I/O.
* **Secure IoT Applications**: The accelerator is ideal for **securing data at the sensor level** in IoT and edge AI applications, where data privacy and integrity are paramount.

## Module Descriptions

### 1. `accelerator_top.sv`
This is the top-level module that instantiates and connects all sub-modules. It serves as the primary interface between the external **Wishbone bus** and the internal logic of the accelerator. It also includes debug probes for simulation purposes.

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

## Block Diagram



* **`accelerator_top`** is the main wrapper.
* **`accelerator_wb`** handles communication with the **Wishbone bus**.
* **`accelerator_regs`** acts as the interface for the CPU to set inputs and read outputs and status.
* **`accelerator_core`** performs the actual cryptographic calculation.

## Getting Started

To simulate or synthesize this project, you will need a **SystemVerilog-compatible toolchain** (e.g., Vivado, QuestaSim, or VCS).

1.  Clone this repository:
    ```bash
    git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
    ```
2.  Add the four `.sv` files to your project.
3.  Set `accelerator_top.sv` as the top-level module.
4.  Run a simulation or synthesize the design for your target FPGA/ASIC.
