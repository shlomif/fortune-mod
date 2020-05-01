/*      $NetBSD: unstr.c,v 1.3 1995/03/23 08:29:00 cgd Exp $    */

/*-
 * Copyright (c) 1991, 1993
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
 *    This program un-does what "strfile" makes, thereby obtaining the
 * original file again.  This can be invoked with the name of the output
 * file, the input file, or both. If invoked with only a single argument
 * ending in ".dat", it is pressumed to be the input file and the output
 * file will be the same stripped of the ".dat".  If the single argument
 * doesn't end in ".dat", then it is presumed to be the output file, and
 * the input file is that name prepended by a ".dat".  If both are given
 * they are treated literally as the input and output files.
 *
 *      Ken Arnold              Aug 13, 1978
 */

/*
 * Umm.  Well, when I got this thing, it didn't work like that.  It now
 * treats the *first* filename listed as the name of the datafile; if
 * the file happens to have an extension, that's stripped off and the
 * result is the name of the strings file.  If there is no extension, then
 * the datafile has '.dat' added, and the strings file is the filename.
 * The only problem with this is if you happen to have a strings file
 * with a dot in it--in that case, specify the dat file fully.
 *
 * The program also now accepts an optional second filename, which is the
 * name of the output file; if not specified, it dumps to stdout.
 *
 * It can also take one parameter, which defines a new separator character.
 * This was added chiefly in order to avoid having to run sed over a
 * strings file; unstr *can* do it easily, so it should.
 *
 * We also had to add some code to make the special cases of a null fortune
 * (two separators on successive lines, a common enough error when editing
 * a strings file) and no trailing separator be treated properly.  Unstr
 * now writes out a separator string at the end of a file; strfile does
 * not consider the null string following this to be a fortune.  Be careful
 * not to put an extra newline after the required last newline--if so, you'll
 * get a fortune that contains nothing but a newline.  Karo syrup, syrup.
 * For the gory details, and lots of cussing, see strfile.c
 */

#include "fortune-mod-common.h"
#include "fortune-util-set-outfn.h"

static char data_filename[MAXPATHLEN], delimiter_char;

static char new_delimiter_char = '\0';

static FILE *Inf, *Dataf, *Outf;

#include "fortune-util.h"

/* ARGSUSED */
static void getargs(int ac, char *av[])
{
    int ch;

    while ((ch = getopt(ac, av, "c:")) != EOF)
        switch (ch)
        {
        case 'c':
            new_delimiter_char = *optarg;
            if (!isascii(new_delimiter_char))
            {
                fprintf(stderr, "Bad delimiting characher: '\\%o'\n",
                    (unsigned int)new_delimiter_char);
            }
            break;
        case '?':
        default:
            fprintf(stderr, "%s",
                "Usage:\n\tunstr [-c C] datafile[.ext] [outputfile]\n");
            exit(1);
        }

    av += optind;

    if (*av)
    {
        input_filename = *av;
        input_fn_2_data_fn();
        set_output_filename(*++av);
    }
    else
    {
        fprintf(stderr, "%s", "No input file name\n");
        fprintf(stderr, "%s",
            "Usage:\n\tunstr [-c C] datafile[.ext] [outputfile]\n");
        exit(1);
    }
    if (!strcmp(input_filename, output_filename))
    {
        fprintf(stderr,
            "The input file for strings (%s) must be different from the output "
            "file (%s)\n",
            input_filename, output_filename);
        exit(1);
    }
}

static void order_unstr(STRFILE *tbl)
{
    int32_t pos;
    char buf[BUFSIZ];
    int printedsome;

    for (uint32_t i = 0; i <= tbl->str_numstr; ++i)
    {
        if (!fread((char *)&pos, 1, sizeof pos, Dataf))
        {
            exit(1);
        }
        fseek(Inf, ntohl((uint32_t)pos), SEEK_SET);
        printedsome = 0;
        for (;;)
        {
            char *const sp = fgets(buf, sizeof buf, Inf);
            if ((!sp) || STR_ENDSTRING(sp, *tbl))
            {
                if (sp || printedsome)
                    fprintf(Outf, "%c\n", delimiter_char);
                break;
            }
            else
            {
                printedsome = 1;
                fputs(sp, Outf);
            }
        }
    }
}

int main(int ac, char **av)
{
    static STRFILE tbl; /* description table */

    getargs(ac, av);
    if (!(Inf = fopen(input_filename, "r")))
    {
        perror(input_filename);
        exit(1);
    }
    if (!(Dataf = fopen(data_filename, "r")))
    {
        perror(data_filename);
        exit(1);
    }
    if (*output_filename == '\0')
        Outf = stdout;
    else if (!(Outf = fopen(output_filename, "w+")))
    {
        perror(output_filename);
        exit(1);
    }
#define err_fread(a, b, c, d)                                                  \
    if (!fread(a, b, c, d))                                                    \
    {                                                                          \
        perror("fread");                                                       \
        exit(1);                                                               \
    }
    err_fread(&tbl.str_version, sizeof(tbl.str_version), 1, Dataf);
    err_fread(&tbl.str_numstr, sizeof(tbl.str_numstr), 1, Dataf);
    err_fread(&tbl.str_longlen, sizeof(tbl.str_longlen), 1, Dataf);
    err_fread(&tbl.str_shortlen, sizeof(tbl.str_shortlen), 1, Dataf);
    err_fread(&tbl.str_flags, sizeof(tbl.str_flags), 1, Dataf);
    err_fread(tbl.stuff, sizeof(tbl.stuff), 1, Dataf);
    if (!(tbl.str_flags & (STR_ORDERED | STR_RANDOM)) && (!new_delimiter_char))
    {
        fprintf(stderr, "nothing to do -- table in file order\n");
        exit(1);
    }
    if (new_delimiter_char)
        delimiter_char = new_delimiter_char;
    else
        delimiter_char = (char)tbl.str_delim;
    order_unstr(&tbl);
    fclose(Inf);
    fclose(Dataf);
    fclose(Outf);
    exit(0);
}
