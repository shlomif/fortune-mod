/*      $NetBSD: fortune.c,v 1.8 1995/03/23 08:28:40 cgd Exp $  */

/*-
 * Copyright (c) 1986, 1993
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

/* Modified September, 1995, Amy A. Lewis
 * 1: removed all file-locking dreck.  Unnecessary
 * 2: Fixed bug that made fortune -f report a different list than
 *    fortune with any other parameters, or none, and which forced
 *    the program to read only one file (named 'fortunes')
 * 3: removed the unnecessary print_file_list()
 * 4: Added "OFFDIR" to pathnames.h as the directory in which offensive
 *    fortunes are kept.  This considerably simplifies our life by
 *    permitting us to dispense with a lot of silly tests for the string
 *    "-o" at the end of a filename.
 * 5: I think the problems with trying to find filenames were fixed by
 *    the change in the way that offensive files are defined.  Two birds,
 *    one stone!
 * 6: Calculated probabilities for all files, so that -f will print them.
 */

/* Changes Copyright (c) 1997 Dennis L. Clark.  All rights reserved.
 *
 *    The changes in this file may be freely redistributed, modified or
 *    included in other software, as long as both the above copyright
 *    notice and these conditions appear intact.
 */

/* Modified May 1997, Dennis L. Clark (dbugger@progsoc.uts.edu.au)
 *  + Various portability fixes
 *  + Percent selection of files with -a now works on datafiles which
 *    appear in both unoffensive and offensive directories (see man page
 *    for details)
 *  + The -s and -l options are now more consistent in their
 *    interpretation of fortune length
 *  + The -s and -l options can now be combined wit the -m option
 */

/* Modified Jul 1999, Pablo Saratxaga <srtxg@chanae.alphanet.ch>
 * - added use of the LANG variables; now if called without argument
 * it will choose (if they exist) fortunes in the users' language.
 * (that is, under a directory $LANG/ under the main fortunes directory
 *
 * Added to debian by Alastair McKinstry, <mckinstry@computer.org>, 2002-07-31
 */

#if 0                           /* comment out the stuff here, and get rid of silly warnings */
#ifndef lint
static char copyright[] =
"@(#) Copyright (c) 1986, 1993\n\
        The Regents of the University of California.  All rights reserved.\n";

#endif /* not lint */

#ifndef lint
#if 0
static char sccsid[] = "@(#)fortune.c   8.1 (Berkeley) 5/31/93";

#else
static char rcsid[] = "$NetBSD: fortune.c,v 1.8 1995/03/23 08:28:40 cgd Exp $";

#endif
#endif /* not lint */
#endif /* killing warnings */

#define         PROGRAM_NAME            "fortune-mod"

#include <stdbool.h>

#include        <sys/types.h>
#include        <sys/time.h>
#include        <sys/param.h>
#include        <sys/stat.h>
#include        <netinet/in.h>

#include        <time.h>
#include        <dirent.h>
#include        <fcntl.h>
#include        <assert.h>
#include        <unistd.h>
#include        <stdio.h>
#include        <ctype.h>
#include        <stdlib.h>
#include        <string.h>
#include        <errno.h>
#include        <locale.h>
#include        <langinfo.h>
#include        <recode.h>


#ifdef HAVE_REGEX_H
#include        <regex.h>
#endif
#ifdef HAVE_REGEXP_H
#include        <regexp.h>
#endif
#ifdef HAVE_RX_H
#include        <rx.h>
#endif

#include        "config.h"
#include        "strfile.h"

#define TRUE    1
#define FALSE   0

#define MINW    6               /* minimum wait if desired */
#define CPERS   20              /* # of chars for each sec */

#define POS_UNKNOWN     ((int32_t) -1)  /* pos for file unknown */
#define NO_PROB         (-1)    /* no prob specified for file */

#ifdef DEBUG
#define DPRINTF(l,x)    if (Debug >= l) fprintf x;
#else
#define DPRINTF(l,x)
#endif

typedef struct fd
{
    int percent;
    int fd, datfd;
    int32_t pos;
    FILE *inf;
    char *name;
    char *path;
    char *datfile, *posfile;
    bool read_tbl;
    bool was_pos_file;
    bool utf8_charset;
    STRFILE tbl;
    int num_children;
    struct fd *child, *parent;
    struct fd *next, *prev;
}
FILEDESC;

static char * env_lang;

static bool Found_one;                 /* did we find a match? */
static bool Find_files = FALSE;        /* just find a list of proper fortune files */
static bool Wait = FALSE;              /* wait desired after fortune */
static bool Short_only = FALSE;        /* short fortune desired */
static bool Long_only = FALSE;         /* long fortune desired */
static bool Offend = FALSE;            /* offensive fortunes only */
static bool All_forts = FALSE;         /* any fortune allowed */
static bool Equal_probs = FALSE;       /* scatter un-allocated prob equally */
static bool Show_filename = FALSE;

static bool ErrorMessage = FALSE;      /* Set to true if an error message has been displayed */

#ifndef NO_REGEX
static bool Match = FALSE;             /* dump fortunes matching a pattern */

#endif
#ifdef DEBUG
static bool Debug = FALSE;             /* print debug messages */

#endif

static unsigned char *Fortbuf = NULL;  /* fortune buffer for -m */

static int Fort_len = 0, Spec_prob = 0,        /* total prob specified on cmd line */
  Num_files, Num_kids,          /* totals of files and children. */
  SLEN = 160;                   /* max. characters in a "short" fortune */

static int32_t Seekpts[2];             /* seek pointers to fortunes */

static FILEDESC *File_list = NULL,     /* Head of file list */
 *File_tail = NULL;             /* Tail of file list */
static FILEDESC *Fortfile;             /* Fortune file to use */

static STRFILE Noprob_tbl;             /* sum of data for all no prob files */

#ifdef POSIX_REGEX
#define RE_COMP(p)      regcomp(&Re_pat, (p), REG_NOSUB)
#define BAD_COMP(f)     ((f) != 0)
#define RE_EXEC(p)      (regexec(&Re_pat, (p), 0, NULL, 0) == 0)

static regex_t Re_pat;
#else
#define NO_REGEX
#endif /* POSIX_REGEX */

static RECODE_REQUEST request;
static RECODE_OUTER outer;

int add_dir(register FILEDESC *);

