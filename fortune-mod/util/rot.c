// An extremely simpleminded function. Read characters from stdin,
// rot13 them, and put them on stdout.  Totally unnecessary, of course.
#include <stdio.h>
#include <ctype.h>

int main(void)
{
    int a;
    while ((a = getchar()) != EOF)
    {
        putchar(isupper(a)   ? ('A' + (a - 'A' + 13) % 26)
                : islower(a) ? ('a' + (a - 'a' + 13) % 26)
                             : a);
    }
    return 0;
}
