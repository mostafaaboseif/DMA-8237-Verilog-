rst
rstb
strtdma
rdemand
lbus  $MODE0, 16
lbus  $MODE0, 17
lbus  $CAR0, 1
lbus  $CAR0, 0
lbus $CAR1, 7
lbus $CAR1, 0
lbus $CCR1, 6
lbus $CCR1, 0
lbus $COMMAND, 1
endma
dreq 1

j main

calcFib:	addi $sp, $sp, -12
	sw $s0 , 8($sp)
	sw $s1 , 4($sp)
	sw $s2 , 0($sp)
	add $v0, $a2, $a3
	lw $s0 , 8($sp)
	lw $s1 , 4($sp)
	lw $s2 , 0($sp)
	addi $sp, $sp, 12	
	jr $ra
print:	addi $a0, $zero, 1
	add $a1, $s2, $zero
	syscall
	jr $ra

main:	addi $s0, $zero, 0
	addi $t0, $zero, 2
	addi $s1, $zero, 0	
	addi $s2, $zero, 1
loop:	add $a2, $s1, $zero
	add $a3, $s2, $zero
	jal calcFib
	addi $s1, $s2, 0	
	addi $s2, $v0, 0
	jal print
	addi $s0, $s0, 1
	bne $s0, $t0, loop
	addi $1, $0, 500
	sw $1, 0($sp)
	
sdemand
