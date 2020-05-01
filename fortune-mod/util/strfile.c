/*      $NetBSD: strfile.c,v 1.3 1995/03/23 08:28:47 cgd Exp $  */

/*-
 * Copyright (c) 1989, 1993
 *      The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Ken Arnold.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by the University of
 *      California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * Changes, September 1995, to make the damn thing actually sort instead
 * of just pretending.  Amy A. Lewis
 *
 * And lots more.
 *
 * Fixed the special cases of %^J% (an empty fortune), no 'separator' at
 * the end of the file, and a trailing newline at the end of the file, all
 * of which produced total ballsup at one point or another.
 *
 * This included adding a routine to go back and write over the last pointer
 * written or stored, for the case of an empty fortune.
 *
 * unstr also had to be modified (well, for *lots* of reasons, but this was
 * one) to be certain to put the delimiters in the right places.
 */

#include "fortune-mod-common.h"

/*
 *    This program takes a file composed of strings separated by
 * lines containing only the delimiting character (the default
 * character is '%') and creates another file which consists of a table
 * describing the file (structure from "strfile.h"), a table of seek
 * pointers to the start of the strings, and the strings, each terminated
 * by a null byte.  Usage:
 *
 *      % strfile [-iorsx] [ -cC ] sourcefile [ datafile ]
 *
 *      c - Change delimiting character from '%' to 'C'
 *      s - Silent.  Give no summary of data processed at the end of
 *          the run.
 *      o - order the strings in alphabetic order
 *      i - if ordering, ignore case
 *      r - randomize the order of the strings
 *      x - set rotated bit
 *
 *              Ken Arnold      Sept. 7, 1978 --
 *
 *      Added ordering options.
 *
 * Made ordering options do more than set the bloody flag, September 95 A. Lewis
 *
 * Always make sure that your loop control variables aren't set to bloody
 * *zero* before distributing the bloody code, all right?
 *
 */

#define CHUNKSIZE 512

#define ALLOC(ptr, sz)                                                         \
    {                                                                          \
        if (!ptr)                                                              \
            ptr = malloc((unsigned int)(CHUNKSIZE * sizeof *ptr));             \
        else if (((sz) + 1) % CHUNKSIZE == 0)                                  \
            ptr = realloc((void *)ptr,                                         \
                ((unsigned int)((sz) + CHUNKSIZE) * sizeof *ptr));             \
        if (!ptr)                                                              \
        {                                                                      \
            fprintf(stderr, "out of space\n");                                 \
            exit(1);                                                           \
        }                                                                      \
    }

typedef struct
{
    char first;
    int32_t pos;
} STR;

static char delimiter_char = '%';

static bool Sflag = false; /* silent run flag */
static bool Oflag = false; /* ordering flag */
static bool Iflag = false; /* ignore case flag */
static bool Rflag = false; /* randomize order flag */
static bool Xflag = false; /* set rotated bit */
static long Num_pts = 0;   /* number of pointers/strings */

static bool storing_ptrs(void) { return (Oflag || Rflag); }

static int32_t *Seekpts;

static FILE *Sort_1, *Sort_2; /* pointers for sorting */

static STRFILE Tbl; /* statistics table */

static STR *Firstch; /* first chars of each string */

static void __attribute__((noreturn)) usage(void)
{
    fprintf(stderr, "%s", "strfile [-iorsx] [-c char] sourcefile [datafile]\n");
    exit(1);
}

#include "fortune-util-set-outfn.h"

/*
 *    This routine evaluates arguments from the command line
 */
static void getargs(int argc, char **argv)
{
    int ch;

    while ((ch = getopt(argc, argv, "c:iorsx")) != EOF)
        switch (ch)
        {
        case 'c': /* new delimiting char */
            delimiter_char = *optarg;
            if (!isascii(delimiter_char))
            {
                printf("bad delimiting character: '\\%o\n'",
                    (unsigned int)delimiter_char);
            }
            break;
        case 'i': /* ignore case in ordering */
            Iflag = true;
            break;
        case 'o': /* order strings */
            Oflag = true;
            break;
        case 'r': /* randomize pointers */
            Rflag = true;
            break;
        case 's': /* silent */
            Sflag = true;
            break;
        case 'x': /* set the rotated bit */
            Xflag = true;
            break;
        case '?':
        default:
            usage();
        }
    argv += optind;

    if (*argv)
    {
        input_filename = *argv;
        set_output_filename(*++argv);
    }
    if (!input_filename)
    {
        puts("No input file name");
        usage();
    }
    if (*output_filename == '\0')
    {
        if (strlen(input_filename) > MAXPATHLEN - 10)
        {
            puts("input file name too long!");
            usage();
        }
        snprintf(
            output_filename, COUNT(output_filename), "%s.dat", input_filename);
    }
}

