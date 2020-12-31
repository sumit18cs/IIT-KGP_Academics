	.file	"ass1b_18CS30042.c" # source file name 
	.text
	.section	.rodata         # read only data section 
	.align 8             	    # align with 8-byte boundary 
.LC0:                           
	.string	"\nGCD of %d, %d, %d and %d is: %d"     # Label of string printf 
	.text						# Code starts 
	.globl	main                # main is a global name 
	.type	main, @function		# main is a function: 
main:							# main: starts 
.LFB0:
	.cfi_startproc              # It initializes some internal data structures and emits architecture dependent initial CFI instructions 
	endbr64						# End Branch 64 bit or more precisely it terminate Indirect Branch in 64 bit 
	pushq	%rbp 				# Set up a new stack frame and pushq %rbp pushes the base pointer onto the stack 
	.cfi_def_cfa_offset 16		# cfi directives 
	.cfi_offset 6, -16			# cfi directives 
	movq	%rsp, %rbp			# rbp<--rsp, moves the base pointer to the stack pointer 
	.cfi_def_cfa_register 6		# cfi directives 
	subq	$32, %rsp           # %rsp is the stack pointer. This line is creating a new function call frame that of size 32 bytes which ultimately create space for local arrays and variables 
	movl	$45, -20(%rbp)		# -20(%rbp) declare for a, assign a=45 
	movl	$99, -16(%rbp)		# -16(%rbp) declare for b, assign b=99 
	movl	$18, -12(%rbp)		# -12(%rbp) declare for c, assign c=18 
	movl	$180, -8(%rbp)		# -8(%rbp) declare for d, assign d=180 
	movl	-8(%rbp), %ecx		# assign ecx=d which is 4th parameter for GCD4 
	movl	-12(%rbp), %edx		# assign edx=c which is 3rd parameter for GCD4 
	movl	-16(%rbp), %esi		# assign esi=b which is 2nd parameter for GCD4 
	movl	-20(%rbp), %eax		# assign eax=a which is 1st parameter for GCD4 
	movl	%eax, %edi 			# assign edi=eax 
	call	GCD4 				# Call funtion GCD4 
	movl	%eax, -4(%rbp) 		# -4(%rbp) declare for result which is return value of function GCD4, assign result=eax 
	movl	-4(%rbp), %edi 		# assign edi=result 
	movl	-8(%rbp), %esi		# assign esi=d 
	movl	-12(%rbp), %ecx 	# assign ecx=c 
	movl	-16(%rbp), %edx		# assign edx=b 
	movl	-20(%rbp), %eax		# assign eax=a 
	movl	%edi, %r9d			# assign r9d=result 
	movl	%esi, %r8d 			# assign r8d=d 
	movl	%eax, %esi			# assign esi=a 
	leaq	.LC0(%rip), %rdi 	# rdi<-- 1st parameter of printf 
	movl	$0, %eax 			# assign eax=0 
	call	printf@PLT 			# call printf 
	movl	$10, %edi			# assign edi=10 
	call	putchar@PLT 		# call putchar for printf 
	movl	$0, %eax 			# assign eax=0 
	leave						# remove stack frame 
	.cfi_def_cfa 7, 8			# cfi directives 
	ret 						# return 
	.cfi_endproc				# cfi directives 
.LFE0:
	.size	main, .-main        
	.globl	GCD4                # GCD4 is a global name 
	.type	GCD4, @function		# GCD4 is a function: 