static unsigned long my_random(unsigned long base)
{
    FILE * fp;
    unsigned long long l = 0;
    char * hard_coded_val;

    hard_coded_val = getenv("FORTUNE_MOD_RAND_HARD_CODED_VALS");
    if (hard_coded_val)
    {
        return ((unsigned long)atol(hard_coded_val) % base);
    }
    if (getenv("FORTUNE_MOD_USE_SRAND"))
    {
        goto fallback;
    }
    fp = fopen("/dev/urandom", "rb");
    if (! fp)
    {
        goto fallback;
    }
    if (fread(&l, sizeof(l), 1, fp) != 1)
    {
        fclose(fp);
        goto fallback;
    }
    fclose(fp);
    return l % base;
fallback:
    return random() % base;
}

static char *program_version(void)
{
    static char buf[BUFSIZ];
    (void) sprintf(buf, "%s version %s", PROGRAM_NAME, VERSION);
    return buf;
}

static void __attribute__((noreturn)) usage(void)
{
    (void) fprintf(stderr, "%s\n",program_version());
    (void) fprintf(stderr, "fortune [-a");
#ifdef  DEBUG
    (void) fprintf(stderr, "D");
#endif /* DEBUG */
    (void) fprintf(stderr, "f");
#ifndef NO_REGEX
    (void) fprintf(stderr, "i");
#endif /* NO_REGEX */
    (void) fprintf(stderr, "l");
#ifndef NO_OFFENSIVE
    (void) fprintf(stderr, "o");
#endif
    (void) fprintf(stderr, "sw]");
#ifndef NO_REGEX
    (void) fprintf(stderr, " [-m pattern]");
#endif /* NO_REGEX */
    (void) fprintf(stderr, " [-n number] [ [#%%] file/directory/all]\n");
    exit(1);
}

#define STR(str)        ((str) == NULL ? "NULL" : (str))


/*
 * calc_equal_probs:
 *      Set the global values for number of files/children, to be used
 * in printing probabilities when listing files
 */
static void calc_equal_probs(void)
{
    FILEDESC *fiddlylist;

    Num_files = Num_kids = 0;
    fiddlylist = File_list;
    while (fiddlylist != NULL)
    {
        Num_files++;
        Num_kids += fiddlylist->num_children;
        fiddlylist = fiddlylist->next;
    }
}

/*
 * print_list:
 *      Print out the actual list, recursively.
 */
static void print_list(register FILEDESC * list, int lev)
{
    while (list != NULL)
    {
        fprintf(stderr, "%*s", lev * 4, "");
        if (list->percent == NO_PROB)
            if (!Equal_probs)
/* This, with some changes elsewhere, gives proper percentages for every case
 * fprintf(stderr, "___%%"); */
                fprintf(stderr, "%5.2f%%", (100.0 - Spec_prob) *
                        list->tbl.str_numstr / Noprob_tbl.str_numstr);
            else if (lev == 0)
                fprintf(stderr, "%5.2f%%", 100.0 / Num_files);
            else
                fprintf(stderr, "%5.2f%%", 100.0 / Num_kids);
        else
            fprintf(stderr, "%5.2f%%", 1.0 * list->percent);
        fprintf(stderr, " %s", STR(list->name));
        DPRINTF(1, (stderr, " (%s, %s, %s)\n", STR(list->path),
                    STR(list->datfile), STR(list->posfile)));
        putc('\n', stderr);
        if (list->child != NULL)
            print_list(list->child, lev + 1);
        list = list->next;
    }
}

#ifndef NO_REGEX
/*
 * conv_pat:
 *      Convert the pattern to an ignore-case equivalent.
 */
static char *conv_pat(register char *orig)
{
    register char *sp;
    register unsigned int cnt;
    register char *new;

    cnt = 1;                    /* allow for '\0' */
    for (sp = orig; *sp != '\0'; sp++)
        if (isalpha(*sp))
            cnt += 4;
        else
            cnt++;
    if ((new = malloc(cnt)) == NULL)
    {
        fprintf(stderr, "pattern too long for ignoring case\n");
        exit(1);
    }

    for (sp = new; *orig != '\0'; orig++)
    {
        if (islower(*orig))
        {
            *sp++ = '[';
            *sp++ = *orig;
            *sp++ = (char)toupper(*orig);
            *sp++ = ']';
        }
        else if (isupper(*orig))
        {
            *sp++ = '[';
            *sp++ = *orig;
            *sp++ = (char)tolower(*orig);
            *sp++ = ']';
        }
        else
            *sp++ = *orig;
    }
    *sp = '\0';
    return new;
}
#endif /* NO_REGEX */

/*
 * do_malloc:
 *      Do a malloc, checking for NULL return.
 */
static void *do_malloc(size_t size)
{
    void *new;

    if ((new = malloc(size)) == NULL)
    {
        (void) fprintf(stderr, "fortune: out of memory.\n");
        exit(1);
    }
    return new;
}

/*
 * do_free:
 *      Free malloc'ed space, if any.
 */
static void do_free(void *ptr)
{
    if (ptr != NULL)
        free(ptr);
}

/*
 * copy:
 *      Return a malloc()'ed copy of the string
 */
static char *copy(char *str, unsigned int len)
{
    char *new, *sp;

    new = do_malloc(len + 1);
    sp = new;
    do
    {
        *sp++ = *str;
    }
    while (*str++);
    return new;
}

/*
 * new_fp:
 *      Return a pointer to an initialized new FILEDESC.
 */
static FILEDESC *new_fp(void)
{
    register FILEDESC *fp;

    fp = (FILEDESC *) do_malloc(sizeof *fp);
    fp->datfd = -1;
    fp->pos = POS_UNKNOWN;
    fp->inf = NULL;
    fp->fd = -1;
    fp->percent = NO_PROB;
    fp->read_tbl = FALSE;
    fp->tbl.str_version = 0;
    fp->tbl.str_numstr = 0;
    fp->tbl.str_longlen = 0;
    fp->tbl.str_shortlen = 0;
    fp->tbl.str_flags = 0;
    fp->tbl.stuff[0] = 0;
    fp->tbl.stuff[1] = 0;
    fp->tbl.stuff[2] = 0;
    fp->tbl.stuff[3] = 0;
    fp->next = NULL;
    fp->prev = NULL;
    fp->child = NULL;
    fp->parent = NULL;
    fp->datfile = NULL;
    fp->posfile = NULL;
    return fp;
}

/*
 * is_dir:
 *      Return TRUE if the file is a directory, FALSE otherwise.
 */
