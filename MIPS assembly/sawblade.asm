.data
	
period:	.asciiz "."
nl:	.asciiz "\n"
space:	.asciiz " "

.text

##Draws a saw blade that is height tall and has num peaks
##CS 214 2025
##Main

#read int height into $t0
	li $v0, 5
	syscall
	add $t0, $v0, $zero
	
#read int num into $t1
	li $v0, 5
	syscall
	add $t1, $v0, $zero
	
	## int I = 0
	li $t2, 0
	
loopA:	bge $t2, $t0, endA
	
	## new int rest = height - i
	sub $t3, $t0, $t2	
	## int J = 0
	li $t4, 0
	
loopB:	bge $t4, $t1, endB
	
	##Print Period##
	li $v0, 4
	la $a0, period
	syscall
	## int K = 0 
	li $t5, 0
	
loopC:	bge $t5, $t2, endC
	##Print Space##
	li $v0, 4
	la $a0, space
	##K++
	addi $t5, $t5, 1
	syscall

	##exit loop
	b loopC
endC:	#Print Period##
	li $v0, 4
	la $a0, period
	syscall
	## int K = 0
	li $t5, 0

loopD:	bge $t5, $t3, endD
	##Print Space##
	li $v0, 4
	la $a0, space
	syscall
	
	##K++
	addi $t5, $t5, 1
	b loopD
endD:	##J++
	addi $t4, $t4, 1
	
	b loopB
endB:	##Print newline
	li $v0, 4
	la $a0, nl
	syscall
	## i++
	addi $t2, $t2, 1
	b loopA
	
endA:	#exit system call
	addi $v0, $zero, 10
	syscall
	