## Welcome to the LearnToBuildCPU project!
The primary purpose of this project is to make learning computer architecture easier and more accessible for students, hobbyists, and aspiring engineers. I want this to be the kind of resource I wish I had when I first started.

### 🧠 What Is This Project?

This is a modular, educational RISC-V CPU project built using VHDL and Verilog. It's designed to teach computer architecture concepts through hands-on development, clean structure, and rich documentation.

This project is designed to be:
- As basic and readable as possible – so even beginners can follow along.
- Modular and well-documented – each component is explained, with clear roles and signal flows.
- Built in multiple HDLs – such as VHDL and Verilog/SystemVerilog, so learners can compare and learn from different styles and languages.
- Expandable for deeper learning – while the core is kept simple, there are opportunities to learn more advanced topics such as:
    - Writing wrappers
    - Using records/structs
    - Building simulation testbenches
    - Understanding control signals, hazard detection, and forwarding

I know how it feels to work in the dark, trying to build something you don’t fully understand. That’s why everything in this project is being documented carefully—so as you build, you also understand.

---

## 📋 What I’ll Provide
- A detailed list of input/output signals for each module to guide the refactor
- Clear credit for contributors in the repo, documentation, and any related blog posts

---

## 🙌 Collaboration and Support
- I’m currently preparing a list of tasks that you can choose from based on your interests and experience level. Each contributor will get a dedicated branch (named after your first name) so you can work independently while keeping things organized.
- We're also exploring support for both VHDL and Verilog versions of the design—so feel free to contribute in the language you're most comfortable with.
- If you have your own ideas on how to contribute, I’d love to hear them. Let’s learn and build together. 🚀
---

## 🧪 Testbench Plans
Once I finish my current superscalar project, I will:
- Write a SystemVerilog/VHDL testbench with assertions to ensure all contributor-built modules are rock solid
- Inject bugs to demonstrate debugging techniques
- Add a TCL + waveform debugging guide
- Possibly publish a tutorial or blog post for learners to follow

**NOTE**: I've written testbenches for the ALU and decoder modules. Feel free to use them—just make sure to update the DUT instance name if yours is different. You may also need to adjust the input and output connections if your port order is not the same. And of course, feel free to modify the testbenches as needed.

---

## 💡 Personal Vision & Acknowledgement
I’m aware that this project currently has several flaws and areas that need improvement. As I continue refactoring and connecting the modules properly according to the RISC-V standard, my personal goal is to rebuild the design following more standard and widely accepted practices—not just based on observation or intuition.

This project is also a learning journey for me. I'm actively seeking feedback and input from more experienced developers to ensure that the architecture and implementation reflect best practices. By doing this, I hope to both deepen my own understanding and make the project more reliable, educational, and transparent for others who want to learn.

---

## 🧰 Tools & Technologies

- **Languages:** VHDL, Verilog, SystemVerilog
- **Simulators:** ModelSim, GHDL, Icarus Verilog
- **Design Tools:** Vivado (for FPGA integration)
- **Version Control:** Git + GitHub

--- 

If this sounds exciting or meaningful to you and you’d like to be listed as a contributor, just reach out. Let’s build something that helps the next generation of CPU designers learn with clarity and confidence.

---

## 🔧 Note to All Contributors
I’m currently preparing a list of tasks you can choose from based on your interests and skill level. Each contributor will have a branch named after their first name, so everyone can work independently while keeping things organized.

If you have your own idea for how you’d like to contribute—feel free to propose it! This is a collaborative, learner-focused space.

---

## 💬 Feedback Welcome

If you have suggestions, spot errors, or want to help improve documentation or design, feel free to open an issue or start a discussion. This is a learning-focused space, and I welcome all constructive input.

--- 

## 🙏 Contributors & Early Supporters
Thank you to everyone who has already shown interest and joined this project! Your enthusiasm and support mean a lot.
- **S N Ravindra** (https://github.com/RAVINDRA0022)

........