static int is_dir(char *file)
{
    auto struct stat sbuf;

    if (stat(file, &sbuf) < 0)
        return FALSE;
    return (sbuf.st_mode & S_IFDIR);
}

/*
 * is_existant:
 *      Return TRUE if the file exists, FALSE otherwise.
 */
static int is_existant(char *file)
{
    struct stat staat;

    if (stat(file, &staat) == 0)
        return TRUE;
    switch(errno)
    {
        case ENOENT:
        case ENOTDIR:
            return FALSE;
        default:
            perror("fortune: bad juju in is_existant");
            exit(1);
    }
}

/*
 * is_fortfile:
 *      Return TRUE if the file is a fortune database file.  We try and
 *      exclude files without reading them if possible to avoid
 *      overhead.  Files which start with ".", or which have "illegal"
 *      suffixes, as contained in suflist[], are ruled out.
 */
static int is_fortfile(char *file, char **datp)
{
    register int i;
    register char *sp;
    register char *datfile;
    static const char *suflist[] =
    {                           /* list of "illegal" suffixes" */
        "dat", "pos", "c", "h", "p", "i", "f",
        "pas", "ftn", "ins.c", "ins,pas",
        "ins.ftn", "sml",
        NULL
    };

    DPRINTF(2, (stderr, "is_fortfile(%s) returns ", file));

    if ((sp = strrchr(file, '/')) == NULL)
        sp = file;
    else
        sp++;
    if (*sp == '.')
    {
        DPRINTF(2, (stderr, "FALSE (file starts with '.')\n"));
        return FALSE;
    }
    if ((sp = strrchr(sp, '.')) != NULL)
    {
        sp++;
        for (i = 0; suflist[i] != NULL; i++)
            if (strcmp(sp, suflist[i]) == 0)
            {
                DPRINTF(2, (stderr, "FALSE (file has suffix \".%s\")\n", sp));
                return FALSE;
            }
    }

    datfile = copy(file, (unsigned int) (strlen(file) + 4));    /* +4 for ".dat" */
    strcat(datfile, ".dat");
    if (access(datfile, R_OK) < 0)
    {
        free(datfile);
        DPRINTF(2, (stderr, "FALSE (no \".dat\" file)\n"));
        return FALSE;
    }
    if (datp != NULL)
        *datp = datfile;
    else
        free(datfile);
    DPRINTF(2, (stderr, "TRUE\n"));
    return TRUE;
}

/*
 * add_file:
 *      Add a file to the file list.
 */
static int add_file(int percent, register const char *file, const char *dir,
             FILEDESC ** head, FILEDESC ** tail, FILEDESC * parent)
{
    register FILEDESC *fp;
    register int fd;
    register char *path, *testpath;
    register bool was_malloc;
    register bool isdir;
    auto char *sp;
    auto bool found;
    struct stat statbuf;

    if (dir == NULL)
    {
        path = strdup(file);
        was_malloc = TRUE;
    }
    else
    {
        path = do_malloc((unsigned int) (strlen(dir) + strlen(file) + 2));
        (void) strcat(strcat(strcpy(path, dir), "/"), file);
        was_malloc = TRUE;
    }
    if (*path == '/' && !is_existant(path))     /* If doesn't exist, don't do anything. */
    {
        if (was_malloc)
            free(path);
        return FALSE;
    }
    if ((isdir = is_dir(path)) && parent != NULL)
    {
        if (was_malloc)
            free(path);
        return FALSE;           /* don't recurse */
    }

    DPRINTF(1, (stderr, "trying to add file \"%s\"\n", path));
    if ((fd = open(path, O_RDONLY)) < 0 || *path != '/')
    {
      found = FALSE;
        if (dir == NULL && (strchr(file,'/') == NULL))
        {
            if ( ((sp = strrchr(file,'-')) != NULL) && (strcmp(sp,"-o") == 0) )
            {
                /* BSD-style '-o' offensive file suffix */
                *sp = '\0';
                found = (add_file(percent, file, LOCOFFDIR, head, tail, parent))
                         || add_file(percent, file, OFFDIR, head, tail, parent);
                /* put the suffix back in for better identification later */
                *sp = '-';
            }
            else if (All_forts)
                found = (add_file(percent, file, LOCFORTDIR, head, tail, parent)
                         || add_file(percent, file, LOCOFFDIR, head, tail, parent)
                         || add_file(percent, file, FORTDIR, head, tail, parent)
                         || add_file(percent, file, OFFDIR, head, tail, parent));
            else if (Offend)
                found = (add_file(percent, file, LOCOFFDIR, head, tail, parent)
                         || add_file(percent, file, OFFDIR, head, tail, parent));
            else
                found = (add_file(percent, file, LOCFORTDIR, head, tail, parent)
                         || add_file(percent, file, FORTDIR, head, tail, parent));
        }
        if (!found && parent == NULL && dir == NULL)
        { /* don't display an error when trying language specific files */
          if (env_lang) {
            char *lang;
            char llang[512];
            char langdir[512];
            int ret=0;
            char *p;

            strncpy(llang,env_lang,sizeof(llang));
            llang[sizeof(llang)-1] = '\0';
            lang=llang;

            /* the language string can be like "es:fr_BE:ga" */
            while (!ret && lang && (*lang)) {
              p=strchr(lang,':');
              if (p) *p++='\0';
              snprintf(langdir,sizeof(langdir),"%s/%s",
                       FORTDIR,lang);

              if (strncmp(path,lang,2) == 0)
                ret=1;
              else if (strncmp(path,langdir,strlen(FORTDIR)+3) == 0)
                ret=1;
              lang=p;
            }
            if (!ret)
              perror(path);
          } else {
            perror(path);
          }
        }

        if (was_malloc)
            free(path);
        return found;
    }

    DPRINTF(2, (stderr, "path = \"%s\"\n", path));

    fp = new_fp();
    fp->fd = fd;
    fp->percent = percent;

    fp->name = do_malloc (strlen (file) + (size_t)1);
    strncpy (fp->name, file, strlen (file) + (size_t)1);

    fp->path = do_malloc (strlen (path) + (size_t)1);
    strncpy (fp->path, path, strlen (path) + 1UL);

    //FIXME
    fp->utf8_charset = FALSE;
    testpath = do_malloc(strlen (path) + 4UL);
    sprintf(testpath, "%s.u8", path);
//    fprintf(stderr, "State mal: %s\n", testpath);
    if(stat(testpath, &statbuf) == 0)
        fp->utf8_charset = TRUE;

    free (testpath);
    testpath = NULL;
//    fprintf(stderr, "Is utf8?: %i\n", fp->utf8_charset );

    fp->parent = parent;

    if ((isdir && !add_dir(fp)) ||
        (!isdir &&
         !is_fortfile(path, &fp->datfile)))
    {
        if (parent == NULL)
            fprintf(stderr,
                    "fortune:%s not a fortune file or directory\n",
                    path);
        if (was_malloc)
            free(path);
        do_free(fp->datfile);
        do_free(fp->posfile);
        do_free(fp->name);
        do_free(fp->path);
        if (fp->fd >= 0) close(fp->fd);
        free(fp);
        return FALSE;
    }

    /* This is a hack to come around another hack - add_dir returns success
     * if the directory is allowed to be empty, but we can not handle an
     * empty directory... */
    if (isdir && fp->num_children == 0) {
        if (was_malloc)
            free(path);
        do_free(fp->datfile);
        do_free(fp->posfile);
        do_free(fp->name);
        do_free(fp->path);
        if(fp->fd >= 0) close(fp->fd);
        free(fp);
        return TRUE;
    }
    /* End hack. */

    if (*head == NULL)
        *head = *tail = fp;
    else if (fp->percent == NO_PROB)
    {
        (*tail)->next = fp;
        fp->prev = *tail;
        *tail = fp;
    }
    else
    {
        (*head)->prev = fp;
        fp->next = *head;
        *head = fp;
    }

    if (was_malloc)
    {
        free(path);
        path = NULL;
    }

    return TRUE;
}

