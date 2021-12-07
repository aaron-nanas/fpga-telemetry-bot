onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib telemetry_bot_opt

do {wave.do}

view wave
view structure
view signals

do {telemetry_bot.udo}

run -all

quit -force
