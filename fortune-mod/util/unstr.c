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

#if 0
#ifndef lint
static char copyright[] =
"@(#) Copyright (c) 1991, 1993\n\
        The Regents of the University of California.  All rights reserved.\n";

#endif /* not lint */

#ifndef lint
static char sccsid[] = "@(#)unstr.c     8.1 (Berkeley) 5/31/93";

#endif /* not lint */
#endif /* comment out the dreck, kill the warnings */

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
#include        <sys/types.h>
#include        <netinet/in.h>
#include        <sys/param.h>
#include        "strfile.h"
#include        <stdio.h>
#include        <ctype.h>
#include        <string.h>
#include        <stdlib.h>
#include        <unistd.h>

#ifndef MAXPATHLEN
#define MAXPATHLEN      1024
#endif /* MAXPATHLEN */

static char *Infile,                   /* name of input file */
  Datafile[MAXPATHLEN],         /* name of data file */
  Delimch,                      /* delimiter character */
  Outfile[MAXPATHLEN];

static char NewDelch = '\0';           /* a replacement delimiter character */

static FILE *Inf, *Dataf, *Outf;

/* ARGSUSED */
static void getargs(int ac, char *av[])
{
    char *extc;
    int ch;

    while ((ch = getopt(ac, av, "c:")) != EOF)
        switch (ch)
          {
          case 'c':
              NewDelch = *optarg;
              if (!isascii(NewDelch))
              {
                  fprintf(stderr, "Bad delimiting characher: '\\%o'\n", (unsigned int)NewDelch);
              }
              break;
          case '?':
          default:
              fprintf(stderr, "Usage:\n\tunstr [-c C] datafile[.ext] [outputfile]\n");
              exit(1);
          }

    av += optind;

    if (*av)
    {
        Infile = *av;
        fprintf(stderr, "Input file: %s\n", Infile);
        if (!strrchr(Infile, '.'))
        {
            strcpy(Datafile, Infile);
            strcat(Datafile, ".dat");
        }
        else
        {
            strcpy(Datafile, Infile);
            extc = strrchr(Infile, '.');
            *extc = '\0';
        }
        if (*++av)
        {
            strcpy(Outfile, *av);
            fprintf(stderr, "Output file: %s\n", Outfile);
        }
    }
    else
    {
        fprintf(stderr, "No input file name\n");
        fprintf(stderr, "Usage:\n\tunstr [-c C] datafile[.ext] [outputfile]\n");
        exit(1);
    }
    if (!strcmp(Infile, Outfile))
    {
        fprintf(stderr, "The input file for strings (%s) must be different from the output file (%s)\n", Infile, Outfile);
        exit(1);
    }
}

static void order_unstr(register STRFILE *tbl)
{
    register uint32_t i;
    register char *sp;
    auto int32_t pos;
    char buf[BUFSIZ];
    int printedsome;

    for (i = 0; i <= tbl->str_numstr; i++)
    {
        fread((char *) &pos, 1, sizeof pos, Dataf);
        fseek(Inf, ntohl((uint32_t)pos), 0);
        printedsome = 0;
        for (;;)
        {
            sp = fgets(buf, sizeof buf, Inf);
            if (sp == NULL || STR_ENDSTRING(sp, *tbl))
            {
                if (sp || printedsome)
                    fprintf(Outf, "%c\n", Delimch);
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
    static STRFILE tbl;         /* description table */

    getargs(ac, av);
    if ((Inf = fopen(Infile, "r")) == NULL)
    {
        perror(Infile);
        exit(1);
    }
    if ((Dataf = fopen(Datafile, "r")) == NULL)
    {
        perror(Datafile);
        exit(1);
    }
    if (*Outfile == '\0')
        Outf = stdout;
    else if ((Outf = fopen(Outfile, "w+")) == NULL)
    {
        perror(Outfile);
        exit(1);
    }
    fread(&tbl.str_version,  sizeof(tbl.str_version),  1, Dataf);
    fread(&tbl.str_numstr,   sizeof(tbl.str_numstr),   1, Dataf);
    fread(&tbl.str_longlen,  sizeof(tbl.str_longlen),  1, Dataf);
    fread(&tbl.str_shortlen, sizeof(tbl.str_shortlen), 1, Dataf);
    fread(&tbl.str_flags,    sizeof(tbl.str_flags),    1, Dataf);
    fread( tbl.stuff,        sizeof(tbl.stuff),        1, Dataf);
    if (!(tbl.str_flags & (STR_ORDERED | STR_RANDOM)) && (!NewDelch))
    {
        fprintf(stderr, "nothing to do -- table in file order\n");
        exit(1);
    }
    if (NewDelch)
        Delimch = NewDelch;
    else
        Delimch = (char)tbl.str_delim;
    order_unstr(&tbl);
    fclose(Inf);
    fclose(Dataf);
    fclose(Outf);
    exit(0);
}