static int names_compare(const void *a, const void *b)
{
    return strcmp(*(const char**)a, *(const char**)b);
}
/*
 * add_dir:
 *      Add the contents of an entire directory.
 */
int add_dir(register FILEDESC * fp)
{
    register DIR *dir;
    register struct dirent *dirent;
    auto FILEDESC *tailp;
    auto char *name;
    char **names;
    size_t i, count_names, max_count_names;

    close(fp->fd);
    fp->fd = -1;
    if ((dir = opendir(fp->path)) == NULL)
    {
        perror(fp->path);
        return FALSE;
    }
    tailp = NULL;
    DPRINTF(1, (stderr, "adding dir \"%s\"\n", fp->path));
    fp->num_children = 0;
    max_count_names = 200;
    count_names = 0;
    names = malloc(sizeof(names[0])*max_count_names);
    if (! names)
    {
        perror("Out of RAM!");
        exit(-1);
    }
    while ((dirent = readdir(dir)) != NULL)
    {
        if (dirent->d_name[0] == 0)
            continue;
        name = strdup(dirent->d_name);
        if (count_names == max_count_names)
        {
            max_count_names += 200;
            names = realloc(names, sizeof(names[0])*max_count_names);
            if (! names)
            {
                perror("Out of RAM!");
                exit(-1);
            }
        }
        names[count_names++] = name;
    }
    closedir(dir);
    qsort(names, count_names, sizeof(names[0]), names_compare);

    for (i=0; i < count_names; ++i)
    {
        if (add_file(NO_PROB, names[i], fp->path, &fp->child, &tailp, fp))
        {
            fp->num_children++;
        }
        free(names[i]);
    }
    free(names);
    dir = NULL;
    if (fp->num_children == 0)
    {
        /*
         * Only the local fortune dir and the local offensive dir are
         * allowed to be empty.
         *  - Brian Bassett (brianb@debian.org) 1999/07/31
         */
        if (strcmp(LOCFORTDIR, fp->path) == 0 || strcmp(LOCOFFDIR, fp->path) == 0)
        {
            return TRUE;
        }
        fprintf(stderr,
                "fortune: %s: No fortune files in directory.\n", fp->path);
        return FALSE;
    }
    return TRUE;
}

/*
 * form_file_list:
 *      Form the file list from the file specifications.
 */
