## Welcome to LearnToBuildCPU 🚀

This project is more than just a pipelined CPU — it’s a guided journey through the inner workings of computer architecture, designed for learners who want to **build**, **break**, **debug**, and **extend** real hardware logic.

I created this as the resource I wish I had when I first started — something hands-on, with clear structure but open-ended enough to explore freely. The design is verified with randomized testbenches (10K–1M+ cases), waveform snapshots, and summaries to help you stay confident while experimenting.

---

## 🧠 Design Philosophy & Exploration Guide

I could have minimized this code more — and I might still do that in the future — but for now, I intentionally kept it readable, diverse, and modular to serve as a learning platform.

Not everything here is "perfectly" optimized. Some parts use shared constants from a centralized file, while others declare values locally. Some modules are compact and reusable, while others are more expanded version. This is all intentional — I wanted to leave room for you to explore, refactor, and improve.

This CPU isn’t just a finished project — it’s a **sandbox for learners**. If you’re writing your own pipeline or just starting with HDL, this code gives you a playground with safety rails.

### 🔍 Ways You Can Explore This CPU

- ✅ **Refactor & Minimize**
    - Replace longer code with `struct` in SystemVerilog or `record` types in VHDL
    - Consolidate locally declared constants into global shared files
    - Create reusable modules where repetition exists

- ✅ **Modify Without Fear**
    - Self-checking testbenches verify functionality with thousands (sometimes millions) of test cases
    - These act as guardrails — so you’ll know if your changes break something

- ✅ **Visual Reference Included**
    - Waveform screenshots and test result summaries are provided
    - You’ll know what behavior to expect and have visual proof of correctness

- ✅ **Mixed-Language Design**
    - Includes VHDL wrappers for Verilog modules, demonstrating interoperability
    - Great if you want to explore cross-language simulation or synthesis

- ✅ **Explore Design Choices**
    - Some control signals are bundled together, others passed separately — optimize or restructure them
    - Signal naming and modularity vary across files so you can practice unifying or improving them

- ✅ **Extend and Scale**
    - Add missing instructions (e.g., `AUIPC`, `LUI`, `MUL/DIV`)
    - Introduce instruction/data caches or branch prediction
    - Design and test a custom debugging unit, interrupt handler, or hazard visualizer

---

🧵 **Synthesis-Ready VHDL Version Included**

This project includes a synthesizable VHDL version that runs on an actual FPGA board. While I used VHDL for my implementation, the same concepts can be translated into Verilog or SystemVerilog — and if you choose to do it that way, I’d love to hear about it!

---

## 🧰 Tools & Technologies

- **Languages:** VHDL, Verilog, SystemVerilog
- **Simulators:** ModelSim, GHDL, Icarus Verilog
- **Design Tools:** Vivado (for FPGA integration)
- **Version Control:** GitHub

---

## 💬 Feedback & Contribution Guidelines

If you’re learning or building something similar, feel free to open an issue, share insights, or just say hello. 
I also welcome:
- Suggestions for improving the documentation or design clarity
- Additions in a **separate folder** that explore new instructions, caching, or structural changes
- Your personal forks if you translate this to Verilog/SystemVerilog or add GUI/visual tools

⚠️ **NOTE**: I want to preserve this main codebase as a teaching platform — so please submit feature changes or refactors in a clearly separate directory to avoid overwriting the core pipeline.

--- 

## 🙏 Contributor
Thank you to **S N Ravindra** (https://github.com/RAVINDRA0022) for the alu (under extra folder)

---

## 👤 Author
**Noridel Herron**  
Senior in Computer Engineering – University of Missouri  
Graduation date: May 2026 | Available to work: July 2026 or earlier

Gmail  : noridel.herron@gmail.com  
Linkedn: (https://www.linkedin.com/in/noridel-h-5a5534156/)
GitHub : [@NoridelHerron](https://github.com/NoridelHerron)

