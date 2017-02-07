onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk_i
add wave -noupdate /tb/srst_i
add wave -noupdate /tb/sop_i
add wave -noupdate /tb/eop_i
add wave -noupdate /tb/val_i
add wave -noupdate /tb/data_i
add wave -noupdate /tb/sop_o
add wave -noupdate /tb/eop_o
add wave -noupdate /tb/val_o
add wave -noupdate /tb/data_o
add wave -noupdate /tb/busy_o
add wave -noupdate -radix unsigned -childformat {{{/tb/i_sorting/mem[7]} -radix unsigned} {{/tb/i_sorting/mem[6]} -radix unsigned} {{/tb/i_sorting/mem[5]} -radix unsigned} {{/tb/i_sorting/mem[4]} -radix unsigned} {{/tb/i_sorting/mem[3]} -radix unsigned} {{/tb/i_sorting/mem[2]} -radix unsigned} {{/tb/i_sorting/mem[1]} -radix unsigned} {{/tb/i_sorting/mem[0]} -radix unsigned}} -expand -subitemconfig {{/tb/i_sorting/mem[7]} {-radix unsigned} {/tb/i_sorting/mem[6]} {-radix unsigned} {/tb/i_sorting/mem[5]} {-radix unsigned} {/tb/i_sorting/mem[4]} {-radix unsigned} {/tb/i_sorting/mem[3]} {-radix unsigned} {/tb/i_sorting/mem[2]} {-radix unsigned} {/tb/i_sorting/mem[1]} {-radix unsigned} {/tb/i_sorting/mem[0]} {-radix unsigned}} /tb/i_sorting/mem
add wave -noupdate /tb/i_sorting/state
add wave -noupdate /tb/i_sorting/state_next
add wave -noupdate -radix unsigned /tb/i_sorting/write_ptr
add wave -noupdate -radix unsigned /tb/i_sorting/write_ptr_new
add wave -noupdate -radix unsigned /tb/i_sorting/input_words_count
add wave -noupdate /tb/i_sorting/sorting_ok
add wave -noupdate -radix unsigned /tb/i_sorting/min_sorted_addr
add wave -noupdate -radix unsigned /tb/i_sorting/max_sorted_addr
add wave -noupdate -color {Cornflower Blue} -radix unsigned /tb/i_sorting/max_read_ptr
add wave -noupdate -color {Cornflower Blue} -radix unsigned /tb/i_sorting/min_read_ptr
add wave -noupdate -color Violet -radix unsigned /tb/i_sorting/min_read_data
add wave -noupdate -color Violet -radix unsigned /tb/i_sorting/max_read_data
add wave -noupdate /tb/i_sorting/data_swap
add wave -noupdate -radix unsigned /tb/i_sorting/min_write_data
add wave -noupdate -radix unsigned /tb/i_sorting/max_write_data
add wave -noupdate -radix unsigned /tb/i_sorting/read_ptr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1201 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 92
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
configure wave -timelineunits ps
update
WaveRestoreZoom {862 ps} {1870 ps}
