# Create and map the work library
vlib work
vmap work work

# Compile the VHDL files
vcom -93 servomoteur_avalon.vhd
vcom -93 tb_IP_Servo_Avalon.vhd

# Load the simulation for the testbench
vsim -novopt work.tb_IP_Servo_Avalon

# Open the waveform window
view wave

# Add all signals from the testbench to the waveform
add wave -r /*

# Run the simulation for 10 milliseconds
run 1000ms
