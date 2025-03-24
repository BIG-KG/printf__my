#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h> 

extern void printf__my(char *const string, ...);

int main() 
{
    printf__my("%d %c %s %x %d%% %c \n", -1, 'e', "test string ", 256, 40, 'u');
}