	/* NOTE: this is hard-coded for x86-64; I don't know enough
	assembly to make this nice and use system headers, etc. */
	.file "null.s"
	.text
	.globl _start

_start:
        mov     $60, %eax
	xor	%rdx, %rdx
	syscall
