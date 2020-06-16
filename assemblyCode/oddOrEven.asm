j main

check:	andi $a1, $a0, 1
	addi $a0, $zero, 1
	syscall
	jr $ra
	

main:	addi $t0, $zero, 6
	sw $t0, 0($zero)
	addi $t0, $zero, 9
	sw $t0, 4($zero)
	addi $t0, $zero, 5
	sw $t0, 8($zero)
	addi $t0, $zero, 26
	sw $t0, 12($zero)
	addi $t0, $zero, 108
	sw $t0, 16($zero)
	lw $a0, 0($zero)
	jal check
	lw $a0, 4($zero)
	jal check
	lw $a0, 8($zero)
	jal check
	lw $a0, 12($zero)
	jal check
	lw $a0, 16($zero)
	jal check
	nop