static int form_file_list(register char **files, register int file_cnt)
{
    register int i, percent;
    register char *sp;
    char langdir[512];
    char fullpathname[512],locpathname[512];

    if (file_cnt == 0)
    {
        if (All_forts)
            return (add_file(NO_PROB, LOCFORTDIR, NULL, &File_list,
                             &File_tail, NULL)
                    | add_file(NO_PROB, LOCOFFDIR, NULL, &File_list,
                               &File_tail, NULL)
                    | add_file(NO_PROB, FORTDIR, NULL, &File_list,
                               &File_tail, NULL)
                    | add_file(NO_PROB, OFFDIR, NULL, &File_list,
                               &File_tail, NULL));
        else if (Offend)
            return (add_file(NO_PROB, LOCOFFDIR, NULL, &File_list,
                             &File_tail, NULL)
                    | add_file(NO_PROB, OFFDIR, NULL, &File_list,
                               &File_tail, NULL));
        else {
            if (env_lang) {
                char *lang;
                char llang[512];
                int ret=0;
                char *p;

                strncpy(llang,env_lang,sizeof(llang));
                llang[sizeof(llang)-1] = '\0';
                lang=llang;

                /* the language string can be like "es:fr_BE:ga" */
                while ( lang && (*lang)) {
                        p=strchr(lang,':');
                        if (p) *p++='\0';

                        /* first try full locale */
                        ret=add_file(NO_PROB, lang, NULL, &File_list,
                                &File_tail, NULL);

                        /* if not try language name only (two first chars) */
                        if (!ret) {
                          char ll[3];

                          strncpy(ll,lang,2);
                          ll[2]='\0';
                          ret=add_file(NO_PROB, ll, NULL,
                                       &File_list, &File_tail, NULL);
                        }

                        /* if we have found one we have finished */
                        if (ret)
                          return ret;
                        lang=p;
                }
                /* default */
                return (add_file(NO_PROB, LOCFORTDIR, NULL, &File_list,
                                 &File_tail, NULL)
                        | add_file(NO_PROB, FORTDIR, NULL, &File_list,
                                   &File_tail, NULL));

            }
            else
              /* no locales available, use default */
              return (add_file(NO_PROB, LOCFORTDIR, NULL, &File_list,
                               &File_tail, NULL)
                      | add_file(NO_PROB, FORTDIR, NULL, &File_list,
                                 &File_tail, NULL));

        }
    }

    for (i = 0; i < file_cnt; i++)
    {
        percent = NO_PROB;
        if (!isdigit(files[i][0]))
            sp = files[i];
        else
        {
            percent = 0;
            for (sp = files[i]; isdigit(*sp); sp++)
                percent = percent * 10 + *sp - '0';
            if (percent > 100)
            {
                fprintf(stderr, "percentages must be <= 100\n");
                ErrorMessage = TRUE;
                return FALSE;
            }
            if (*sp == '.')
            {
                fprintf(stderr, "percentages must be integers\n");
                ErrorMessage = TRUE;
                return FALSE;
            }
            /*
             * If the number isn't followed by a '%', then
             * it was not a percentage, just the first part
             * of a file name which starts with digits.
             */
            if (*sp != '%')
            {
                percent = NO_PROB;
                sp = files[i];
            }
            else if (*++sp == '\0')
            {
                if (++i >= file_cnt)
                {
                    fprintf(stderr, "percentages must precede files\n");
                    ErrorMessage = TRUE;
                    return FALSE;
                }
                sp = files[i];
            }
        }
        if (strcmp(sp, "all") == 0)
        {
          snprintf(fullpathname,sizeof(fullpathname),"%s",FORTDIR);
          snprintf(locpathname,sizeof(locpathname),"%s",LOCFORTDIR);
        }
        /* if it isn't an absolute path or relative to . or ..
           make it an absolute path relative to FORTDIR */
        else
        {
            if (strncmp(sp,"/",1)!=0 && strncmp(sp,"./",2)!=0 &&
                    strncmp(sp,"../",3)!=0)
            {
                snprintf(fullpathname,sizeof(fullpathname),
                        "%s/%s",FORTDIR,sp);
                snprintf(locpathname,sizeof(locpathname),
                        "%s/%s",LOCFORTDIR,sp);
            }
            else
            {
                snprintf(fullpathname,sizeof(fullpathname),"%s",sp);
                snprintf(locpathname,sizeof(locpathname),"%s",sp);
            }
        }

        if (env_lang) {
          char *lang;
          char llang[512];
          int ret=0;
          char *p;

          strncpy(llang,env_lang,sizeof(llang));
          llang[sizeof(llang)-1] = '\0';
          lang=llang;

          /* the language string can be like "es:fr_BE:ga" */
          while (!ret && lang && (*lang)) {
            p=strchr(lang,':');
            if (p) *p++='\0';

            /* first try full locale */
            snprintf(langdir,sizeof(langdir),"%s/%s/%s",
                     FORTDIR, lang, sp);
            ret=add_file(percent, langdir, NULL, &File_list,
                         &File_tail, NULL);

            /* if not try language name only (two first chars) */
            if (!ret) {
              char ll[3];

              strncpy(ll,lang,2);
              ll[2]='\0';
              snprintf(langdir,sizeof(langdir),
                       "%s/%s/%s", FORTDIR, ll, sp);
              ret=add_file(percent, langdir, NULL,
                           &File_list, &File_tail, NULL);
            }

            lang=p;
          }
          /* default */
          if (!ret)
            ret=add_file(percent, fullpathname, NULL, &File_list,
                         &File_tail, NULL);
          if ( !ret && strncmp(fullpathname, locpathname, sizeof(fullpathname)))
            ret=add_file(percent, locpathname, NULL, &File_list,
                         &File_tail, NULL);

          if (!ret) {
                  snprintf (locpathname, sizeof (locpathname), "%s/%s", getenv ("PWD"), sp);

                  ret = add_file (percent, locpathname, NULL, &File_list, &File_tail, NULL);
          }
          if (!ret) {
                return FALSE;
          }
          if (strncmp(fullpathname, locpathname, sizeof(fullpathname)) && strcmp(sp, "all") == 0) {
              add_file(percent, locpathname, NULL, &File_list, &File_tail, NULL);
          }
        }
        else
          if (!add_file(percent, fullpathname, NULL, &File_list,
                        &File_tail, NULL))
            return FALSE;
    }
    return TRUE;
}

/*
 *    This routine evaluates the arguments on the command line
 */
static void getargs(int argc, char **argv)
{
    register int ignore_case;

#ifndef NO_REGEX
    register char *pat = NULL;

#endif /* NO_REGEX */
    int ch;

    ignore_case = FALSE;

#ifdef DEBUG
#define DEBUG_GETOPT "D"
#else
#define DEBUG_GETOPT
#endif

#ifdef NO_OFFENSIVE
#define OFFENSIVE_GETOPT
#else
#define OFFENSIVE_GETOPT "o"
#endif

    while ((ch = getopt(argc, argv, "ac" DEBUG_GETOPT "efilm:n:" OFFENSIVE_GETOPT "svw")) != EOF)
        switch (ch)
          {
          case 'a':             /* any fortune */
              All_forts = TRUE;
              break;
#ifdef DEBUG
          case 'D':
              Debug++;
              break;
#endif /* DEBUG */
          case 'e':
              Equal_probs = TRUE;    /* scatter un-allocted prob equally */
              break;
          case 'f':             /* find fortune files */
              Find_files = TRUE;
              break;
          case 'l':             /* long ones only */
              Long_only = TRUE;
              Short_only = FALSE;
              break;
          case 'n':
              SLEN = atoi(optarg);
              break;
#ifndef NO_OFFENSIVE
          case 'o':             /* offensive ones only */
              Offend = TRUE;
              break;
#endif
          case 's':             /* short ones only */
              Short_only = TRUE;
              Long_only = FALSE;
              break;
          case 'w':             /* give time to read */
              Wait = TRUE;
              break;
#ifdef  NO_REGEX
          case 'i':             /* case-insensitive match */
          case 'm':             /* dump out the fortunes */
              (void) fprintf(stderr,
                  "fortune: can't match fortunes on this system (Sorry)\n");
              exit(0);
#else /* NO_REGEX */
          case 'm':             /* dump out the fortunes */
              Match = TRUE;
              pat = optarg;
              break;
          case 'i':             /* case-insensitive match */
              ignore_case++;
              break;
#endif /* NO_REGEX */
          case 'v':
              (void) printf("%s\n", program_version());
              exit(0);
          case 'c':
              Show_filename = TRUE;
              break;
          case '?':
          default:
              usage();
          }
    argc -= optind;
    argv += optind;

    if (!form_file_list(argv, argc))
    {
        if (!ErrorMessage) fprintf (stderr, "No fortunes found\n");
        exit(1);                /* errors printed through form_file_list() */
    }
#ifdef DEBUG
/*      if (Debug >= 1)
 * print_list(File_list, 0); */
#endif /* DEBUG */
/* If (Find_files) print_list() moved to main */
#ifndef NO_REGEX
    if (pat != NULL)
    {
        if (ignore_case)
            pat = conv_pat(pat);
        if (BAD_COMP(RE_COMP(pat)))
        {
            fprintf(stderr, "bad pattern: %s\n", pat);
            exit (1);
        }
        if (ignore_case)
        {
            free(pat);
        }
    }
#endif /* NO_REGEX */
}

