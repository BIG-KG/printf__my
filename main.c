#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h> 

extern void printf__my(char *const string, ...);

int main() 
{
    printf__my("%b %d %x\n", 256);
}