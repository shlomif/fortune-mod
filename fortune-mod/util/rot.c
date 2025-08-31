// An extremely simpleminded function. Read characters from stdin,
// rot13 them, and put them on stdout.  Totally unnecessary, of course.
#include <stdio.h>
#include <ctype.h>

#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif

int main(void)
{
#ifdef _WIN32
    // Force binary mode to avoid CRLF translation.
    setmode(_fileno(stdin), _O_BINARY);
    setmode(_fileno(stdout), _O_BINARY);
#endif

    int a;
    while ((a = getchar()) != EOF)
    {
        putchar(isupper(a)   ? ('A' + (a - 'A' + 13) % 26)
                : islower(a) ? ('a' + (a - 'a' + 13) % 26)
                             : a);
    }
    return 0;
}