/*
 * add_offset:
 *      Add an offset to the list, or write it out, as appropriate.
 */
static void add_offset(FILE *fp, int32_t off)
{
    if (!storing_ptrs())
    {
        uint32_t net;
        net = htonl((uint32_t)off);
        fwrite(&net, 1, sizeof net, fp);
    }
    else
    {
        ALLOC(Seekpts, Num_pts + 1);
        Seekpts[Num_pts] = off;
    }
    Num_pts++;
}

/*
 * fix_last_offset:
 *     Used when we have two separators in a row.
 */
static void fix_last_offset(FILE *const fp, const int32_t off)
{
    if (!storing_ptrs())
    {
        uint32_t net = htonl((uint32_t)off);
        fseek(fp, -(long)(sizeof net), SEEK_CUR);
        fwrite(&net, 1, sizeof net, fp);
    }
    else
    {
        Seekpts[Num_pts - 1] = off;
    }
}

/*
 * cmp_str:
 *      Compare two strings in the file
 */
static int cmp_str(const void *v1, const void *v2)
{
#define SET_N(nf, ch) (nf = (ch == '\n'))
#define IS_END(ch, nf) (ch == delimiter_char && nf)

    const STR *p1 = (const STR *)v1;
    const STR *p2 = (const STR *)v2;
    int c1 = p1->first;
    int c2 = p2->first;
    if (c1 != c2)
    {
        return c1 - c2;
    }

    fseek(Sort_1, p1->pos, SEEK_SET);
    fseek(Sort_2, p2->pos, SEEK_SET);

    bool n1 = false;
    bool n2 = false;
    while (!isalnum(c1 = getc(Sort_1)) && c1 != '\0')
        SET_N(n1, c1);
    while (!isalnum(c2 = getc(Sort_2)) && c2 != '\0')
        SET_N(n2, c2);

    while (!IS_END(c1, n1) && !IS_END(c2, n2))
    {
        if (Iflag)
        {
            if (isupper(c1))
                c1 = tolower(c1);
            if (isupper(c2))
                c2 = tolower(c2);
        }
        if (c1 != c2)
        {
            return c1 - c2;
        }
        SET_N(n1, c1);
        SET_N(n2, c2);
        c1 = getc(Sort_1);
        c2 = getc(Sort_2);
    }
    if (IS_END(c1, n1))
    {
        c1 = 0;
    }
    if (IS_END(c2, n2))
    {
        c2 = 0;
    }
    return c1 - c2;
}

/*
 * do_order:
 *      Order the strings alphabetically (possibly ignoring case).
 */
static void do_order(void)
{
    Sort_1 = fopen(input_filename, "r");
    Sort_2 = fopen(input_filename, "r");
    qsort(
        (char *)Firstch, (size_t)((int)Num_pts - 1), sizeof *Firstch, cmp_str);
    /*      i = Tbl.str_numstr;
     * Fucking brilliant.  Tbl.str_numstr was initialized to zero, and is still
     * zero
     */
    long i = Num_pts - 1;
    int32_t *lp = Seekpts;
    STR *fp = Firstch;
    while (i--)
    {
        *lp++ = fp++->pos;
    }
    fclose(Sort_1);
    fclose(Sort_2);
    Tbl.str_flags |= STR_ORDERED;
}

/*
 * randomize:
 *      Randomize the order of the string table.  We must be careful
 *      not to randomize across delimiter boundaries.  All
 *      randomization is done within each block.
 */
static void randomize(void)
{
    srandom((unsigned int)(time((time_t *)NULL) + getpid()));

    Tbl.str_flags |= STR_RANDOM;
    /*      cnt = Tbl.str_numstr;
     * See comment above.  Isn't this stuff distributed worldwide?  How
     * embarrassing!
     */
    int cnt = (int)Num_pts;

    /*
     * move things around randomly
     */

    int32_t *sp = Seekpts;
    for (; cnt > 0; cnt--, sp++)
    {
        const int i = random() % cnt;
        const int32_t tmp = sp[0];
        sp[0] = sp[i];
        sp[i] = tmp;
    }
}

/*
 * main:
 *      Drive the sucker.  There are two main modes -- either we store
 *      the seek pointers, if the table is to be sorted or randomized,
 *      or we write the pointer directly to the file, if we are to stay
 *      in file order.  If the former, we allocate and re-allocate in
 *      CHUNKSIZE blocks; if the latter, we just write each pointer,
 *      and then seek back to the beginning to write in the table.
 */
