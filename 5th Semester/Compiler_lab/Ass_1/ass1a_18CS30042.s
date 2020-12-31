	.file	"ass1a_18CS30042.c" # source file name 
	.text
	.section	.rodata 		# read only data section 
.LC0:							
	.string	"\nThe greater number is: %d"     # Label of string printf 
	.text						# Code starts 
	.globl	main                # main is a global name 
	.type	main, @function		# main is a function: 
main:							# main: starts 
.LFB0:
	.cfi_startproc 			    # It initializes some internal data structures and emits architecture dependent initial CFI instructions 
	endbr64                		# End Branch 64 bit or more precisely it terminate Indirect Branch in 64 bit 
	pushq	%rbp             	# Set up a new stack frame and pushq %rbp pushes the base pointer onto the stack 
	.cfi_def_cfa_offset 16		# cfi directives 
	.cfi_offset 6, -16			# cfi directives 
	movq	%rsp, %rbp       	# rbp<--rsp, moves the base pointer to the stack pointer 
	.cfi_def_cfa_register 6		# cfi directives 
	subq	$16, %rsp     		# %rsp is the stack pointer. This line is creating a new function call frame that of size 16 bytes which ultimately create space for local arrays and variables 
	movl	$45, -8(%rbp)   	# -8(%rbp) declare for num1, assign num1=45 
	movl	$68, -4(%rbp)   	# -4(%rbp) declare for num2, assign num2=68 
	movl	-8(%rbp), %eax		# assign eax = num1 
	cmpl	-4(%rbp), %eax      # compare eax with num2 
	jle	.L2 					# if(num2>eax) jump to .L2 
	movl	-8(%rbp), %eax      # assign eax=num1 
	movl	%eax, -12(%rbp)     # -12(%rbp) declare for greater, assign greater=eax 
	jmp	.L3 					# jump to .L3, since jmp indicates unconditional and always jump situation 
.L2:
	movl	-4(%rbp), %eax		# assign eax=num2 
	movl	%eax, -12(%rbp)		# assign greater=eax 
.L3:
	movl	-12(%rbp), %eax		# assign eax=greater 
	movl	%eax, %esi			# esi<--eax (2nd parameter) 
	leaq	.LC0(%rip), %rdi    # rdi<-- 1st parameter of printf 
	movl	$0, %eax            # assign eax=0 
	call	printf@PLT 			# call printf 
	movl	$0, %eax            # assign eax=0 
	leave						# remove stack frame 
	.cfi_def_cfa 7, 8			# cfi directives 
	ret 						# return 
	.cfi_endproc				# cfi directives 
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.3.0-10ubuntu2) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8					# align with 8-byte boundary 
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
