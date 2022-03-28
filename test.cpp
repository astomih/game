#include <iostream>
#include <stdio.h>
#include <string>

int main(int argc, const char **argv) {
  int a = 1;
  int &b = a;
  int c = 10;

  memcpy(&b, &c, sizeof(int));
  printf("%d\n", b);

  return 0;
}