rst
rstb
strtdma
lbus $MODE0, 80
lbus $MODE0, 81
lbus $CAR0, 3
lbus $CAR0, 0
lbus $CAR1, 10
lbus $CAR1, 0
lbus $CCR1, 5
lbus $CCR1, 0
lbus $COMMAND, 1
endma
dreq 1

j main

mul:	add $t0, $zero, $zero
	add $v0, $zero, $zero
loop:	add $v0, $v0, $a0
	addi $t0, $t0, 1
	bne $t0, $a1, loop
	jr $ra 

print:	addi $a0, $zero, 1
	add $a1, $v0, $zero
	syscall
	jr $ra
	

main:	addi $s0, $zero, 7
	addi $s1, $zero, 1
	addi $a0, $zero, 1
	addi $a1, $zero, 1
fact:	jal mul
	jal print
	sw $v0, 0($s0) 
	add $a0, $zero, $v0
	addi $s1, $s1, 1
	add $a1, $s1, $zero
	addi $s0, $s0, -1
	bne $s0, $zero, fact
