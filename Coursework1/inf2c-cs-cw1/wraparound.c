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
// 2D String Finder VERTICAL & HORIZONTAL & DIAGONAL
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
int number_of_rows = 1; // Variables to keep track of rows and columns, always at least 1 row
int number_of_cols = 0;

int current_col = -1; // Global column and row variables to keep track of where the program is in the grid
int current_row = -1; // Used across multiple functions, hence global
char *end_address = 0; // Pointer used to store the end of the grid for comparisons

// function to print found word
void print_word(char *word)
{
  while(*word != '\n' && *word != '\0') {
    print_char(*word);
    word++;
  }
}

// HORIZONTAL STRING/WORD MATCHER - checks horizontal match
// function to see if the string contains the (\n terminated) word
int h_contain(char *string, char *word) //two targets
{
  while (1) {
    // Second check in this if statement is now necessary as a string may end in newline character as well!
    if (((*string != *word) && (*string != '\n')) || (*string == '\n' && *word == '\n')){ // if the string is no longer the same as the word
      return ((*word == '\n')); // return true if dictionary word is new line, false if it isn't
    } // word will have been incremented to the new line character if it has been successful in
    // finding a match between string and word, if there has been a match so far, but then it isn't
    // the new line character, then the word has not finished (ie: not being found in nothing)

    // WRAP AROUND FUNCTIONALITY
    if ((*string == '\n') && (*word != '\n')) { // if the end of the row, but not the end of the dictionary word
      string = string - number_of_cols - 1; // start at the beginning of the row again, decrement by 1 to compensate newline char
      word--; // move the dictionary word back one so it doesn't skip over a char
    }

    string++; // increment string and word pointers
    word++;
  }
  return 0;
}

// VERTICAL STRING/WORD MATCHER - checks vertical match
int v_contain(char *string, char *word) //two targets
{
  int looped = 0; // local variable to store whether looped around once or not - not specified about multiple wrap arounds so just a boolean
  int temp_row = current_row; // local variable to store row currently on without affecting the current_row counter

  while (1) {
    if (*string != *word){ // if the string is no longer the same as the word
      return ((*word == '\n')); // return true if dictionary word is new line, false if it isn't, functionality same as h_contain
    }

    // WRAP AROUND FUNCTIONALITY
    if (((temp_row + 1) == number_of_rows) && (looped == 0)) { // if on the last row and hasn't been looped through once
      string = string - (temp_row * number_of_cols) - temp_row; // set string to the same col on the first row: string - total grid chars - newline chars
      looped = 1; // toggle boolean looped condition so function knows it has looped around the grid once already
    }
    else {
      string = string + number_of_cols + 1; // increment string by an entire line (+1 for the newline char too)
    }

    word++; // increment string and word pointers
    temp_row++;
  }
  return 0;
}

// DIAGONAL STRING/WORD MATCHER - checks diagonal match
int d_contain(char *string, char *word) //two targets
{
  int temp_row = current_row;
  int temp_col = current_col;

  while (1) {
    if ((((*string != *word) && (*string != '\n'))) || (*string == '\n' && *word == '\n')){ // if the string is no longer the same as the word
      return ((*word == '\n')); // return true if dictionary word is new line, false if it isn't, functionality same as h_contain
    }
    
    string = string + number_of_cols + 1 + 1; // increment string pointer by an entire row (+1 for newline char too, +1 for diagonality)

    if ((*string == '\n') || (string > end_address)) { // if gone past the end of the grid, or landed on a new line character
      string = string - number_of_cols - 1 - 1; // undo the previous increment
      string = string - ((temp_row * number_of_cols) + temp_row + temp_row); // skip back diagonally

      if (temp_col+1 < number_of_rows) { // if in the lower left corner of the grid
        string = string + (number_of_rows-(temp_col+1))*(number_of_cols + 1 + 1); // only skip back the required number of rows
      }

      // Don't need to reset column/row counters as won't be wrapping around again
    }

    temp_col++; // increment word and row/col counters
    temp_row++;
    word++;
  }
  return 0;
}

// STRFIND - Finds matches in all directions by going through the dictionary
void strfind()
{
  char *dictionary_word; // pointer to the dictionary word
  int idx = 0;
  int grid_idx = 0;

  for(idx = 0; idx < dict_num_words; idx ++) { // for each word in the dictionary, check if there are matches
    grid_idx = 0; // re-index to the start of the grid when a new dictionary word is chosen
    dictionary_word = dictionary + dictionary_idx[idx]; // new dictionary word address
    current_col = -1; // start count at -1 for row and col as rows and columns are indexed from 0
    current_row = -1;
    while (grid[grid_idx] != '\0') { // while not the end of the grid file
      current_row++; // the program is going through row by row, so increment row
      while (grid[grid_idx] != '\n') { // while not the end of the current row
        current_col++; // increment column as going through character by character (column by column)
        if (h_contain(grid + grid_idx, dictionary_word)) { // if HORIZONTAL WORD found, print it out with the details
          if (found > 0) { // Only a print a new line if a word has been found (to stop wasted terminal line)
            print_char('\n');
          }
          print_int(current_row);
          print_char(',');
          print_int(current_col); 
          print_char(' ');
          print_char('H');
          print_char(' ');
          print_word(dictionary_word); // print the word that is there
          print_char(' ');
          found++; // found at least one word, so increment found
          }
        if (v_contain(grid + grid_idx, dictionary_word)) { // if VERTICAL WORD found, print it out with the details
          if (found > 0) { // Only a print a new line if a word has been found (to stop wasted terminal line)
            print_char('\n');
          }
          print_int(current_row);
          print_char(',');
          print_int(current_col); 
          print_char(' ');
          print_char('V');
          print_char(' ');
          print_word(dictionary_word); // print the word that is there
          print_char(' ');
          found++; // found at least one word, so increment found          
          }
        if (d_contain(grid + grid_idx, dictionary_word)) { // if DIAGONAL WORD found, print it out with the details
          if (found > 0) { // Only a print a new line if a word has been found (to stop wasted terminal line)
            print_char('\n');
          }
          print_int(current_row);
          print_char(',');
          print_int(current_col);
          print_char(' ');
          print_char('D');
          print_char(' ');
          print_word(dictionary_word); // print the word that is there
          print_char(' ');
          found++; // found at least one word, so increment found          
          }
        grid_idx++; // increment the grid index to keep looking through the grid
      }
      grid_idx++; // newline character detected, so increment the grid index past it
      current_col = -1; // reset the column counter back to its original value
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

  dict_num_words = dict_idx - 1; // Ignore the last line of the dicitonary that has no word on it

  // run calculations to work out the number of columns and rows in the grid
  int i = 0;
  // increment through the grid to find first newline occurence, no. of chars before that is the number of cols (width of grid)
  while (grid[i] != '\n') {
    number_of_cols++;
    i++;
  }
  i = 0; // Reset counting variable for next loop
  // increment through the grid until the end, count the number of newline occurences - this is the number of rows (length of grid)
  while (grid[i] != '\0') {
    if (grid[i] == '\n') {
      number_of_rows++;
    }
    i++;
  }

  number_of_rows--; // The grid contains a \n then \0 at the end, so a blank new line needs to be removed
  end_address = grid + (number_of_rows*number_of_cols) + number_of_rows + 1; // Store the address of the end of the grid
  // Base of grid + total number of characters + all of the newlines (one per row) + EOF character

  strfind(); // search for all matches

  if (found == 0) { // if a word hasn't been found at all then print "-1" and a newline to the terminal
    print_string("-1");
  }

  print_char('\n'); // Ensure line is returned for the terminal prompt

  return 0;
}