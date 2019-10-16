.data

dictionary_idx:		.space 4000

.text

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
	la $t9, dictionary_idx
	addi $t0, $0, 1
	addi $t9, $t9, 0
	sw $t0, ($t9)
	
main_end:      
        li   $v0, 10          # exit()
        syscall