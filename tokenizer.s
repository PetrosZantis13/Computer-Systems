
#=========================================================================
# Tokenizer
#=========================================================================
# Split a string into alphabetic, punctuation and space tokens
# 
# Inf2C Computer Systems
# 
# Petros Zantis
# Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"   
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL

# You can add your data here!

        
tokens:                  .space 411849   #tokens[2049][201]
tokens_number:           .byte                                 
                                                
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
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

# reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_file);
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  content($t0)

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

# You can add your code here!

tokenizer: 	 	
        li   $t0 , 0     # int c_idx = 0;
        li   $t1 , 0     #int tokens_number = 0;
                			         			 
splitLoop:    
        lb   $s3, content($t0)           #c = content[c_idx];
        beqz  $s3 , main_end         #end of content : if(c == '\0'){ break }
        
        slti $t2, $s3, 65    
        beqz  $t2, isAlpha   #if the token starts with an alphabetic character 
        
        li   $t9 , 32              #ASCII value for ' '
        beq  $s3, $t9 , isSpace    #else if(c == ' ') {
    
        j isPunct          #else if the token starts with one of punctuation marks
isAlpha:
        li   $t2 , 0             #int token_c_idx = 0; 
isAlphaLoop:       
        mul  $t4, $t1, 201      #because maximum token length is 200 (+1 for null character at end)
        add  $t4 , $t2, $t4     #position of c in the token.  [token_c_idx];
        sb   $s3, tokens($t4)   #tokens[tokens_number][token_c_idx] = c;
        addi $t2 , $t2 , 1       #token_c_idx += 1;
        addi $t0, $t0 ,1         #c_idx += 1;
        li   $v0, 11             # print the char c ;
        la   $a0, ($s3)           
        syscall
        lb   $s3, content($t0)     #c = content[c_idx];
        slti $t2, $s3, 65    
        beqz  $t2, isAlphaLoop       #while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z'); 
        sb   $0 , tokens($t4)        #tokens[tokens_number][token_c_idx] = '\0';
        addi $t1 , $t1 , 1           #tokens_number += 1;
        j printNewLine
        
isSpace: 
        li   $t2 , 0             #int token_c_idx = 0;        
isSpaceLoop:
        mul  $t4, $t1, 201      #because maximum token length is 200 (+1 for null character at end)
        add  $t4 , $t2, $t4     #position of c in the token.  [token_c_idx];
        sb   $s3, tokens($t4)    #tokens[tokens_number][token_c_idx] = c;
        addi $t2 , $t2 , 1       #token_c_idx += 1;
        addi $t0, $t0 ,1         #c_idx += 1;
        li   $v0, 11             # print the char c ;
        la   $a0, ($s3)
        syscall
        lb   $s3, content($t0)        #c = content[c_idx];
        li   $t9 , 32      
        beq  $s3, $t9 , isSpaceLoop      #while(c == ' ');
        sb   $0 , tokens($t4)        #tokens[tokens_number][token_c_idx] = '\0';
        addi $t1 , $t1 , 1           #tokens_number += 1;
        j printNewLine
       
isPunct:
        li   $t2 , 0             #int token_c_idx = 0;        
isPunctLoop:
        mul  $t4, $t1, 201      #because maximum token length is 200 (+1 for null character at end)
        add  $t4 , $t2, $t4     #position of c in the token.  [token_c_idx];
        sb   $s3, tokens($t4)    #tokens[tokens_number][token_c_idx] = c;
        addi $t2 , $t2 , 1       #token_c_idx += 1;
        addi $t0, $t0 ,1         #c_idx += 1;
        li   $v0, 11             # print the char c ;
        la   $a0, ($s3)
        syscall
        lb   $s3, content($t0)        #c = content[c_idx];
        li , $t5, 44                  #ASCII value for ','
        li , $t6, 46                  #ASCII value for '.' 
        li , $t7, 33                  #ASCII value for '!'
        li , $t8, 63                  #ASCII value for '?'
        beq  $s3, $t5, isPunctLoop      #while(c == ',' || c == '.' || c == '!' || c == '?');
        beq  $s3, $t6, isPunctLoop
        beq  $s3, $t7, isPunctLoop
        beq  $s3, $t8, isPunctLoop
        sb   $0 , tokens($t4)        #tokens[tokens_number][token_c_idx] = '\0';
        addi $t1 , $t1 , 1           #tokens_number += 1;
	j printNewLine

printNewLine: 				        
        li   $v0, 4           # print string("\n");
        la   $a0, newline
        syscall
        j splitLoop
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
