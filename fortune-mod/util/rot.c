/*
 * An extremely simpleminded function. Read characters from stdin,
 * rot13 them, and put them on stdout.  Totally unnecessary, of course.
 */

#include <stdio.h>
#include <ctype.h>

int main(void)
{
    char a, b;

    while ((a = getchar()) != EOF)
    {
	if (isupper(a))
	    b = 'A' + (a - 'A' + 13) % 26;
	else if (islower(a))
	    b = 'a' + (a - 'a' + 13) % 26;
	else
	    b = a;
	putchar(b);
    }
    exit(0);
}
