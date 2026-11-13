# ModelSim/QuestaSim simulation script for TLAB2 ALU
# Run with: vsim -do simulate.do

# Create work library
vlib work

# Compile all VHDL files (order matters for dependencies)
vcom -2008 full_adder.vhd
vcom -2008 adder4.vhd
vcom -2008 adder_subtractor4.vhd
vcom -2008 flags_unit.vhd
vcom -2008 au_module.vhd
vcom -2008 xor0.vhd
vcom -2008 logic_module.vhd
vcom -2008 decode_op.vhd
vcom -2008 flags_alu.vhd
vcom -2008 mux2to1_4bit.vhd
vcom -2008 alu.vhd
vcom -2008 alu_tb.vhd

# Start simulation
vsim work.alu_tb

# Add signals to wave
add wave -position insertpoint  \
    /alu_tb/X \
    /alu_tb/Y \
    /alu_tb/OP \
    /alu_tb/CBi \
    /alu_tb/R \
    /alu_tb/CBo \
    /alu_tb/OV \
    /alu_tb/Z \
    /alu_tb/GE \
    /alu_tb/BE

# Run simulation
run 2 us