vlib work 

vcom -93 IPtelemetre.vhd
vcom -93 Telemetre_tb.vhd

vsim -novopt telemetre_tb
view signals 

add wave sim:/telemetre_tb/G1/*
run -all