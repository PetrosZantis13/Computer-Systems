/***********************************************************************
* File       : <spell_checker.c>
*
* Author     : <Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/18
*
***********************************************************************/
// ==========================================================================
// Spell checker
// ==========================================================================
// Marks misspelled words in a sentence according to a dictionary

// Inf2C-CS Coursework 1. Task B/C
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2018

#include <stdio.h>

// maximum size of input file
#define MAX_INPUT_SIZE 2048
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 10000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 20

int read_char() { return getchar(); }
int read_int()
{
    int i;
    scanf("%i", &i);
    return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
char dictionary_file_name[] = "dictionary.txt";
// input file name
char input_file_name[] = "input.txt";
// content of input file
char content[MAX_INPUT_SIZE + 1];
// valid punctuation marks
char punctuations[] = ",.!?";
// tokens of input file
char tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];
// number of tokens in input file
int tokens_number = 0;
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1];

///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////

// You can define your global variables here!
char dictionary_words[MAX_DICTIONARY_WORDS + 1][MAX_WORD_SIZE + 1];
// Task B
void dictionary_split(){      //put the dictionary words in a 2D array called dictionary_words
  int i = 0;                //position of word in the new 2D array
  int k = 0;               //position of character in the old 1D array called dictionary[]
  int j = 0;               //position of a character in a word

  do {
    if (dictionary[k] == '\0'){          //if null character, means end of dictionary[]
      dictionary_words[i][j] = '\0';    //place a null character at end of each word
      break;                           //break the loop
    }
    else if (dictionary[k] == '\n'){      //if new line character
      dictionary_words[i][j] = '\0';      //place a null character at end of each word
      i+=1;                              //go to next word in new 2d array
      j=0;                              //start from its beggining.
      k+=1 ;                           //next character in dictionary[]
    }
    else {
      dictionary_words[i][j] = dictionary[k];  //copy the character into the correct position, in the new 2D array
      j+=1;                                    //go to next character in dictionary_words[][]
      k+=1;                                    //next character in dictionary[]
    }
  }while(1);
}

int same_letter(char c, char d){       //to identify if two characters are the same letter
  if (c==d || (c<d && ((d-c)==32)) || (c>d && ((c-d)==32))){  //difference in ASCII is either 0, or 32(if one is Upper case and other is not)
    return 1;
  }
  return 0;
}

int is_punct(char c){              //to identify if a character is a valid punctuation or a space
  if (c == ',' || c == '.' || c == '!' || c == '?'|| c== ' '){  //only these 5 are valid
    return 1;
  }
  return 0;
}

void spell_checker() {

  dictionary_split();     //put the dictionary words in a 2D array called dictionary_words
  int token_idx = 0;     //start from the first token

 do {
   int isValid = 0;     //equivalent to a boolean, indicates if a token is valid (in the dictionary)
   int char_idx = 0;    //position (index) of a character in a word
   int dict_idx = 0;    // index of the dictionary word

   if (is_punct(tokens[token_idx][char_idx]) ==1) { //if the character is a valid punctuation or a space
      isValid=1;                                   //the boolean becomes true
     }
   do {
      if (isValid ==1) break;                   //if the boolean is true, break the loop
          do{
             if (same_letter( tokens[token_idx][char_idx] , dictionary_words[dict_idx][char_idx] ) ==1){  //if the two characters are the same letter
               isValid=1;          //boolean becomes true
               char_idx+=1;        //next character
               }
             else {              //if the two characters are not the same letter
                isValid=0;      //boolean becomes false
                char_idx = 0;    //character index restarts (back to 0)
                dict_idx+=1;     // next word in dictionary_words
                break;
              }
           }while ( ( tokens[token_idx][char_idx] != '\0') && (dictionary_words[dict_idx][char_idx]!= '\0') );  //repeat the loop until one of the two words ends
     if ( tokens[token_idx][char_idx] != dictionary_words[dict_idx][char_idx]) {   //meaning both must be '/0' at the same time, thus same length
       isValid=0;     //if not same legth, boolean turns false
     }
   }while (dict_idx < MAX_DICTIONARY_WORDS );    //repeat the loop until the end of the dictionary_words[][]
    if (isValid==1){                 //if the boolean is true
	     output(tokens[token_idx]);   //print the current valid token
  	 }
		else if(isValid==0){         //if the boolean is false
		   output("_");                //underline
		   output(tokens[token_idx]);  //and print the current invalid token
		   output("_");
		  }
		token_idx+=1 ;            //next token in tokens[][]
    //print_int(isValid);
  }while (token_idx < tokens_number);   //repeat the loop until the end of tokens[][]
 }

// Task B
void output_tokens() {
  return;
}

//---------------------------------------------------------------------------
// Tokenizer function
// Split content into tokens
//---------------------------------------------------------------------------
void tokenizer(){
  char c;

  // index of content
  int c_idx = 0;
  c = content[c_idx];
  do {

    // end of content
    if(c == '\0'){
      break;
    }

    // if the token starts with an alphabetic character
    if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {

      int token_c_idx = 0;
      // copy till see any non-alphabetic character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with one of punctuation marks
    } else if(c == ',' || c == '.' || c == '!' || c == '?') {

      int token_c_idx = 0;
      // copy till see any non-punctuation mark character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ',' || c == '.' || c == '!' || c == '?');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with space
    } else if(c == ' ') {

      int token_c_idx = 0;
      // copy till see any non-space character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ' ');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;
    }
  } while(1);
}
//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{


  /////////////Reading dictionary and input files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;

  // open input file
  FILE *input_file = fopen(input_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the input file failed
  if(input_file == NULL){
    print_string("Error in opening input file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }

  // reading the input file
  do {
    c_input = fgetc(input_file);
    // indicates the the of file
    if(feof(input_file)) {
      content[idx] = '\0';
      break;
    }

    content[idx] = c_input;

    if(c_input == '\n'){
      content[idx] = '\0';
    }

    idx += 1;

  } while (1);

  // closing the input file
  fclose(input_file);

  idx = 0;

  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }

    dictionary[idx] = c_input;
    idx += 1;
  } while (1);

  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ////////////////////////////////////////////////////////////////

  tokenizer();

  spell_checker();

  output_tokens();

  return 0;
}
