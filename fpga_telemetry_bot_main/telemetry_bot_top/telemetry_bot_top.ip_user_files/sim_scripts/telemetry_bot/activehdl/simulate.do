onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+telemetry_bot -L xilinx_vip -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.telemetry_bot xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {telemetry_bot.udo}

run -all

endsim

quit -force
