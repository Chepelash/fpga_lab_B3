transcript on


vlib work

vlog -sv ../src/fsm.sv
vlog -sv ../src/inp_comb.sv
vlog -sv ../src/mem_ctrl.sv
vlog -sv ../src/ram_memory.sv
vlog -sv ../src/sorter.sv
vlog -sv ../src/sorting.sv

vlog -sv ./sorting_tb.sv

vsim -novopt sorting_tb 

add wave /sorting_tb/clk_i
add wave /sorting_tb/srst_i
add wave -radix hex /sorting_tb/data_i
add wave /sorting_tb/sop_i
add wave /sorting_tb/eop_i
add wave /sorting_tb/val_i
add wave -radix hex /sorting_tb/data_o
add wave /sorting_tb/sop_o
add wave /sorting_tb/eop_o
add wave /sorting_tb/val_o
add wave /sorting_tb/busy_o

add wave /sorting_tb/DUT/wren
add wave /sorting_tb/DUT/wrpntr
add wave /sorting_tb/DUT/rdpntr
add wave /sorting_tb/DUT/fsm_sort_op
add wave /sorting_tb/DUT/fsm_output_op
add wave /sorting_tb/DUT/fsm_clr
add wave -radix hex /sorting_tb/DUT/srt_outp_module/data_array


run -all

