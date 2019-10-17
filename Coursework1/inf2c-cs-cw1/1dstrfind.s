
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 

grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *

.align 2
dictionary_idx:		.space 4000                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!
 
	move $t0, $0 # int dict_idx = 0
	move $t1, $0 # int start_idx = 0
 	move $s7, $0 # int dict_num_words = 0
 
 # storing starting index of each word in the dictionary
 	move $t2, $0 # idx = 0
 	
 INDEX_DICT_LOOP:
 	la $t3, dictionary($t2)	# c_input = dictionary[idx]
 	lb $t4, 0($t3) # Load address into t3 first, then load byte from address into t4
 	beqz $t4, AFTER_DICT # if (c_input == '\0'), then break
 	lb $t9, newline # Load newline character for comparison
 	beq $t4, $t9, INDEX_DICT # if (c_input == '\n'), then go INDEX_DICT
 RESUME_DICT_LOOP:
  	addi $t2, $t2, 1 # idx += 1
  	j INDEX_DICT_LOOP
 
 INDEX_DICT:
 	addi $t0, $t0, 1 # Increment dict_idx
 	add $t6, $t0, $t0 # Double and double again dict_idx to get multiple of 4
 	add $t6, $t6, $t6 # this is for the alignment of the array 
 	la $t9, dictionary_idx($0) # Load the address of the start of the dictionary_index
 	add $t9, $t9, $t6 # add the aligned dict_idx to the base of the array
 	sw $t1, ($t9) # store start_idx in next location of array
 	
# 	li  $v0, 1        
#   	move $a0, $t1  # load desired value into argument register $a0, using pseudo-op
#  	syscall
   	
#    	li $v0, 11
#    	addi $a0, $0, 32
#    	syscall
 	
 	addi $t1, $t2, 1 # start_idx = idx + 1
 	j RESUME_DICT_LOOP
 	
 AFTER_DICT:
 	move $s7, $t0 # dict_num_words = dict_idx
 	#addi $sp,$sp,-4 # POP
	#sw $ra,0($sp)
	
 	jal strfind
 	
 	#lw $ra,0($sp)
 	#addi $sp, $sp, 4 # PUSH back on
 
#-----------------------------------------------------------------
# My Functions
#----------------------------------------------------------------- 
				
 strfind:
 	move $t0, $0 # int idx = 0
 	move $t1, $0 # int grid_idx = 0
 	# Let t3 be word pointer
 FOR_EACH_DICT_WORD:
	lw $t3, dictionary_idx($t0) # load value of dictionary index at index
	#add $t3, $t3, $t3 # align the index correctly for the dictionary
	#add $t3, $t3, $t3 # by x2 x2, for 4
	la $t4, dictionary # load dictionary
	add $t3, $t3, $t4 # word = dictionary + dictionary_idx[idx]
	move $s6, $t3 # safely store the word ADDRESS in s6
	la $t3, grid # load grid
	add $t3, $t3, $t1 # store grid word address
	move $s5, $t3 # put grid word ADDRESS into s5
	
	addi $sp,$sp,-4 # POP
	sw $ra,0($sp)
	
	jal contain
	
	lw $ra,0($sp)
 	addi $sp, $sp, 4 # PUSH back on
	
	addi $t0, $t0, 4 # increase the dictionary index
	bge $t0, $s7, CHANGE_GRID_WORD # if iterated through dictionary, go to next grid word
	beqz $v1, FOR_EACH_DICT_WORD # if dictionary not match with grid word, try next dictionary
	beq $v1, 1, FOUND_WORD

CHANGE_GRID_WORD:
	addi $t1, $t1, 1
	j FOR_EACH_DICT_WORD	
	
FOUND_WORD:	
	li  $v0, 1    # found it!    
    	move $a0, $t1  #print id number
    	syscall
    	
    	li  $v0, 11    # found it!    
    	addi $a0, $0, 32  #print space
    	syscall
    	
    	li  $v0, 1    # found it!    
    	lw $a0, ($s6)  #print word
    	syscall
	
	j END

 contain:
 	# set v1 to 1 if does contain
 CONTAIN_LOOP:
 	lb $t9, ($s6) # store character of word in t9
 	lb $t8, ($s5) # store character of grid in t8
 	
 	beqz $t8, END # IF REACHED THE END OF THE GRID, END PROGRAM
 	
	bne $t9, $t8 IF_CHARACTERS_NOT_EQUAL # if (*string != *word)
	addi $s6, $s6, 1 # increase word character pointer
	addi $s5, $s5, 1 # increase string character pointer
	j CONTAIN_LOOP
	
 IF_CHARACTERS_NOT_EQUAL:
	lb $t7, newline # Load newline character for comparison
	beq $t9, $t7, SET_V1_1 # *word == '\n'
	bne $t9, $t7, SET_V1_0 # *word != '\n'
 SET_V1_1:
 	addi $v1, $0, 1 # if *word is new line then return 1
	jr $ra
 SET_V1_0:
 	add $v1, $0, $0 # if word is not new line then return 0
	jr $ra


 	
 
 	
END: 	
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
