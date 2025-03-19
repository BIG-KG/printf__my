#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

extern void printf__my(char *const string, ...);

int main() 
{
    printf__my("test");
}