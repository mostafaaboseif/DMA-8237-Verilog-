vsim work.aaaatb
add wave clk
add wave /aaaatb/dma/bus
add wave /aaaatb/dma/currentState
add wave /aaaatb/dma/nextState
add wave /aaaatb/arb/AEN
add wave /aaaatb/arb/reqP
add wave /aaaatb/arb/gntP
add wave /aaaatb/arb/reqD
add wave /aaaatb/arb/gntD
add wave /aaaatb/arb/reqR
add wave /aaaatb/arb/gntR
add wave /aaaatb/dma/DMA_IN
add wave /aaaatb/dma/MEMR
add wave /aaaatb/dma/MEMW
add wave /aaaatb/dma/READY
add wave /aaaatb/dma/car
add wave /aaaatb/dma/ccr
add wave /aaaatb/dma/temporary
run 1000
