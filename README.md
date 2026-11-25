# SPI-Full-Duplex-Communication
Design and verification of SPI Full-Duplex Master-Slave Communication using Verilog HDL and QuestaSim.
# SPI Full-Duplex Communication using Verilog HDL

## Project Overview
This project implements an SPI (Serial Peripheral Interface) communication protocol using Verilog HDL with one Master and one Slave.

The design supports full-duplex communication, allowing both devices to transmit and receive data simultaneously.

## Features
- SPI Master and Slave architecture
- FSM-based Master design
- SPI Clock Divider
- MOSI and MISO communication
- Rising and Falling Edge Detection
- TX and RX Shift Registers
- 8-bit data transmission
- Full-Duplex Communication

## Design Configuration
- Data Width: 8 bits
- Clock Divider: 4
- SPI Mode: Mode 0
- Bit Order: MSB First
- Simulation Tool: QuestaSim

## Simulation Results

| Description | Data |
|---|---|
| Master Transmitted | 10110010 |
| Slave Received | 10110010 |
| Slave Transmitted | 11001010 |
| Master Received | 11001010 |

**Result: SPI FULL DUPLEX TEST PASSED**

## Tools Used
- Verilog HDL
- QuestaSim

## Learning Outcomes
- RTL Design
- Finite State Machine
- Serial Communication
- Shift Register Implementation
- Functional Simulation and Verification<img width="1251" height="231" alt="Screenshot 2026-11-25 191005" src="https://github.com/user-attachments/assets/9650660d-1472-41a9-bf83-518a44cc963e" />
<img width="1246" height="396" alt="Screenshot 2026-11-25 190915" src="https://github.com/user-attachments/assets/680759b1-c8fa-4c22-bcb4-1f4960ba6689" />
<img width="1396" height="357" alt="Screenshot 2026-11-25 190800" src="https://github.com/user-attachments/assets/c8db7633-fb31-4b24-bf6d-1e7539a49b67" />
<img width="1227" height="673" alt="Screenshot 2026-11-25 185810" src="https://github.com/user-attachments/assets/8cf42bc6-f6f3-47d7-933d-8e8c16e7fc2d" />
