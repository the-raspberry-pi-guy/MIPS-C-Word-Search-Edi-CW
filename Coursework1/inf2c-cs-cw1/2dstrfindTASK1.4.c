/***********************************************************************
* File       : <2dstrfind.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder VERTICAL & HORIZONTAL
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid

// Inf2C-CS Coursework 1. Task 3-5
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

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
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE + 1 /* for \0 */ ];
// content of dictionary file 
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */ ) + 1 /* for \0 */ ];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////

int dict_num_words = 0;
int dictionary_idx[MAX_DICTIONARY_WORDS];
int found = 0; // Variable store whether a word has been found or not
int number_of_rows = 1; //always at least 1 row
int number_of_cols = 0;
int total_grid_chars = 0;

// function to print found word
void print_word(char *word)
{
  while(*word != '\n' && *word != '\0') {
    print_char(*word);
    word++;
  }
}

// function to see if the string contains the (\n terminated) word
int contain(char *string, char *word) //two targets
{
  while (1) {
    // Second check in this if statement is now necessary as a string may end in newline character as well!
    if ((*string != *word) || (*string == '\n' && *word == '\n')){ // if the string is no longer the same as the word
      return ((*word == '\n')); // return true if dictionary word is new line, false if it isn't
    } // word will have been incremented to the new line character if it has been successful in
    // finding a match between string and word, if there has been a match so far, but then it isn't
    // the new line character, then the word has not finished (ie: not being found in nothing)

    string++; // increment string and word pointers
    word++;
  }

  return 0;
}

int v_contain(char *string, char *word) //two targets
{
  while (1) {
    // Second check in this if statement is now necessary as a string may end in newline character as well!
    if (*string != *word){ // if the string is no longer the same as the word
      return ((*word == '\n')); // return true if dictionary word is new line, false if it isn't
    } // word will have been incremented to the new line character if it has been successful in
    // finding a match between string and word, if there has been a match so far, but then it isn't
    // the new line character, then the word has not finished (ie: not being found in nothing)

    string = string + number_of_cols +1; // increment string and word pointers (+1 for newline char)
// if (string > grid+total_grid_chars) {return 0;} // Turns out that this is unnecessary
    word++;
  }

  return 0;
}

// this functions finds all of the VERTICAL matches in the grid
void v_strfind()
{
  char *dictionary_word;
  int idx = 0;
  int grid_idx = 0;
  int row = 0;
  for(idx = 0; idx < dict_num_words; idx ++) { // for each word in the dictionary, check if there is a match
    grid_idx = 0; // re-index to the start of the grid when a new dictionary word is chosen
    dictionary_word = dictionary + dictionary_idx[idx]; // new dictionary word address
    int col = -1; // start count at -1 for row and col as rows and columns are indexed from 0
    int row = -1;
    while (grid[grid_idx] != '\0') { 
      row++; 
      while (grid[grid_idx] != '\n') {
        col++;
        if (v_contain(grid + grid_idx, dictionary_word)) { // if the dictionary word is in the address, print
          print_int(row);
          print_char(',');
          print_int(col); // print that id number
          print_char(' ');
          print_char('V');
          print_char(' ');
          print_word(dictionary_word); // print the word that is there
          print_char(' ');
          print_char('\n');
          found++; // found at least one word, so increment found
          }
        grid_idx++;
      }
      grid_idx++;
      col = -1;
    }
  }
}

// this functions finds all of the HORIZONTAL matches in the grid
void h_strfind()
{
  char *dictionary_word;
  int idx = 0;
  int grid_idx = 0;
  int row = 0;
  for(idx = 0; idx < dict_num_words; idx ++) { // for each word in the dictionary, check if there is a match
    grid_idx = 0; // re-index to the start of the grid when a new dictionary word is chosen
    row = 0; // reset row counter
    dictionary_word = dictionary + dictionary_idx[idx]; // new dictionary word address
    int col = -1; // start count at -1 for row and col as rows and columns are indexed from 0
    int row = -1;
    while (grid[grid_idx] != '\0') { 
      row++; 
      while (grid[grid_idx] != '\n') {
        col++;
        if (contain(grid + grid_idx, dictionary_word)) { // if the dictionary word is in the address, print
          print_int(row);
          print_char(',');
          print_int(col); // print that id number
          print_char(' ');
          print_char('H');
          print_char(' ');
          print_word(dictionary_word); // print the word that is there
          print_char(' ');
          print_char('\n');
          found++; // found at least one word, so increment found
          }
        grid_idx++;
      }
      grid_idx++;
      col = -1;
    }
  }
}

//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{

  /////////////Reading dictionary and grid files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;
  int dict_idx = 0;
  int start_idx = 0;

  // open grid file
  FILE *grid_file = fopen(grid_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the grid file failed
  if(grid_file == NULL){
    print_string("Error in opening grid file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }
  // reading the grid file
  do {
    c_input = fgetc(grid_file);
    // indicates the the of file
    if(feof(grid_file)) {
      grid[idx] = '\0';
      break;
    }
    grid[idx] = c_input;
    idx += 1;

  } while (1);

  // closing the grid file
  fclose(grid_file);
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
  ///////////////You can add your code here!//////////////////////

  idx = 0;
    do {
      c_input = dictionary[idx]; // character input at index
      if(c_input == '\0') { // if end of file then stop
        break;
      }
      if(c_input == '\n') { // if new line then store the index of this word in the dictionary
        dictionary_idx[dict_idx ++] = start_idx;
        start_idx = idx + 1; // increase the start index to find the next word
      }
      idx += 1;
    } while (1); // this will stop from the break if end of file

  dict_num_words = dict_idx;

  int i = 0;
  int j = 0;
  while (grid[i] != '\n') {
     number_of_cols++;
      i++;
  }
  while (grid[j] != '\0') {
    if (grid[j] == '\n') {
      number_of_rows++;
    }
    j++;
  }
  total_grid_chars = number_of_rows * number_of_cols;

  h_strfind();
  v_strfind();

  if (found == 0) { // if a word hasn't been found at all then print "-1"
    print_string("-1\n");
  }

  return 0;
}
