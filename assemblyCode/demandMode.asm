rst
rstb
strtdma
lbus $MODE0, 144
lbus $CAR0, 2
lbus $CAR0, 0
lbus $CCR0, 5
lbus $CCR0, 0
lbus $COMMAND, 0
memio
endma
dreq 1

nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop




laddri 14
ldata $a1
smemw
rmemw