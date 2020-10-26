
#=========================================================================
# Punctuation checker 
#=========================================================================
# Marks misspelled words and punctuation errors in a sentence according to a dictionary
# and punctuation rules
#
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
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
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL

# You can add your data here!
tokens:                 .space 411849   #tokens[2049][201]
tokens_number:          .byte                                           
dictionary_words:       .space 200001        
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------
tokenizer: 	 	
        li   $t0 , 0     # int c_idx = 0;
        li   $s7 , 0     #int tokens_number = 0;
                			         			 
splitLoop:    
        lb   $s3, content($t0)           #c = content[c_idx];
        beqz  $s3 , tokenizerEnd    #end of content : if(c == '\0'){ break }
        
        slti $t2, $s3, 65    
        beqz  $t2, isAlpha   #if the token starts with an alphabetic character 
        
        li   $t9 , 32              #ASCII value for ' '
        beq  $s3, $t9 , isSpace    #else if(c == ' ') {
    
        j isPunct          #else if the token starts with one of punctuation marks
isAlpha:
        li   $t2 , 0             #int token_c_idx = 0; 
isAlphaLoop:       
        mul  $t4, $s7, 201      #because maximum token length is 200 (+1 for null character at end)
        add  $t4 , $t2, $t4     #position of c in the token.  [token_c_idx];        
        sb   $s3, tokens($t4)   #tokens[tokens_number][token_c_idx] = c;
        
        addi $t2 , $t2 , 1       #token_c_idx += 1;
        addi $t0, $t0 ,1         #c_idx += 1;
        
        lb   $s3, content($t0)     #c = content[c_idx];
        slti  $t8, $s3, 65    
        beqz  $t8, isAlphaLoop       #while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
        
        addi $t4 , $t4 , 1
        sb   $0 , tokens($t4)        #tokens[tokens_number][token_c_idx] = '\0';
        addi $s7 , $s7 , 1           #tokens_number += 1;
        j printNewLine
        
isSpace: 
        li   $t2 , 0             #int token_c_idx = 0;        
isSpaceLoop:
        mul  $t4, $s7, 201      #because maximum token length is 200 (+1 for null character at end)
        add  $t4 , $t2, $t4     #position of c in the token.  [token_c_idx];
        sb   $s3, tokens($t4)    #tokens[tokens_number][token_c_idx] = c;
        
        addi $t2 , $t2 , 1       #token_c_idx += 1;
        addi $t0, $t0 ,1         #c_idx += 1;
        
        lb   $s3, content($t0)        #c = content[c_idx];
        li   $t9 , 32      
        beq  $s3, $t9 , isSpaceLoop      #while(c == ' ');
        
        addi $t4 , $t4 , 1
        sb   $0 , tokens($t4)        #tokens[tokens_number][token_c_idx] = '\0';
        addi $s7 , $s7 , 1           #tokens_number += 1;
        j printNewLine
       
isPunct:
        li   $t2 , 0             #int token_c_idx = 0;        
isPunctLoop:
        mul  $t4, $s7, 201      #because maximum token length is 200 (+1 for null character at end)
        add  $t4 , $t2, $t4     #position of c in the token.  [token_c_idx];
        sb   $s3, tokens($t4)    #tokens[tokens_number][token_c_idx] = c;
        
        addi $t2 , $t2 , 1       #token_c_idx += 1;
        addi $t0, $t0 ,1         #c_idx += 1;
        
        lb   $s3, content($t0)        #c = content[c_idx];
        li , $t5, 44                  #ASCII value for ','
        li , $t6, 46                  #ASCII value for '.' 
        li , $t7, 33                  #ASCII value for '!'
        li , $t8, 63                  #ASCII value for '?'
        beq  $s3, $t5, isPunctLoop      #while(c == ',' || c == '.' || c == '!' || c == '?');
        beq  $s3, $t6, isPunctLoop
        beq  $s3, $t7, isPunctLoop
        beq  $s3, $t8, isPunctLoop
        
        addi $t4 , $t4 , 1
        sb   $0 , tokens($t4)        #tokens[tokens_number][token_c_idx] = '\0';
        addi $s7 , $s7 , 1           #tokens_number += 1;
        j printNewLine

