onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib cpuram_opt

do {wave.do}

view wave
view structure
view signals

do {cpuram.udo}

run -all

quit -force
