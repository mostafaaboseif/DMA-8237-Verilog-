
addi $t0 , $0 , 0  
addi $t1, $0 , 3 

loop1:	 beq $t0 , $t1 , finish
	sll $t3, $t0, 2 
	add $s1, $s0, $t0
	sw $t3, 0($s1)
	addi $t0, $t0 ,1 
	j loop1

finish:	add $t0 , $0 , $0
	addi $t4 , $0, 0
loop2:	beq $t0, $t1 , finish2 
	add $s1, $s0, $t0
	lw $t5,0($s1)
	add $t4, $t4, $t5
	addi $t0 , $t0 ,1
	j loop2
finish2: 	addi $a0 , $t4 , 0