printNewLine: 				        
        j splitLoop
tokenizerEnd:
        jr $ra

dictionary_split:      #more explanatory comments in my C code
        li , $s1, 0                 #int i = 0; 
        li , $t1, 0                 #int k = 0;
        li , $t2, 0                 #int j = 0;
        
inputLoop:
        lb   $t4, dictionary($t1)    # dictionary[k]
        beqz $t4 , endLoop           # if (dictionary[k] == '\0'){
        beq  $t4 , 10, wordEnd       # else if (dictionary[k] == '\n'){
        beq  $t4 , 13, wordEnd
        
        mul  $t5, $s1, 21                #because maximum dictionary word length is 20 (+1 for null character at end)
        add  $t5 , $t2, $t5               #position of char in the word.  
        sb   $t4, dictionary_words($t5)    #else {dictionary_words[i][j] = dictionary[k]}
        
        addi $t2, $t2, 1               # j+=1;
        addi $t1, $t1, 1               # k+=1;
        j    inputLoop 
        
wordEnd:
        mul  $t5, $s1, 21                #because maximum dictionary word length is 20 (+1 for null character at end)
        add  $t5 , $t2, $t5               #position of char in the word.  
        sb   $0, dictionary_words($t5)    # dictionary_words[i][j] = '\0';    
        
        addi $s1, $s1, 1         # i+=1; 
        li   $t2, 0              # j = 0;
        addi $t1, $t1, 1         # k+=1;
        j    inputLoop      
endLoop:
        mul  $t5, $s1, 21                #because maximum dictionary word length is 20 (+1 for null character at end)
        add  $t5 , $t2, $t5               #position of char in the word.  
        sb   $0, dictionary_words($t5)    # dictionary_words[i][j] = '\0';       
 
        jr $ra        
                                                                                                                                                                                                                                                                            
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
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

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
        
        jal tokenizer          #tokenize the input and return here        
        jal dictionary_split  #put the dictionary words in a 2D array called dictionary_words, and return here
        
spell_checker:            #corresponding to my C code, more explanations there
        li $t0 , 0        #int token_idx = 0;
       
tokenLoop:
        slt   $t8, $t0, $s7           #while (token_idx < tokens_number); $s7 is token number.
        beqz   $t8 , main_end        #end of tokens.  
        
        li $t1 , 0        #int char_idx = 0;             
        li $t2 , 0        #int dict_idx = 0;
        li $t3 , 0        #int isValid = 0;
        
        mul  $s6, $t0, 201          #because maximum token length is 200 (+1 for null character at end)
        add  $s6, $t1, $s6         #position of char in the token.  [char_idx];
        lb   $s3, tokens($s6)       #tokens[token_idx][char_idx]; 
        
        slti $t4 , $s3, 65     #if (c == ',' || c == '.' || c == '!' || c == '?'|| c== ' ')
        bnez $t4 , punctCheck  # check the punctuation token
        j dictionaryLoop       # else jump in dictionaryLoop

