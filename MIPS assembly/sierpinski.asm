.data
	
period:	.asciiz "."
nl:	.asciiz "\n"
space:	.asciiz " "

.text

## draws a warped version of the Sierpinski triangle
## input value must be a power of 2

##################################################################
#
#     main

	
	#read int size into $a3/$s2
	li $v0, 5
	syscall
	add $s2, $v0, $zero
	add $a3, $s2, $zero #copy to arg #size
	
	#int y = size- 1 ($a1/s1)
	sub $s1, $a3, 1
	add $a1, $s1, $zero #copy to arg #y
	
	##While loop D (y>=0)
loopD:	blt $a1, 0, endD
	#declare x =0 ($a2/$s0)
	li $s0, 0	
	add $a2, $s0, $zero #copy to arg #x
	
	##While loop E (x < size)
loopE:	bge $a2, $a3, endE
		#period if (draw at ==1)
		jal drawAt
		bne $v0, 1, else
		#Print Period##
		li $v0, 4
		la $a0, period
		syscall
		b skip
		#space else
else:		##Print Space##
		li $v0, 4
		la $a0, space
		syscall
		
skip:		
		##increase x
		add $s0, $s0, 1
		
			#recast args
			add $a3, $s2, $zero #copy to arg #size
			add $a1, $s1, $zero #copy to arg #y
			add $a2, $s0, $zero #copy to arg #x

	b loopE
endE:	#end e
	##Print newline
	li $v0, 4
	la $a0, nl
	syscall
	
	
	#y decrease
	sub $s1, $s1, 1
	add $a1, $s1, $zero #copy to arg #y
	b loopD
endD:

#exit system call
	addi $v0, $zero, 10
	syscall

#################################################################
#
#       public int static drawAt(int x, int y,, int size)

drawAt:	addi	$sp, $sp, -20	#ALLOCATE MEMORY
	sw	$ra, ($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)

	#Cast args to s registers
	add $s0, $a2, $zero	#x
	add $s1, $a1, $zero	#y
	add $s2, $a3, $zero	#size

	##if size == 1
	beq $s2, 1, end
	#return 1
	
	#declare half
	div $s3, $s2, 2
	
	#A IF
	blt $s0, $s3, endA
		#B IF
		blt $s1, $s3, endB
			li $v0, 0	#return 0
			b return
endB:		##return drawAt
		sub $a2, $s0, $s3	#x - half
		add $a1, $s1, $zero	#y
		add $a3, $s3, $zero	#half
		jal drawAt
		b return
endA:	
	#C IF
	blt $s1, $s3, endC
		##return drawAt
		add $a2, $s0, $zero	#x
		sub $a1, $s1, $s3	#y-half
		add $a3, $s3, $zero	#half
		jal drawAt
		b return
endC:
	#last case
	#return drawAt
	add $a2, $s0, $zero	#x
	add $a1, $s1, $zero	#y
	add $a3, $s3, $zero	#half
	jal drawAt
	b return
	
##	Return
return:	lw	$ra, ($sp)	#RESOLVE MEMORY
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra

end:	li $v0, 1
	b return