int main(int ac, char **av)
{
    char *sp;
    FILE *inf, *outf;
    bool len_was_set = false;

    getargs(ac, av); /* evalute arguments */
    if (!(inf = fopen(input_filename, "r")))
    {
        perror(input_filename);
        exit(1);
    }

    if (!(outf = fopen(output_filename, "w")))
    {
        perror(output_filename);
        exit(1);
    }
    if (!storing_ptrs())
    {
        (void)fseek(outf, sizeof Tbl, SEEK_SET);
    }

    /*
     * Write the strings onto the file
     */

    Tbl.str_longlen = 0;
    Tbl.str_shortlen = (unsigned int)0xffffffff;
    Tbl.str_delim = (uint8_t)delimiter_char;
    Tbl.str_version = STRFILE_VERSION;
    bool first = Oflag;
    add_offset(outf, (int32_t)ftell(inf));
    int32_t last_off = 0;
    do
    {
        char string[257];
        sp = fgets(string, 256, inf);
        if ((!sp) || STR_ENDSTRING(sp, Tbl))
        {
            const int32_t pos = (int32_t)ftell(inf);
            const int32_t length =
                pos - last_off - (int32_t)(sp ? strlen(sp) : 0);
            if (!length)
            /* Here's where we go back and fix things, if the
             * 'fortune' just read was the null string.
             * We had to make the assignment of last_off slightly
             * redundant to achieve this.
             */
            {
                if (pos - last_off == 2)
                {
                    fix_last_offset(outf, pos);
                }
                last_off = pos;
                continue;
            }
            last_off = pos;
            add_offset(outf, pos);
            if (!len_was_set)
            {
                Tbl.str_longlen = (uint32_t)length;
                Tbl.str_shortlen = (uint32_t)length;
                len_was_set = true;
            }
            else
            {
                if ((int)Tbl.str_longlen < length)
                {
                    Tbl.str_longlen = (uint32_t)length;
                }
                if (Tbl.str_shortlen > (uint32_t)length)
                {
                    Tbl.str_shortlen = (uint32_t)length;
                }
            }
            first = Oflag;
        }
        else if (first)
        {
            char *nsp = sp;
            for (; !isalnum(*nsp); ++nsp)
            {
            }
            ALLOC(Firstch, Num_pts);
            STR *const fp = &Firstch[Num_pts - 1];
            fp->first =
                ((Iflag && isupper(*nsp)) ? ((char)tolower(*nsp)) : (*nsp));
            fp->pos = Seekpts[Num_pts - 1];
            first = false;
        }
    } while (sp);

    /*
     * write the tables in
     */

    fclose(inf);

    if (Oflag)
    {
        do_order();
    }
    else if (Rflag)
    {
        randomize();
    }

    if (Xflag)
    {
        Tbl.str_flags |= STR_ROTATED;
    }

    if (!Sflag)
    {
        printf("\"%s\" created\n", output_filename);
        if (Num_pts == 1)
        {
            puts("There was no string");
        }
        else
        {
            if (Num_pts == 2)
            {
                puts("There was 1 string");
            }
            else
            {
                printf("There were %ld strings\n", Num_pts - 1);
            }
            printf("Longest string: %lu byte%s\n",
                (unsigned long)(Tbl.str_longlen),
                Tbl.str_longlen == 1 ? "" : "s");
            printf("Shortest string: %lu byte%s\n",
                (unsigned long)(Tbl.str_shortlen),
                Tbl.str_shortlen == 1 ? "" : "s");
        }
    }

    fseek(outf, (off_t)0, SEEK_SET);
    Tbl.str_version = htonl(Tbl.str_version);
    Tbl.str_numstr = htonl((uint32_t)(Num_pts - 1));
    /* Look, Ma!  After using the variable three times, let's store
     * something in it!
     */
    Tbl.str_longlen = htonl(Tbl.str_longlen);
    Tbl.str_shortlen = htonl(Tbl.str_shortlen);
    Tbl.str_flags = htonl(Tbl.str_flags);
    fwrite(&Tbl.str_version, sizeof Tbl.str_version, 1, outf);
    fwrite(&Tbl.str_numstr, sizeof Tbl.str_numstr, 1, outf);
    fwrite(&Tbl.str_longlen, sizeof Tbl.str_longlen, 1, outf);
    fwrite(&Tbl.str_shortlen, sizeof Tbl.str_shortlen, 1, outf);
    fwrite(&Tbl.str_flags, sizeof Tbl.str_flags, 1, outf);
    fwrite(Tbl.stuff, sizeof Tbl.stuff, 1, outf);
    if (storing_ptrs())
    {
        int cnt = (int)Num_pts;
        for (int32_t *p = Seekpts; cnt--; ++p)
        {
            *p = (int32_t)htonl((uint32_t)*p);
            fwrite(p, sizeof *p, 1, outf);
        }
    }
    fclose(outf);
    exit(0);
}
