//CS 214 2025
//simulates cache operations
//assumes addresses are 16 bits
//this was the most confusing homework i have ever done
//used ai to explain a lot of the cache stuff that i didn't understand
//looked up bit switching for exponents and how to use the strncpy function
//i am not confident in edge case functionality but i am tired

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int offset_bits;           //number of bits in the offset
int line_num_bits;         //number of bits in the line number
int misses = 0;
int num_sets;
int lines_per_set;

//CACHE STRUCT LINE DEFINITION
struct line {
  char* tag;
  int validity;
  int dirty;
};

struct line* cache;
//creates array of cache
  
int binToInt(char* bin) {  //converts binary number string into integer
  int retVal = 0;
  while(*bin) {
    retVal *= 2;
    if(*bin == '1')
      retVal += 1;
    bin++;
  }
  return retVal;
}

int read(char* addr) {
  //called when there is a read on given address; returns whether it hit
  //declare sizes
  int tag_bits = 16 - line_num_bits - offset_bits;
  char tag[tag_bits + 1];//tag
  char lineA[line_num_bits+1];//line
  char offset[offset_bits+1];//offset

  ///  printf("tag is this long: %d DEBUG\n",sizeof(tag));   
  strncpy(tag, addr, tag_bits);
  //copy over the tag
  //plus terminating 0
  tag[tag_bits]='\0';

  strncpy(lineA, addr + tag_bits, line_num_bits);
  //copy line addy
  //add terminating 0
  lineA[line_num_bits]='\0';

  strncpy(offset, addr + tag_bits + line_num_bits, offset_bits);
  //copy over offset
  //add terminating 0
  offset[offset_bits] ='\0';
  
  // printf("[DEBUG] Read from address %s: tag- %s, line- %s, off- %s\n", addr, tag, lineA, offset);
  //check if everything got separated correctly

  //convert binary to num
  int line_number = binToInt(lineA);
  //add more stuff because its now dynamically allocated
  int set_number = line_number % num_sets; //which set are we in
  int line_in_set = line_number / num_sets; //index within set
  int line_index = set_number * lines_per_set + line_in_set; //total of indexes in other sets we've passed plus current index
      //traverses the actual full array


  //check if the cache is valid and the tags match
  if(cache[line_index].validity == 1 && strcmp(cache[line_index].tag, tag)==0){
    printf("Read to address %s is ", addr);
    return 1;
    //CACHE HIT
  }
  //CACHE MISS
  //else, corresponding data block put into cache by adjusting line and returning 0
  //free original tag if it's there
  if(cache[line_index].tag != NULL){
    free(cache[line_index].tag);
  }
  //allocate memory
  cache[line_index].tag = (char*)malloc((tag_bits+1));
  //copy data
  strcpy(cache[line_index].tag, tag);
  //mark valid
  cache[line_index].validity = 1;
  //log a miss
  misses++;
  printf("Read to address %s is ", addr);
  return 0;
}