/*
 * init_prob:
 *      Initialize the fortune probabilities.
 */
static void init_prob(void)
{
    register FILEDESC *fp, *last;
    register int percent, num_noprob, frac;

    /*
     * Distribute the residual probability (if any) across all
     * files with unspecified probability (i.e., probability of 0)
     * (if any).
     */

    percent = 0;
    num_noprob = 0;
    last = NULL;
    for (fp = File_tail; fp != NULL; fp = fp->prev)
        if (fp->percent == NO_PROB)
        {
            num_noprob++;
            if (Equal_probs)
                last = fp;
        }
        else
            percent += fp->percent;
    DPRINTF(1, (stderr, "summing probabilities:%d%% with %d NO_PROB's\n",
                percent, num_noprob));
    if (percent > 100)
    {
        fprintf(stderr,
                "fortune: probabilities sum to %d%%!\n", percent);
        exit(1);
    }
    else if (percent < 100 && num_noprob == 0)
    {
        fprintf(stderr,
                "fortune: no place to put residual probability (%d%%)\n",
                percent);
        exit(1);
    }
    else if (percent == 100 && num_noprob != 0)
    {
        fprintf(stderr,
                "fortune: no probability left to put in residual files\n");
        exit(1);
    }
    Spec_prob = percent;        /* this is for -f when % is specified on cmd line */
    percent = 100 - percent;
    if (Equal_probs)
    {
        if (num_noprob != 0)
        {
            if (num_noprob > 1)
            {
                frac = percent / num_noprob;
                DPRINTF(1, (stderr, ", frac = %d%%", frac));
                for (fp = File_tail; fp != last; fp = fp->prev)
                    if (fp->percent == NO_PROB)
                    {
                        fp->percent = frac;
                        percent -= frac;
                    }
            }
            last->percent = percent;
            DPRINTF(1, (stderr, ", residual = %d%%", percent));
        }
        else
        {
            DPRINTF(1, (stderr,
                        ", %d%% distributed over remaining fortunes\n",
                        percent));
        }
    }
    DPRINTF(1, (stderr, "\n"));

#ifdef DEBUG
/*      if (Debug >= 1)
     * print_list(File_list, 0); *//* Causes crash with new %% code */
#endif
}

/*
 * zero_tbl:
 *      Zero out the fields we care about in a tbl structure.
 */
static void zero_tbl(register STRFILE * tp)
{
    tp->str_numstr = 0;
    tp->str_longlen = 0;
    tp->str_shortlen = (uint32_t)(-1);
}

/*
 * sum_tbl:
 *      Merge the tbl data of t2 into t1.
 */
static void sum_tbl(register STRFILE * t1, register STRFILE * t2)
{
    t1->str_numstr += t2->str_numstr;
    if (t1->str_longlen < t2->str_longlen)
        t1->str_longlen = t2->str_longlen;
    if (t1->str_shortlen > t2->str_shortlen)
        t1->str_shortlen = t2->str_shortlen;
}

/*
 * get_tbl:
 *      Get the tbl data file the datfile.
 */