GCD4:							# GCD4: starts 
.LFB1:
	.cfi_startproc				# cfi directives 
	endbr64						# End Branch 64 bit or more precisely it terminate Indirect Branch in 64 bit 
	pushq	%rbp				# Set up a new stack frame and pushq %rbp pushes the base pointer onto the stack 
	.cfi_def_cfa_offset 16		# cfi directives 
	.cfi_offset 6, -16			# cfi directives 
	movq	%rsp, %rbp			# rbp<--rsp, moves the base pointer to the stack pointer 
	.cfi_def_cfa_register 6		# cfi directives 
	subq	$32, %rsp           # %rsp is the stack pointer. This line is creating a new function call frame that of size 32 bytes which ultimately create space for local arrays and variables 
	movl	%edi, -20(%rbp)  	# -20(%rbp) declare for n1, assign n1=edi 
	movl	%esi, -24(%rbp)		# -24(%rbp) declare for n2, assign n2=esi 
	movl	%edx, -28(%rbp)		# -28(%rbp) declare for n3, assign n3=edx 
	movl	%ecx, -32(%rbp)		# -32(%rbp) declare for n4, assign n4=ecx 
	movl	-24(%rbp), %edx  	# assign edx=n2 
	movl	-20(%rbp), %eax		# assign eax=n1 
	movl	%edx, %esi			# assign esi=edx which is 1st parameter for GCD 
	movl	%eax, %edi			# assign edi=eax which is 2nd parameter for GCD 
	call	GCD 				# call function GCD 
	movl	%eax, -12(%rbp)     # -12(%rbp) declare for result which is return value of function GCD, assign t1=eax 
	movl	-32(%rbp), %edx 	# assign edx=n4 
	movl	-28(%rbp), %eax 	# assign eax=n3 
	movl	%edx, %esi 			# assign esi=edx which is 1st parameter for GCD  
	movl	%eax, %edi 			# assign edi=eax which is 2nd parameter for GCD 
	call	GCD 				# call funtion GCD 
	movl	%eax, -8(%rbp) 		# -8(%rbp) declare for result which is return value of function GCD4, assign t2=eax 
	movl	-8(%rbp), %edx   	# assign edx=t2 
	movl	-12(%rbp), %eax 	# assign eax=t1 
	movl	%edx, %esi			# assign esi=edx which is 1st parameter for GCD  
	movl	%eax, %edi 			# assign edi=eax which is 2nd parameter for GCD 
	call	GCD 				# call function GCD 
	movl	%eax, -4(%rbp)		# -4(%rbp) declare for result which is return value of function GCD4, assign t3=eax 
	movl	-4(%rbp), %eax 		# assign eax=t3 
	leave 						# remove stack frame 
	.cfi_def_cfa 7, 8			# cfi directives 
	ret 						# return 
	.cfi_endproc				# cfi directives 
.LFE1:
	.size	GCD4, .-GCD4
	.globl	GCD                 # GCD is a global name 
	.type	GCD, @function      # GCD is a function: 
GCD: 							# GCD: starts 
.LFB2:
	.cfi_startproc				# cfi directives 
	endbr64						# End Branch 64 bit or more precisely it terminate Indirect Branch in 64 bit 
	pushq	%rbp				# Set up a new stack frame and pushq %rbp pushes the base pointer onto the stack 
	.cfi_def_cfa_offset 16		# cfi directives 
	.cfi_offset 6, -16			# cfi directives 
	movq	%rsp, %rbp			# rbp<--rsp, moves the base pointer to the stack pointer 
	.cfi_def_cfa_register 6		# cfi directives 
	movl	%edi, -20(%rbp) 	# -20(%rbp) declare for num1, assign num1=edi 
	movl	%esi, -24(%rbp)  	# -24(%rbp) declare for num2, assign num2=esi 
	jmp	.L6						# jump to .L6, since jmp indicates unconditional and always jump situation 
.L7:
	movl	-20(%rbp), %eax  	# assign eax=M[rbp-20] 
	cltd						# converts signed long to signed double long 
	idivl	-24(%rbp) 			# assign edx=eax%M[rbp-24] 
	movl	%edx, -4(%rbp) 		# M[rbp-4]=edx 
	movl	-24(%rbp), %eax		# assign eax=M[rbp-24] 
	movl	%eax, -20(%rbp) 	# M[rbp-20]=eax 
	movl	-4(%rbp), %eax 		# assign eax=M[rbp-4] 
	movl	%eax, -24(%rbp)		# M[rbp-24]=eax 
.L6:
	movl	-20(%rbp), %eax    	# assign eax=num1 
	cltd 						# converts signed long to signed double long 
	idivl	-24(%rbp) 			# assign edx=eax%M[rbp-24] 
	movl	%edx, %eax          # assign eax=edx  
	testl	%eax, %eax			# check whether eax is zero or not 
	jne	.L7 					# jump to L7 when eax is not zero 
	movl	-24(%rbp), %eax 	# assign eax=M[rbp-24] , which contain result 
	popq	%rbp 				# remove base stack pointer, free the register 
	.cfi_def_cfa 7, 8			# cfi directives 
	ret 						# return 
	.cfi_endproc				# cfi directives 
.LFE2:
	.size	GCD, .-GCD
	.ident	"GCC: (Ubuntu 9.3.0-10ubuntu2) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
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