int write(char* addr) {
  //called when there is a read on given address; returns whether it hit
  //declare sizes
  int tag_bits = 16 - line_num_bits - offset_bits;
  char tag[tag_bits + 1];//tag
  char lineA[line_num_bits+1];//line
  char offset[offset_bits+1];//offset

  ///  printf("tag is this long: %d DEBUG\n",sizeof(tag));   
  strncpy(tag, addr, tag_bits);
  //copy over the tag
  //plus terminating 0
  tag[tag_bits]='\0';

  strncpy(lineA, addr + tag_bits, line_num_bits);
  //copy line addy
  //add terminating 0
  lineA[line_num_bits]='\0';

  strncpy(offset, addr + tag_bits + line_num_bits, offset_bits);
  //copy over offset
  //add terminating 0
  offset[offset_bits] ='\0';
  
  // printf("[DEBUG] Read from address %s: tag- %s, line- %s, off- %s\n", addr, tag, lineA, offset);
  //check if everything got separated correctly

  //convert binary to num
  int line_number = binToInt(lineA);
  //add more stuff because its now dynamically allocated
  int set_number = line_number % num_sets; //which set are we in
  int line_in_set = line_number / num_sets; //index within set
  int line_index = set_number * lines_per_set + line_in_set; //total of indexes in other sets we've passed plus current index
      //traverses the actual full array


  //check if the cache is valid and the tags match
  if(cache[line_index].validity == 1 && strcmp(cache[line_index].tag, tag)==0){
     printf("Write to address %s is ", addr);
    //mark cache as dirty because we are writing
    cache[line_index].dirty = 1;
    return 1;
    //CACHE HIT
  }
  //CACHE MISS
  //else, corresponding data block put into cache by adjusting line and returning 0
  //free original tag if it's there
  if(cache[line_index].tag != NULL){
    free(cache[line_index].tag);
  }
  //allocate memory
  cache[line_index].tag = (char*)malloc((tag_bits+1));
  //copy data
  strcpy(cache[line_index].tag, tag);
  //mark valid
  cache[line_index].validity = 1;
  //mark dirty
  cache[line_index].dirty = 1;
  //log a miss
  misses++;
  
  printf("Write to address %s: ", addr);
  return 0;
}

void print() {  //print the cache contents
  printf("--------------------\nCache contents:\n");
  for(int i = 0; i < num_sets * lines_per_set; i++){
    printf("line %d: ", i);
    if(cache[i].tag != NULL){
      printf("Tag: %s ", cache[i].tag);
      if(cache[i].dirty)
	printf("Dirty");
    }
    else
      printf("Empty");
    printf("\n");
  }
  printf("Misses so far: %d\n", misses);

}

int main(int argc, char** argv) {
  //argv[1] = x == line_num_bits
  //argv[2] = y == num of sets is 2^y / # of line bits
  //argv[3] = z == offset bits

  num_sets = 1 << atoi(argv[2]); //2^y

  
  //x=y means direct mapped cache
  if(atoi(argv[1]) == atoi(argv[2])){
    //#of lines is equal to # of sets
    lines_per_set = num_sets;
  }
  else{//sets in size of 2^(x-y)
    lines_per_set = 1 << (atoi(argv[1])-atoi(argv[2]));
  }
  offset_bits = atoi(argv[3]);       //line size was 2^3=8 bytes -> z
  line_num_bits = atoi(argv[1]);     //2^4=16 lines -> x

  //allocate cache memory
  cache = malloc(num_sets * lines_per_set * sizeof(struct line));
  if(cache == NULL){
    printf("[DEBUG] memory allocation failed");
    return 1;
  }
    
    //initialize empty cache
  for(int i = 0; i < num_sets * lines_per_set; i++){
    cache[i].tag = NULL;
    cache[i].validity = 0;
    cache[i].dirty = 0;
  }
  
  char line[30];  //to read input
  while(fgets(line, 30, stdin) != NULL) {
    char* cmd = strtok(line, " \n");  //command
    if(strcmp(cmd, "quit") == 0)
      break;
    if(strcmp(cmd, "print") == 0)
      print();
    else if(strcmp(cmd, "read") == 0) {
      char* addr = strtok(NULL, " \n");  //address for operation
      if(addr)
	if(read(addr))
	  printf("Hit!\n");
	else
	  printf("Miss\n");
      else
	printf("Missing address\n");
    } else if(strcmp(cmd, "write") == 0) {
      char* addr = strtok(NULL, " \n");  //address for operation
      if(addr)
	if(write(addr))
	  printf("Hit!\n");
	else
	  printf("Miss\n");
      else
	printf("Missing address\n");
    } else
      printf("Unrecognized command: %s\n", cmd);
  }

  //free up cache at end
    for(int i = 0; i < num_sets * lines_per_set; i++){
      if(cache[i].tag != NULL)
	free(cache[i].tag);
    }
    free(cache);
}
