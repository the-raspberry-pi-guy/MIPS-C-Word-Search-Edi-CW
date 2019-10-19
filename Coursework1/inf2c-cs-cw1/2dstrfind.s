
#=========================================================================
# 2D String Finder HORIZONTAL, VERTICAL & DIAGONAL
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
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

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
# You can add your data here!
.align 2                                # The next field will be aligned with 2
dictionary_idx:		.space 4000     # int dictionary_idx[MAX_DICTIONARY WORDS]
                                        # MAX_DICTIONARY_WORDS = 1000, integer takes 4 bytes, hence 4000
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

#------------------------------------------------------------------
# MAIN FUNCTION
#------------------------------------------------------------------

# You can add your code here!
 
        move $t0, $0                    # int dict_idx = 0
        move $t1, $0                    # int start_idx = 0
        move $s0, $0                    # int dict_num_words = 0
                                        # To keep track of total number of words in dictionary
        addi $s1, $0, 1 # int number_of_rows =1
        move $s2, $0 # int number_of_cols = 0
        move $s3, $0 # int found = 0
 
 # storing starting index of each word in the dictionary
        move $t2, $0                    # idx = 0
 	
INDEX_DICT_LOOP:
        la $t3, dictionary($t2)	        # c_input = dictionary[idx]
        lb $t4, 0($t3)                  # Load address into t3 first, then load byte from address into t4
        beqz $t4, AFTER_DICT            # if (c_input == '\0'), then break out of loop (to AFTER_DICT)
        beq $t4, '\n', INDEX_DICT       # if (c_input == '\n'), then go to INDEX_DICT
RESUME_DICT_LOOP:
        addi $t2, $t2, 1                # idx += 1
        j INDEX_DICT_LOOP               # do while(1) loop

INDEX_DICT:
        addi $t0, $t0, 1                # [dict_idx ++] - increment dict_idx
        sll $t6, $t0, 2                 # Multiply dict_idx by 4 to be word aligned
        la $t9, dictionary_idx($0)      # Load the address of the start of the dictionary_index
        add $t9, $t9, $t6               # Add the aligned dict_idx to the base of the array
        sw $t1, ($t9)                   # dictionary_idx[dict_idx ++] = start_idx - store start_idx in next location of array
        addi $t1, $t2, 1                # start_idx = idx + 1
        j RESUME_DICT_LOOP              # Resume the indexing loop

AFTER_DICT:
        move $s0, $t0                   # dict_num_words = dict_idx - store total dictionary words
        move $t0, $0 # int i = 0
        move $t1, $0 # int j = 0
        
COL_CALC_LOOP:        
        la $t2, grid
        add $t2, $t2, $t0
        lb $t2, ($t2)
        beq $t2, '\n', FINISH_COL_CALC
        addi $s2, $s2, 1
        addi $t0, $t0, 1
        j COL_CALC_LOOP
FINISH_COL_CALC:

ROW_CALC_LOOP:
        la $t2, grid
        add $t2, $t2, $t1
        lb $t2, ($t2)
        beqz $t2, FINISH_ROW_CALC
        beq $t2, '\n', INCREMENT_ROW
        addi $t1, $t1, 1
        j ROW_CALC_LOOP
INCREMENT_ROW:
        addi $s1, $s1, 1
        addi $t1, $t1, 1
        j ROW_CALC_LOOP
   
FINISH_ROW_CALC:     
        jal strfind                     # strfind() - jump to the strfind() procedure 
 	
 
#------------------------------------------------------------------
# STRFIND FUNCTION - find all matching dictionary words in a string
#------------------------------------------------------------------ 
				
strfind:
        move $t0, $0                    # int idx = 0
        move $t1, $0                    # int grid_idx = 0
 	# Let t3 be dictionary word pointer, equivalent to char *word
 	
FOR_EACH_DICT_WORD:                     # for(idx = 0; idx < dict_num_words; idx ++) - label for this purpose
        sll $t2, $s0, 2                 # Multiply total number of word in dictionary by 4
        bge  $t0, $t2, END              # If exhausted dictionary words, end for loop, branch to END for final checks on found variable
        
        addi $t0, $t0, 4                # Prepare next dictionary_word index for next loop NEXT TIME                                	                 	                                	                 
        move $t1, $0                    # Set grid_idx = 0, ready to be iterated through
        lw $t3, dictionary_idx($t0)     # Load dictionary index
        la $t4, dictionary              # Load address of base of dictionary
        add $s4, $t3, $t4               # dictionary_word = dictionary + dictionary_idx[idx]
        
