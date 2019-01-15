// This is a very silly circular buffer implementation,
// just for testing an external program

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define FILE_NAME "circular_buffer.txt"
#define RECORD_SIZE 9L
#define RECORD "%8d"

void usage(const char *cmd)
{
  fprintf(stderr, "Syntax: %s <command>, where <command> is:\n\
  init <size>\n\
  put <value>\n\
  get\n\
  length\n\
  dump\n", cmd);
  exit(1);
}

void init(const char *s)
{
  int size = atoi(s);
  FILE *fp;
  int i;

  if (access(FILE_NAME, F_OK) != -1)
  {
    fprintf(stderr, "Buffer exists already.\n");
    exit(2);
  }
  if (size < 1)
  {
    fprintf(stderr, "Invalid size.\n");
    exit(3);
  }
  if (!(fp = fopen(FILE_NAME, "w")))
  {
    fprintf(stderr, "Could not open file.\n");
    exit(4);
  }
  fprintf(fp, "%8d\n", size);   // size
  fprintf(fp, "%8d\n", 0);      // low water
  fprintf(fp, "%8d\n", 0);      // high water
  for (i = 0; i < size + 1; i++)
    fprintf(fp, "%8d\n", -1);   // data
  fclose(fp);
}

void put(const char *s)
{
  int value = atoi(s);
  FILE *fp;
  int size, low, high;

  if (access(FILE_NAME, F_OK) == -1)
  {
    fprintf(stderr, "Buffer is not initialized.\n");
    exit(2);
  }
  if (!(fp = fopen(FILE_NAME, "r+")))
  {
    fprintf(stderr, "Could not open file.\n");
    exit(4);
  }
  fscanf(fp, "%d\n", &size);
  fscanf(fp, "%d\n", &low);
  fscanf(fp, "%d\n", &high);
  if (fseek(fp, (high + 3) * RECORD_SIZE, SEEK_SET) < 0)
  {
    fprintf(stderr, "Invalid pointer.\n");
    exit(5);
  }
  high++; if (high >= size + 1) high = 0;
  if (high == low)
  {
    fprintf(stderr, "Buffer full, can't store more data.\n");
    exit(6);
  }
  fprintf(fp, "%8d\n", value);
  if (fseek(fp, 2 * RECORD_SIZE, SEEK_SET) < 0)
  {
    fprintf(stderr, "Invalid pointer.\n");
    exit(5);
  }
  fprintf(fp, "%8d\n", high);
  fclose(fp);
}

void get()
{
  FILE *fp;
  int size, low, high;
  int value;

  if (access(FILE_NAME, F_OK) == -1)
  {
    fprintf(stderr, "Buffer is not initialized.\n");
    exit(2);
  }
  if (!(fp = fopen(FILE_NAME, "r+")))
  {
    fprintf(stderr, "Could not open file.\n");
    exit(4);
  }
  fscanf(fp, "%d\n", &size);
  fscanf(fp, "%d\n", &low);
  fscanf(fp, "%d\n", &high);
  if (high == low)
  {
    fprintf(stderr, "Buffer empty, can't extract more data.\n");
    exit(6);
  }
  if (fseek(fp, (low + 3) * RECORD_SIZE, SEEK_SET) < 0)
  {
    fprintf(stderr, "Invalid pointer.\n");
    exit(5);
  }
  fscanf(fp, "%d\n", &value);
  low++; if (low >= size + 1) low = 0;
  if (fseek(fp, 1 * RECORD_SIZE, SEEK_SET) < 0)
  {
    fprintf(stderr, "Invalid pointer.\n");
    exit(5);
  }
  fprintf(fp, "%8d\n", low);
  printf("%d\n", value);
  fclose(fp);
}

void length()
{
  FILE *fp;
  int size, low, high;

  if (access(FILE_NAME, F_OK) == -1)
  {
    fprintf(stderr, "Buffer is not initialized.\n");
    exit(2);
  }
  if (!(fp = fopen(FILE_NAME, "r")))
  {
    fprintf(stderr, "Could not open file.\n");
    exit(4);
  }
  fscanf(fp, "%d\n", &size);
  fscanf(fp, "%d\n", &low);
  fscanf(fp, "%d\n", &high);
  if (low <= high)
    printf("%d\n", high - low);
  else
    printf("%d\n", size + 1 + high - low);
  fclose(fp);
}

void dump()
{
  FILE *fp;
  char c;

  if (access(FILE_NAME, F_OK) == -1)
  {
    fprintf(stderr, "Buffer is not initialized.\n");
    exit(2);
  }
  if (!(fp = fopen(FILE_NAME, "r")))
  {
    fprintf(stderr, "Could not open file.\n");
    exit(4);
  }
  printf("\nFile '%s' contains:\n\n", FILE_NAME);
  while ((c = fgetc(fp)) != EOF)       // No assumptions made on file correctness
    putchar(c);
  fclose(fp);
  putchar('\n');
}

int main(int argc, char *argv[])
{
  switch(argc)
  {
    case 2:
      if (!strcmp(argv[1], "get"))
        get();
      else if (!strcmp(argv[1], "length"))
        length();
      else if (!strcmp(argv[1], "dump"))
        dump();
      else
        usage(argv[0]);
      break;
    case 3:
      if (!strcmp(argv[1], "init")) 
        init(argv[2]);
      else if (!strcmp(argv[1], "put"))
        put(argv[2]);
      else
        usage(argv[0]);
      break;
    default:
      usage(argv[0]);
  }
}
