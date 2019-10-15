transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/Ruslan/Desktop/08.10.19/stripes/IMAGE_SENSOR_SIM_binar.vhd}
vcom -93 -work work {C:/Users/Ruslan/Desktop/08.10.19/stripes/Checker.vhd}
vcom -93 -work work {C:/Users/Ruslan/Desktop/08.10.19/stripes/count_n_modul.vhd}

vcom -93 -work work {C:/Users/Ruslan/Desktop/08.10.19/stripes/simulation/modelsim/IMAGE_SENSOR_SIM.vht}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneive -L rtl_work -L work -voptargs="+acc"  IMAGE_SENSOR_SIM_vhd_tst

add wave *
view structure
view signals
run -all