punctCheck:
        addi $t0, $t0, -1          #token_idx-=1  (to check the token before)
        mul  $s6, $t0, 201          #because maximum token length is 200 (+1 for null character at end)
        add  $s6, $t1, $s6         #position of char in the token.  [char_idx];
        lb   $s3, tokens($s6)       #tokens[token_idx][char_idx];
        
        addi $t0, $t0, 1           #token_idx+=1 (return to original token)
        li  $t8, 32                 #ASCII value for ' '
        beq $s3, $t8, isInvalid     #invalid if has a space token before it
        
        addi $t0, $t0, 1          #token_idx+=1  (to check the token after)
        mul  $s6, $t0, 201          #because maximum token length is 200 (+1 for null character at end)
        add  $s6, $t1, $s6         #position of char in the token.  [char_idx];
        lb   $s3, tokens($s6)       #tokens[token_idx][char_idx];
        
        addi $t0, $t0, -1           #token_idx-=1 (return to original token)
        slti $t4 , $s3, 65           #if !(c == ',' || c == '.' || c == '!' || c == '?'|| c== ' ')
        beqz $t4 , isInvalid        #invalid if has an alphabetic char after it
        
        mul  $s6, $t0, 201          #because maximum token length is 200 (+1 for null character at end)
        add  $s6, $t1, $s6         #position of char in the token.  [char_idx];
        lb   $s3, tokens($s6)       #tokens[token_idx][char_idx];
        
        li   $t8, 46                   #ASCII value for '.'
        beq  $s3, $t8, ellipsis        
        
        addi $t1, $t1, 1            #check next character in punctuation token
        mul  $s6, $t0, 201          #because maximum token length is 200 (+1 for null character at end)
        add  $s6, $t1, $s6         #position of char in the token.  [char_idx];
        lb   $s3, tokens($s6)       #tokens[token_idx][char_idx];
        
        li   $t1, 0                  #return to start of token    
        bnez  $s3, isInvalid      # invalid if more than one panctuation marks. Only '\0' char is valid after.
        
        li   $t3 , 1                 #int isValid = 1;
        j dictionaryLoop                   
        
isInvalid:
        li $t3 , 0        #int isValid = 0;
        j dictionaryLoop 
validDot:
        li $t3 , 1        #int isValid = 1;
        j dictionaryLoop          
        
ellipsis:
        li   $t8 , 1              #next character index in token

        mul  $s6, $t0, 201          #because maximum token length is 200 (+1 for null character at end)
        add  $s6, $t8, $s6          #position of char in the token.  
        lb   $s3, tokens($s6)       #tokens[token_idx][char_idx];
        
        beqz  $s3, validDot     #If '\0' char follows, then token is a valid dot

        li    $t7, 46                   #ASCII value for '.'
        bne   $s3, $t7, isInvalid       #if anything other than a '.' follows, invalid punctuation
        
        li    $t3 , 1               #int isValid = 1;
        addi  $t8, $t8, 1           #check next character
        mul  $s6, $t0, 201          #because maximum token length is 200 (+1 for null character at end)
        add  $s6, $t8, $s6          #position of char in the token.  
        lb   $s3, tokens($s6)       #tokens[token_idx][char_idx];
        
        li    $t7, 46                   #ASCII value for '.'
        bne   $s3, $t7, isInvalid       #if anything other than a '.' follows, invalid punctuation
        
        addi  $t8, $t8, 1           #check next character
        mul  $s6, $t0, 201          #because maximum token length is 200 (+1 for null character at end)
        add  $s6, $t8, $s6          #position of char in the token.  
        lb   $s3, tokens($s6)       #tokens[token_idx][char_idx];
        beqz  $s3 , validDot        #If '\0' char follows, then token is a valid Ellipsis.
        j isInvalid
                                                                          
dictionaryLoop:
        bnez $t3, printToken   #if (isValid ==1) break;
        bge  $t2, $s1, dictionaryEnd   #while (dict_idx < MAX_DICTIONARY_WORDS );  

