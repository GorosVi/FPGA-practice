onerror {resume}
quietly WaveActivateNextPane {} 0
delete wave *

transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/Metrotek/Labs/B3_sorting/rtl {D:/Metrotek/Labs/B3_sorting/rtl/mem_core.sv}
vlog -sv -work work +incdir+D:/Metrotek/Labs/B3_sorting/rtl {D:/Metrotek/Labs/B3_sorting/rtl/sorting.sv}
vlog -sv -work work +incdir+D:/Metrotek/Labs/B3_sorting/quartus {D:/Metrotek/Labs/B3_sorting/quartus/TOP.sv}

vlog -sv -work work +incdir+D:/Metrotek/Labs/B3_sorting/quartus/../tb {D:/Metrotek/Labs/B3_sorting/quartus/../tb/tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb

do wave.do

update
view structure
view signals
run -all