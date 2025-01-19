
vlib work

# 编译设计文件和 Testbench 文件
vcom -93 servomoteur.vhd
vcom -93 servomoteur_tb.vhd

# 加载仿真
vsim -voptargs="+acc" work.DE10_Lite_Servomoteur_tb

# 设置波形窗口
add wave -position insertpoint sim:/DE10_Lite_Servomoteur_tb/clk_tb
add wave -position insertpoint sim:/DE10_Lite_Servomoteur_tb/RST_N_tb
add wave -position insertpoint sim:/DE10_Lite_Servomoteur_tb/position_tb
add wave -position insertpoint sim:/DE10_Lite_Servomoteur_tb/commande_tb
add wave -position insertpoint sim:/DE10_Lite_Servomoteur_tb/UUT/cpt
add wave -position insertpoint sim:/DE10_Lite_Servomoteur_tb/UUT/cpt_envoi
add wave -position insertpoint sim:/DE10_Lite_Servomoteur_tb/UUT/resultat

# 设置仿真时间
run 200 ms

# 显示仿真结果
wave zoom full