charLoop:             
        mul  $s6, $t0, 201        #because maximum token length is 200 (+1 for null character at end)
        add  $s6 , $t1, $s6      #position of char in the token.  [char_idx];
        lb   $s3, tokens($s6)     #tokens[token_idx][char_idx]; 
        
        mul  $s5, $t2, 21         #because maximum dictionary word length is 20 
        add  $s5 , $t1, $s5       #position of char in the dictionary word.  [char_idx];
        lb   $s4, dictionary_words($s5)    #dictionary_words[dict_idx][char_idx];
                
        sub  $t9, $s4, $s3      #difference of the two characters
        li , $t8, 32            #ASCII difference between Upper and Lower case of same letter
        li , $t7, -32           #ASCII difference between Lower and Upper case of same letter
        
        beqz $t9, sameChar       #if two characters are the same
        beq  $t9,$t8, sameChar   #if first character is Upper case, and second is Lower (of the same letter)
        beq  $t9,$t7, sameChar    #if first character is Lower case, and second is Upper (of the same letter)
        
        li   $t3 , 0              #isValid=0; 
        addi $t2, $t2 , 1         #int dict_idx += 1;
        li   $t1 , 0              #int char_idx = 0;       
        j dictionaryLoop     

sameChar:
        li   $t3 , 1              #isValid=1; 
        addi $t1, $t1 , 1         #char_idx+=1;
        
        mul  $s6, $t0, 201        #because maximum token length is 200 (+1 for null character at end)
        add  $s6 , $t1, $s6      #position of char in the token.  [char_idx];
        lb   $s3, tokens($s6)     #tokens[token_idx][char_idx]; 
        
        mul  $s5, $t2, 21         #because maximum dictionary word length is 20 
        add  $s5 , $t1, $s5       #position of char in the dictionary word.  [char_idx];
        lb   $s4, dictionary_words($s5)    #dictionary_words[dict_idx][char_idx];
        
        beqz  $s3 , sameEnd      #if tokens[token_idx][char_idx]== '\0'
        beqz  $s4, sameEnd       #if dictionary_words[dict_idx][char_idx]== '\0';
        
        j charLoop
          
sameEnd:
        bne $s3, $s4, notSameLength   #indicates that both words ended at '\0', with the same length
        li   $t3 , 1              #isValid=1;    
        j dictionaryLoop  
notSameLength:
        li   $t3 , 0              #isValid=0;
        j dictionaryLoop         

dictionaryEnd:
        beqz $t3, underlineToken   # if(isValid==0){ 
        j printToken               # else if (isValid==1){
        
underlineToken:
        li   $t6  ,95          # ASCII value for '_' 
        li   $v0, 11             
        move  $a0, $t6         #output("_");
        syscall
        li   $t5, 0          #start printing from the initital character of the token

underlineLoop:
        mul  $s6, $t0, 201        #because maximum token length is 200 (+1 for null character at end)
        add  $s6 , $t5, $s6      #position of char in the token.  [char_idx];
        lb   $s3, tokens($s6)     #tokens[token_idx][char_idx]; 
        beqz $s3, endUnderline   #when the whole of token is printed
        
        li     $v0, 11             
        move   $a0, $s3         # print char ( tokens[token_idx][char_idx] );
        syscall
        addi $t5 ,$t5, 1         #next character in token to print
        j underlineLoop   

endUnderline:
        li   $t6  ,95          # ASCII value for '_' 
        li   $v0, 11             
        move  $a0, $t6         #output("_");
        syscall
        addi $t0, $t0 , 1        #token_idx+=1 ;
        j tokenLoop     
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
printToken:
        li   $t5, 0          #start printing from the initital character of the token
printCharLoop:
        mul  $s6, $t0, 201        #because maximum token length is 200 (+1 for null character at end)
        add  $s6 , $t5, $s6      #position of char in the token.  [char_idx];
        lb   $s3, tokens($s6)     #tokens[token_idx][char_idx]; 
        beqz  $s3, endPrint   #when the whole of token is printed
        
        li     $v0, 11             
        move   $a0, $s3         # print char ( tokens[token_idx][char_idx] );
        syscall
        addi $t5 ,$t5, 1         #next character in token to print
        j printCharLoop
endPrint:
        addi $t0, $t0 , 1        #token_idx+=1 ;
        j tokenLoop
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
