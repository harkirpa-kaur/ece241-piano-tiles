# ECE241 Piano Tiles

A **Piano Tiles-style rhythm game** implemented in Verilog for the DE1-SoC FPGA as part of U of T's ECE241 Digital Systems course.

The project combines VGA graphics, PS/2 keyboard input, audio playback, and FSM-based game control. I later refactored the design to make the controller and datapath easier to test independently and built a SystemVerilog verification environment around them.

## Highlights

- Verilog RTL for game logic and FPGA integration
- VGA tile rendering and PS/2 keyboard input
- Audio playback using `.mif` memory initialization files
- FSM-based controller with separate datapath logic
- Self-checking SystemVerilog testbenches
- Immediate and temporal assertions
- Randomized controller timing using `$urandom_range`
- State and transition functional-coverage definitions

## Controller Verification

The controller follows:

```text
WAIT -> SPAWN -> SHIFT1 -> SHIFT2 -> SHIFT3 -> SPAWN
```

The testbench verifies state transitions, hold behavior, reset handling, and each completion condition. Randomized stimulus varies how long the FSM remains in each state, while temporal assertions continuously check correct behavior.

## Datapath Verification

The controller datapath generates completion signals from operation counters. Its self-checking testbench verifies behavior below, at, and above the completion threshold.

## Tools

Verilog, SystemVerilog, Intel Quartus, ModelSim / QuestaSim, DE1-SoC, VGA, PS/2, RTL FSM design, assertion-based verification.

## Running the Tests

```tcl
vlib work
vlog game_controller.v
vlog -sv tb/tb_game_controller.sv
vsim work.tb_game_controller
run -all
```

Datapath:

```tcl
vlog controller_datapath.v
vlog -sv tb/tb_controller_datapath.sv
vsim work.tb_controller_datapath
run -all
```

Native `covergroup` definitions are included, but executing them requires a Questa `svverification` license.

## Ongoing Work

Broader datapath verification, controller/datapath integration, and keyboard/input-path verification.
