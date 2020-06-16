main:	addi	$s0,$zero,2
	addi	$s1,$zero,3
	addi	$a0,$s0,0
	addi 	$a1,$s1,0
	jal	mul
	addi	$s1,$v0,0
	jal 	print
	j 	finish 

print:	addi $a0, $zero, 1
	add $a1, $s1, $zero
	syscall
	jr $ra

mul:
	addi $sp,$sp,-4
	sw $s0,0($sp)
	addi $sp,$sp,-4
	sw $s1,0($sp)
	addi $t0,$a0,0
	addi $v0,$zero,0

start:
	beq $t0,$zero,exit
	add $v0,$v0,$a1
	addi $t0,$t0,-1
	j start

exit:
	lw $s1,0($sp)
	addi $sp,$sp,4
	lw $s0,0($sp)
	addi $sp,$sp,4
	jr $ra

finish: