# RVX10-P: A Five-Stage Pipelined RISC-V Core

**RVX10-P** is a five-stage pipelined RISC-V processor core implementing the **RV32I base ISA** along with **10 custom ALU instructions**.  
Developed under the course **Digital Logic and Computer Architecture ** taught by **Dr. Satyajit Das**, **IIT Guwahati**.

---

## 🧠 Project Overview

RVX10-P is designed as a **fully functional pipelined RISC-V processor** with the following key features:
- Implements **RV32I** instruction set architecture.
- **Five pipeline stages**: IF, ID, EX, MEM, WB.
- **Hazard detection**, **data forwarding**, and **pipeline flushing** mechanisms.
- **Custom ALU extensions** for special-purpose computations.
- Verified with an assembly test program that stores the value `25` to memory address `100`.

---

## 🏗️ Pipeline Architecture

| Stage | Name | Function |
|:------|:------|:----------|
| IF | Instruction Fetch | Fetch instruction from instruction memory using PC |
| ID | Instruction Decode | Decode instruction, read registers, generate control signals |
| EX | Execute | Perform ALU operations, branch address calculation |
| MEM | Memory Access | Access data memory for load/store instructions |
| WB | Write Back | Write ALU or memory results back to register file |

---

## ⚙️ Design Highlights

- **Forwarding Logic:**  
  Supports forwarding from EX/MEM and MEM/WB stages to resolve data hazards between consecutive ALU operations.

- **Stalling Logic:**  
  Inserts a **single-cycle stall** for load-use hazards (when an instruction depends on a just-loaded register).

- **Branch Handling:**  
  Implements **pipeline flush** on taken branches or jumps (`beq`, `bne`, `jal`, etc.) to discard incorrect instructions.

- **Register File Integrity:**  
  The **x0 register** is hardwired to zero and remains unchanged throughout execution.

---

## 🧩 Custom Instructions

RVX10-P adds **10 custom ALU operations** to the standard RV32I set, enhancing arithmetic and logic performance for specific applications.  
Examples include:
- Bit manipulation
- Multiply-accumulate
- Conditional logic functions  
*(Exact operation list detailed in REPORT.md)*

---

## ✅ Verification Checklist

| Requirement | Status |
|--------------|---------|
| Test program stores 25 to memory[100] | ✔️ Verified |
| x0 register constant at zero | ✔️ Verified |
| Forwarding for back-to-back ALU ops | ✔️ Verified |
| Single-cycle stall for load-use | ✔️ Verified |
| Pipeline flush for taken branches | ✔️ Verified |
