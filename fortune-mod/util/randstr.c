/*
 * The following code has been derived chiefly from the BSD distributions
 * of the utility program unstr and the random quote displayer fortune.
 * The utility produced by this code shares characteristics of both
 * (it might be regarded as a minimalist implementation of fortune, for
 * large values of 'minimal'), and is here offered so as to have the
 * minimal necessary tools for rabbiting a strfile routine into some other,
 * more significant program, all in one place.  A programmer who cares and
 * has the proper training could probably clean this up significantly; it's
 * all stolen code (first rule of programming: steal) hacked together to
 * fit.  Or, to paraphrase the old saw about how the British built ships,
 * it's coded by the mile and cut off to order.  In that analogy, this
 * program's about an inch--and separated with an axe.
 *
 * Axe murderess programming.  Wotta concept!
 *
 * Use at your own peril, especially as a pattern (kludge, kludge!). This
 * program, at least, shouldn't have any real chance of corrupting data,
 * though; it opens files ro and dumps to the screen.  If you redirect
 * output, you definitely do so at your own peril (I lost six hours of
 * editing on a fortune file that way, by redirecting the output of unstr
 * before it had an outputfile option, trying to skip over the mv x.sorted
 * x step.  Axe murderess redirection, in that case).
 *
 * Blame Amy A. Lewis.  September, 1995.  alewis@email.unc.edu
 */

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

/* randstr repeats the minimum functionality of the fortune program.  It
 * finds the fortune text or data file specified on the command line --
 * one or the other, not both -- generates a random number, and displays
 * the text string indexed.  No provision is made for any other command
 * line switches.  At all.
 *
 * Usage:
 *
 * randstr filename[.ext]
 *
 * Example: run sed or Perl over your /etc/passwd, and kick out a
 * strfile-format file containing lognames on the first line and full
 * names on the second.  Write a script called 'lottery' which is
 * called once a month from crontab; it in turn calls randstr lusers,
 * and the winning luser gets a prize notification sent by email from
 * the lottery script.  Living up to promises is optional.
 *
 * Note: if you're a sysadmin who regularly reads _Mein Kampf_ for the
 * deep truths buried in it, and believe in Truth, Justice, and the
 * American Family, you could use this to replace fortune, by pointing
 * it at a small, Family Values database.  The great advantage to this,
 * in my opinion, is that it wouldn't take up any disk space at all.
 * Who're you gonna quote?  Dan Quayle?
 */

#include        <netinet/in.h>
#include        <sys/param.h>
#include        "strfile.h"
#include        <stdio.h>
#include        <stdlib.h>
#include        <ctype.h>
#include        <string.h>
#include        <unistd.h>
#include        <time.h>
#ifndef MAXPATHLEN
#define MAXPATHLEN      1024
#endif /* MAXPATHLEN */

char *Infile,                   /* name of input file */
  Datafile[MAXPATHLEN],         /* name of data file */
  Delimch;                      /* delimiter character */

FILE *Inf, *Dataf, *Outf;

off_t pos, Seekpts[2];          /* seek pointers to fortunes */


void getargs(int ac, char *av[])
{
    extern int optind;
    char *extc;

    av += optind + 1;

    if (*av)
    {
        Infile = *av;
/* Hmm.  Don't output anything if we can help it.
 * fprintf(stderr, "Input file: %s\n",Infile); */
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
    }
    else
/*    {
 * Don't write out errors here, either; trust in exit codes and sh
 * fprintf(stderr, "No input file name\n");
 * fprintf(stderr, "Usage:\n\tunstr [-c C] datafile[.ext] [outputfile]\n");
 */ exit(1);
/*    } */
}

/*
 * get_pos:
 *      Get the position from the pos file, if there is one.  If not,
 *      return a random number.
 */
void get_pos(STRFILE * fp)
{
    pos = random() % fp->str_numstr;
    if (++(pos) >= fp->str_numstr)
        pos -= fp->str_numstr;
}

/*
 * get_fort:
 *      Get the fortune data file's seek pointer for the next fortune.
 */
void get_fort(STRFILE fp)
{
    register int choice;

    choice = random() % fp.str_numstr;

    get_pos(&fp);
    fseek(Dataf, (long) (sizeof fp + pos * sizeof Seekpts[0]), 0);
    fread(Seekpts, sizeof Seekpts, 1, Dataf);
    Seekpts[0] = ntohl(Seekpts[0]);
    Seekpts[1] = ntohl(Seekpts[1]);
}

void display(FILE * fp, STRFILE table)
{
    register char *p, ch;
    unsigned char line[BUFSIZ];
    int i;

    fseek(fp, (long) Seekpts[0], 0);
    for (i = 0; fgets(line, sizeof line, fp) != NULL &&
         !STR_ENDSTRING(line, table); i++)
    {
        if (table.str_flags & STR_ROTATED)
            for (p = line; (ch = *p); ++p)
                if (isupper(ch))
                    *p = 'A' + (ch - 'A' + 13) % 26;
                else if (islower(ch))
                    *p = 'a' + (ch - 'a' + 13) % 26;
        fputs(line, stdout);
    }
    fflush(stdout);
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
    fread((char *) &tbl, sizeof tbl, 1, Dataf);
    tbl.str_version = ntohl(tbl.str_version);
    tbl.str_numstr = ntohl(tbl.str_numstr);
    tbl.str_longlen = ntohl(tbl.str_longlen);
    tbl.str_shortlen = ntohl(tbl.str_shortlen);
    tbl.str_flags = ntohl(tbl.str_flags);

    srandom((int) (time((time_t *) NULL) + getpid()));
    get_fort(tbl);
    display(Inf, tbl);

    exit(0);

    fclose(Inf);
    fclose(Dataf);
    fclose(Outf);
    exit(0);
}
