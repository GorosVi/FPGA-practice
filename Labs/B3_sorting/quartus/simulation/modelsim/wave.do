onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk_i
add wave -noupdate /tb/srst_i
add wave -noupdate /tb/sop_i
add wave -noupdate /tb/eop_i
add wave -noupdate /tb/val_i
add wave -noupdate -radix hexadecimal /tb/data_i
add wave -noupdate /tb/sop_o
add wave -noupdate /tb/eop_o
add wave -noupdate /tb/val_o
add wave -noupdate -radix hexadecimal /tb/data_o
add wave -noupdate /tb/busy_o
add wave -noupdate /tb/i_sorting/state
add wave -noupdate /tb/i_sorting/sort_finished
add wave -noupdate -radix unsigned /tb/i_sorting/input_write_ptr
add wave -noupdate -radix unsigned /tb/i_sorting/input_write_ptr_new
add wave -noupdate -radix unsigned /tb/i_sorting/out_read_ptr
add wave -noupdate -radix unsigned /tb/i_sorting/out_read_ptr_new
add wave -noupdate /tb/i_sorting/mem_wren_a
add wave -noupdate /tb/i_sorting/mem_wren_b
add wave -noupdate -radix unsigned /tb/i_sorting/mem_ptr_a
add wave -noupdate -radix unsigned /tb/i_sorting/mem_ptr_b
add wave -noupdate -radix hexadecimal /tb/i_sorting/mem_data_a
add wave -noupdate -radix hexadecimal /tb/i_sorting/mem_data_b
add wave -noupdate -radix hexadecimal /tb/i_sorting/mem_q_a
add wave -noupdate -radix hexadecimal /tb/i_sorting/mem_q_b
add wave -noupdate -radix unsigned /tb/i_sorting/sort_ptr_start
add wave -noupdate -radix unsigned /tb/i_sorting/sort_ptr_end
add wave -noupdate -radix unsigned /tb/i_sorting/sort_swap_op
add wave -noupdate -radix hexadecimal /tb/i_sorting/i_true_dual_port_ram_single_clock/ram
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2358 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 215
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2976 ps}