WHILE_NOT_END_OF_GRID:                  # while(grid[grid_idx] != '\0')
        la $t5, grid                    # Load address of base of grid
        add $s5, $t5, $t1               # grid + grid_idx
        lb $t9, ($s5)                   # Load grid character to check if iterated through the entire grid yet
        beqz $t9, FOR_EACH_DICT_WORD    # If character is \0 then break to FOR_EACH_DICT_WORD, finishes while loop

        addi $sp,$sp,-4                 # POP the current address register to the stack
        sw $ra,0($sp)
        jal contain                     # if (contain(grid + grid_idx, word)) - call contain procedure on s5 and s6 registers
        lw $ra,0($sp)                   # PUSH back the previous address register to the stack
        addi $sp, $sp, 4

        beq $v1, 1, FOUND_WORD          # if (contain(grid + grid_idx,word) evaulates to true, ie: a word has been found, branch to FOUND_WORD
RESUME_NOT_END_OF_GRID:                 # Continue to find all the matches
        addi $t1, $t1, 1                # grid_idx++               
        j WHILE_NOT_END_OF_GRID         # Increase grid index and continue loop
	
FOUND_WORD:                             # if (contain(grid + grid_idx,word), do:
        li  $v0, 1                      # Set syscall to print integer  
        add $a0, $0, $t1                # Add grid_idx to be printed
        syscall                         # print_int(grid_idx)
        
        li  $v0, 11                     # Set syscall to print char   
        addi $a0, $0, 32                # Add ASCII for space to be printed
        syscall                         # print_char(' ')
        
        lw $a3, dictionary_idx($t0)     # Load the index number that the word was found into the a3 register for printing 
        addi $sp,$sp,-4                 # POP the current address register to the stack
        sw $ra,0($sp)
        jal print_dictionary_word       # print_word(word) - jump to print_dictionary_word function, taking a3 as input
        lw $ra,0($sp)                   # PUSH back the previous address register to the stack
        addi $sp, $sp, 4
        
        addi $a0, $0, 10                # Add ASCII for new line to be printed
        syscall                         # print_char('\n')
        
        addi $s3, $s3, 1                # found++ - Increment found to indicate at least one word has been found	               
        j RESUME_NOT_END_OF_GRID        # Loop back to continue searching through grid
	
#------------------------------------------------------------------
# CONTAIN FUNCTION
#------------------------------------------------------------------ 
 
contain:
        # function to see if the string contains the (\n terminated) word
        move $t9, $s4 # temporary copy of word pointer
	move $t8, $s5 # temporary copy of string pointer
CONTAIN_LOOP:
        lb $t7, ($t9)                   # *word - dereference pointer of dictionary word - store character of word in t9
        lb $t6, ($t8)                   # *string - dereference pointer of grid word - store character of string in t8
        
        bne $t7, $t6, IF_CHARACTERS_NOT_EQUAL # if (*string != *word)
        addi $t9, $t9, 1                # word++ increase word character pointer
        addi $t8, $t8, 1                # string++ increase string character pointer
        j CONTAIN_LOOP                  # while(1)
	
IF_CHARACTERS_NOT_EQUAL:
        bne $t7, '\n', SET_V1_0         # *word != '\n', break to SET_V1_0
        beq $t7, '\n', SET_V1_1         # *word == '\n', break to SET_V1_1
SET_V1_1:
        addi $v1, $0, 1                 # if *word is new line then return 1 (to v1 register)
        jr $ra                          # return - jump back to the return address in strfind
SET_V1_0:
        add $v1, $0, $0                 # if word is not new line then return 0 (to v1 register)
        jr $ra                          # return - jump back to the return address in strfind
 
#------------------------------------------------------------------
# PRINT_DICTIONARY_WORD FUNCTION
#------------------------------------------------------------------ 
 
print_dictionary_word:                  # void print_word(char *word)
 	# assuming the address of the dictionary word to be printed is in $a3
 	li  $v0, 11                     # Set syscall to print char   
    	move $a1, $a3                   # Move input address to a1
UNTIL_DONE:                             # while(*word != '\n' && *word != '\0')
        lb $a0, dictionary($a1)         # Load char of word to be printed
        syscall                         # print_char(*word)
        addi $a1, $a1, 1                # word++
        lb $t8, dictionary($a1)         # Temporary load of the char into memory to check if it is \n or \0
        beqz $t8, STOP_PRINTING_WORD    # Branch to STOP_PRINTING_WORD if char == \0
        beq $t8, '\n', STOP_PRINTING_WORD # Branch to STOP_PRINTING_WORD if char == \n
        j UNTIL_DONE                    # Continue while(*word != '\n' && *word != '\0')
STOP_PRINTING_WORD:
        jr $ra                          # Return to register address

END_WITH_FAILURE:                       # If no word is found then print out -1
        li $v0, 1                       # Set syscall to print integer  
        addi $a0, $0, -1                # Add -1 to be printed
        syscall                         # print_string("-1")
        li $v0, 4                       # Load to print char
        addi $a0, $0, 10                # print new line
        
END:
        beqz $s3, PRINT_MINUS1
        j main_end
        
PRINT_MINUS1:
        li  $v0, 1                      # Set syscall to print integer  
        add $a0, $0, -1                 # Add -1 to be printed
        syscall                         # print_string("-1")
        
        li  $v0, 11                     # Set syscall to print char   
        addi $a0, $0, 10                # print new line
        syscall 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