static void get_tbl(FILEDESC * fp)
{
    auto int fd;
    register FILEDESC *child;

    if (fp->read_tbl)
        return;
    if (fp->child == NULL)
    {
#if 0
        /* This should not be needed anymore since add_file takes care of
         * empty directories now (Torsten Landschoff <torsten@debian.org>)
         */

        /*
         * Only the local fortune dir and the local offensive dir are
         * allowed to be empty.  Don't try and fetch their tables if
         * they have no children (i.e. are empty).
         *  - Brian Bassett (brianb@debian.org) 1999/07/31
         */
        if (strcmp(LOCFORTDIR, fp->path) == 0 || strcmp(LOCOFFDIR, fp->path) == 0)
        {
            fp->read_tbl = TRUE;        /* Make it look like we've read it. */
            return;
        }
        /* End */
#endif
        if ((fd = open(fp->datfile, O_RDONLY)) < 0)
        {
            perror(fp->datfile);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_version, sizeof fp->tbl.str_version) !=
                sizeof fp->tbl.str_version)
        {
            fprintf(stderr,
                    "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_numstr, sizeof fp->tbl.str_numstr) !=
                sizeof fp->tbl.str_numstr)
        {
            fprintf(stderr,
                    "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_longlen, sizeof fp->tbl.str_longlen) !=
                sizeof fp->tbl.str_longlen)
        {
            fprintf(stderr,
                    "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_shortlen, sizeof fp->tbl.str_shortlen) !=
                sizeof fp->tbl.str_shortlen)
        {
            fprintf(stderr,
                    "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_flags, sizeof fp->tbl.str_flags) !=
                sizeof fp->tbl.str_flags)
        {
            fprintf(stderr,
                    "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.stuff, sizeof fp->tbl.stuff) !=
                sizeof fp->tbl.stuff)
        {
            fprintf(stderr,
                    "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        fp->tbl.str_version = ntohl(fp->tbl.str_version);
        fp->tbl.str_numstr = ntohl(fp->tbl.str_numstr);
        fp->tbl.str_longlen = ntohl(fp->tbl.str_longlen);
        fp->tbl.str_shortlen = ntohl(fp->tbl.str_shortlen);
        fp->tbl.str_flags = ntohl(fp->tbl.str_flags);
        close(fd);
    }
    else
    {
        zero_tbl(&fp->tbl);
        for (child = fp->child; child != NULL; child = child->next)
        {
            get_tbl(child);
            sum_tbl(&fp->tbl, &child->tbl);
        }
    }
    fp->read_tbl = TRUE;
}

/*
 * sum_noprobs:
 *      Sum up all the noprob probabilities, starting with fp.
 */
static void sum_noprobs(register FILEDESC * fp)
{
    static bool did_noprobs = FALSE;

    if (did_noprobs)
        return;
    zero_tbl(&Noprob_tbl);
    while (fp != NULL)
    {
        get_tbl(fp);
        /* This conditional should help us return correct values for -f
         * when a percentage is specified */
        if (fp->percent == NO_PROB)
            sum_tbl(&Noprob_tbl, &fp->tbl);
        fp = fp->next;
    }
    did_noprobs = TRUE;
}

/*
 * pick_child
 *      Pick a child from a chosen parent.
 */
static FILEDESC *pick_child(FILEDESC * parent)
{
    register FILEDESC *fp;
    register int choice;

    if (Equal_probs)
    {
        choice = my_random(parent->num_children);
        DPRINTF(1, (stderr, "    choice = %d (of %d)\n",
                    choice, parent->num_children));
        for (fp = parent->child; choice--; fp = fp->next)
            continue;
        DPRINTF(1, (stderr, "    using %s\n", fp->name));
        return fp;
    }
    else
    {
        get_tbl(parent);
        choice = (int)(my_random(parent->tbl.str_numstr));
        DPRINTF(1, (stderr, "    choice = %d (of %ld)\n",
                    choice, parent->tbl.str_numstr));
        for (fp = parent->child; choice >= (int)fp->tbl.str_numstr;
             fp = fp->next)
        {
            choice -= fp->tbl.str_numstr;
            DPRINTF(1, (stderr, "\tskip %s, %ld (choice = %d)\n",
                        fp->name, fp->tbl.str_numstr, choice));
        }
        DPRINTF(1, (stderr, "    using %s, %ld\n", fp->name,
                    fp->tbl.str_numstr));
        return fp;
    }
}

/*
 * open_dat:
 *      Open up the dat file if we need to.
 */
static void open_dat(FILEDESC * fp)
{
    if (fp->datfd < 0 && (fp->datfd = open(fp->datfile, O_RDONLY)) < 0)
    {
        perror(fp->datfile);
        exit(1);
    }
}

/*
 * get_pos:
 *      Get the position from the pos file, if there is one.  If not,
 *      return a random number.
 */
static void get_pos(FILEDESC * fp)
{
    assert(fp->read_tbl);
    if (fp->pos == POS_UNKNOWN)
    {
        fp->pos = (int32_t)(my_random(fp->tbl.str_numstr));
    }
    if (++(fp->pos) >= (int32_t)fp->tbl.str_numstr)
        fp->pos -= fp->tbl.str_numstr;
    DPRINTF(1, (stderr, "pos for %s is %ld\n", fp->name, fp->pos));
}

/*
 * get_fort:
 *      Get the fortune data file's seek pointer for the next fortune.
 */
static void get_fort(void)
{
    register FILEDESC *fp;
    register int choice;

    if (File_list->next == NULL || File_list->percent == NO_PROB)
        fp = File_list;
    else
    {
        choice = my_random(100);
        DPRINTF(1, (stderr, "choice = %d\n", choice));
        for (fp = File_list; fp->percent != NO_PROB; fp = fp->next)
            if (choice < fp->percent)
                break;
            else
            {
                choice -= fp->percent;
                DPRINTF(1, (stderr,
                            "    skip \"%s\", %d%% (choice = %d)\n",
                            fp->name, fp->percent, choice));
            }
        DPRINTF(1, (stderr,
                    "using \"%s\", %d%% (choice = %d)\n",
                    fp->name, fp->percent, choice));
    }
    if (fp->percent != NO_PROB)
        get_tbl(fp);
    else
    {
        if (fp->next != NULL)
        {
            sum_noprobs(fp);
            choice = (int)(my_random(Noprob_tbl.str_numstr));
            DPRINTF(1, (stderr, "choice = %d (of %ld) \n", choice,
                        Noprob_tbl.str_numstr));
            while (choice >= (int)fp->tbl.str_numstr)
            {
                choice -= (int)fp->tbl.str_numstr;
                fp = fp->next;
                DPRINTF(1, (stderr,
                            "    skip \"%s\", %ld (choice = %d)\n",
                            fp->name, fp->tbl.str_numstr,
                            choice));
            }
            DPRINTF(1, (stderr, "using \"%s\", %ld\n", fp->name,
                        fp->tbl.str_numstr));
        }
        get_tbl(fp);
    }
    if (fp->tbl.str_numstr == 0)
    {
        fprintf(stderr, "fortune: no fortune found\n");
        exit(1);
    }
    if (fp->child != NULL)
    {
        DPRINTF(1, (stderr, "picking child\n"));
        fp = pick_child(fp);
    }
    Fortfile = fp;
    get_pos(fp);
    open_dat(fp);
    lseek(fp->datfd,
          (off_t) (sizeof fp->tbl + (size_t)fp->pos * sizeof Seekpts[0]), 0);
    read(fp->datfd, &Seekpts[0], sizeof Seekpts[0]);
    read(fp->datfd, &Seekpts[1], sizeof Seekpts[1]);
    Seekpts[0] = (int32_t)ntohl((uint32_t)Seekpts[0]);
    Seekpts[1] = (int32_t)ntohl((uint32_t)Seekpts[1]);
}

/*
 * open_fp:
 *      Assocatiate a FILE * with the given FILEDESC.
 */
static void open_fp(FILEDESC * fp)
{
    if (fp->inf == NULL && (fp->inf = fdopen(fp->fd, "r")) == NULL)
    {
        perror(fp->path);
        exit(1);
    }
}

#ifndef NO_REGEX
/*
 * maxlen_in_list
 *      Return the maximum fortune len in the file list.
 */
static int maxlen_in_list(FILEDESC * list)
{
    register FILEDESC *fp;
    register int len, maxlen;

    maxlen = 0;
    for (fp = list; fp != NULL; fp = fp->next)
    {
        if (fp->child != NULL)
        {
            if ((len = maxlen_in_list(fp->child)) > maxlen)
                maxlen = len;
        }
        else
        {
            get_tbl(fp);
            if ((int)fp->tbl.str_longlen > maxlen)
            {
                maxlen = (int)fp->tbl.str_longlen;
            }
        }
    }
    return maxlen;
}

/*
 * matches_in_list
 *      Print out the matches from the files in the list.
 */
static void matches_in_list(FILEDESC * list)
{
    unsigned char *sp;
    unsigned char *p; /* -allover */
    unsigned char ch; /* -allover */
    register FILEDESC *fp;
    int in_file, nchar;
    char *output;

    for (fp = list; fp != NULL; fp = fp->next)
    {
        if (fp->child != NULL)
        {
            matches_in_list(fp->child);
            continue;
        }
        DPRINTF(1, (stderr, "searching in %s\n", fp->path));
        open_fp(fp);
        sp = Fortbuf;
        in_file = FALSE;
        while (fgets((char *)sp, Fort_len, fp->inf) != NULL)
        {
            if (!STR_ENDSTRING(sp, fp->tbl))
            {
                sp += strlen((const char *)sp);
            }
            else
            {
                *sp = '\0';
                nchar = (int)(sp - Fortbuf);

                if (fp->utf8_charset)
                {
                    output = recode_string (request, (const char *)Fortbuf);
                }
                else
                {
                    output = (char *)Fortbuf;
                }
                /* Should maybe rot13 Fortbuf -allover */

                if(fp->tbl.str_flags & STR_ROTATED)
                {
                    for (p = (unsigned char *)output; (ch = *p); ++p)
                    {
                        if (isupper(ch) && isascii(ch))
                            *p = 'A' + (ch - 'A' + 13) % 26;
                        else if (islower(ch) && isascii(ch))
                            *p = 'a' + (ch - 'a' + 13) % 26;
                    }
                }

                DPRINTF(1, (stdout, "nchar = %d\n", nchar));
                if ( (nchar < SLEN || !Short_only) &&
                        (nchar > SLEN || !Long_only) &&
                        RE_EXEC(output) )
                {
                    if (!in_file)
                    {
                        fprintf(stderr, "(%s)\n%c\n", fp->name, fp->tbl.str_delim);
                        Found_one = TRUE;
                        in_file = TRUE;
                    }
                    fputs (output, stdout);
                    printf("%c\n", fp->tbl.str_delim);
                }

                if (fp->utf8_charset)
                  free (output);

                sp = Fortbuf;
            }
        }
    }
}

/*
 * find_matches:
 *      Find all the fortunes which match the pattern we've been given.
 */
static int find_matches(void)
{
    Fort_len = maxlen_in_list(File_list);
    DPRINTF(2, (stderr, "Maximum length is %d\n", Fort_len));
    /* extra length, "%\n" is appended */
    Fortbuf = do_malloc((unsigned int) Fort_len + 10);

    Found_one = FALSE;
    matches_in_list(File_list);
    return Found_one;
    /* NOTREACHED */
}
#endif /* NO_REGEX */

static void display(FILEDESC * fp)
{
    register char *p, ch;
    unsigned char line[BUFSIZ];

    open_fp(fp);
    fseek(fp->inf, (long) Seekpts[0], 0);
    if (Show_filename)
        printf ("(%s)\n%%\n", fp->name);
    for (Fort_len = 0; fgets((char *)line, sizeof line, fp->inf) != NULL &&
         !STR_ENDSTRING(line, fp->tbl); Fort_len++)
    {
        if (fp->tbl.str_flags & STR_ROTATED)
        {
            for (p = (char *)line; (ch = *p); ++p)
            {
                if (isupper(ch) && isascii(ch))
                    *p = 'A' + (ch - 'A' + 13) % 26;
                else if (islower(ch) && isascii (ch))
                    *p = 'a' + (ch - 'a' + 13) % 26;
            }
        }
        if(fp->utf8_charset) {
            char *output;
            output = recode_string (request, (const char *)line);
            fputs(output, stdout);
            free(output);
        }
        else
            fputs((char *)line, stdout);
    }
    fflush(stdout);
}

/*
 * fortlen:
 *      Return the length of the fortune.
 */
static int fortlen(void)
{
    register int nchar;
    char line[BUFSIZ];

    if (!(Fortfile->tbl.str_flags & (STR_RANDOM | STR_ORDERED)))
        nchar = (Seekpts[1] - Seekpts[0]) - 2;  /* for %^J delimiter */
    else
    {
        open_fp(Fortfile);
        fseek(Fortfile->inf, (long) Seekpts[0], 0);
        nchar = 0;
        while (fgets(line, sizeof line, Fortfile->inf) != NULL &&
               !STR_ENDSTRING(line, Fortfile->tbl))
            nchar += strlen(line);
    }
    Fort_len = nchar;
    return nchar;
}

static int max(register int i, register int j)
{
    return (i >= j ? i : j);
}

static void free_desc(FILEDESC *ptr)
{
    while (ptr)
    {
        free_desc(ptr->child);
        do_free(ptr->datfile);
        do_free(ptr->posfile);
        do_free(ptr->name);
        do_free(ptr->path);
        if (ptr->inf)
        {
            fclose(ptr->inf);
            ptr->inf = NULL;
        }
        FILEDESC *next = ptr->next;
        free(ptr);
        ptr = next;
    }
}

int main(int ac, char *av[])
{
    const char *ctype;
    char *crequest;
    int exit_code = 0;

    env_lang=getenv("LC_ALL");
    if (!env_lang) env_lang=getenv("LC_MESSAGES");
    if (!env_lang) env_lang=getenv("LANGUAGE");
    if (!env_lang) env_lang=getenv("LANG");

    getargs(ac, av);

    outer = recode_new_outer(true);
    request = recode_new_request (outer);

    setlocale(LC_ALL,"");
    ctype = nl_langinfo(CODESET);
    if (!ctype || !*ctype)
    {
        ctype = "C";
    }
    else if(strcmp(ctype,"ANSI_X3.4-1968") == 0)
    {
        ctype="ISO-8859-1";
    }

    crequest = malloc(strlen(ctype) + 7 + 1);
    sprintf(crequest, "UTF-8..%s", ctype);
    recode_scan_request (request, crequest);
    free(crequest);

#ifndef NO_REGEX
    if (Match)
    {
        exit_code = (find_matches() != 0);
        regfree(&Re_pat);
        goto cleanup;
    }
#endif
    init_prob();
    if (Find_files)
    {
        sum_noprobs(File_list);
        if (Equal_probs)
            calc_equal_probs();
        print_list(File_list, 0);
    }
    else
    {
        srandom((unsigned int) (time((time_t *) NULL) + getpid()));
        do
        {
            get_fort();
        }
        while ((Short_only && fortlen() > SLEN) ||
            (Long_only && fortlen() <= SLEN));

        display(Fortfile);

        if (Wait)
        {
            fortlen();
            sleep((unsigned int) max(Fort_len / CPERS, MINW));
        }
    }
cleanup:
    recode_delete_request(request);
    recode_delete_outer(outer);

    /* Free the File_list */
    free_desc(File_list);
    free(Fortbuf);
    exit(exit_code);
    /* NOTREACHED */
}
