onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk_i
add wave -noupdate /tb/srst_i
add wave -noupdate /tb/wrreq_i
add wave -noupdate /tb/rdreq_i
add wave -noupdate -color {Orange Red} -radix hexadecimal /tb/data_i
add wave -noupdate -color {Orange Red} -radix hexadecimal /tb/q_o
add wave -noupdate /tb/empty_o
add wave -noupdate /tb/full_o
add wave -noupdate -radix unsigned /tb/usedw_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1350 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {600 ps} {2100 ps}
