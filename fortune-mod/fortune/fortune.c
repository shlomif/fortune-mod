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

#define PROGRAM_NAME "fortune-mod"

#include "config.h"
#include "fortune-mod-common.h"

#include <dirent.h>
#include <fcntl.h>
#include <assert.h>
#include <errno.h>
#include <locale.h>
#ifndef _WIN32
#include <langinfo.h>
#define O_BINARY 0
#ifdef HAVE_RECODE_H
#define WITH_RECODE
#endif
#endif
#ifdef WITH_RECODE
#include <recode.h>
#endif

#ifdef HAVE_REGEX_H
#include <regex.h>
#endif

#define MINW 6   /* minimum wait if desired */
#define CPERS 20 /* # of chars for each sec */

#define POS_UNKNOWN ((int32_t)-1) /* pos for file unknown */
#define NO_PROB (-1)              /* no prob specified for file */

#ifdef DEBUG
#define DPRINTF(l, x)                                                          \
    if (Debug >= l)                                                            \
        fprintf x;
#else
#define DPRINTF(l, x)
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
} FILEDESC;

static const char *env_lang = NULL;

static bool Found_one = false;   /* did we find a match? */
static bool Find_files = false;  /* just find a list of proper fortune files */
static bool Wait = false;        /* wait desired after fortune */
static bool Short_only = false;  /* short fortune desired */
static bool Long_only = false;   /* long fortune desired */
static bool Offend = false;      /* offensive fortunes only */
static bool All_forts = false;   /* any fortune allowed */
static bool Equal_probs = false; /* scatter un-allocated prob equally */
static bool Show_filename = false;
static bool No_recode = false; /* Do we want to stop recoding from occuring */

static bool ErrorMessage =
    false; /* Set to true if an error message has been displayed */

#ifdef POSIX_REGEX
#define WITH_REGEX
#define RE_COMP(p) regcomp(&Re_pat, (p), REG_NOSUB)
#define BAD_COMP(f) ((f) != 0)
#define RE_EXEC(p) (regexec(&Re_pat, (p), 0, NULL, 0) == 0)

static regex_t Re_pat;
#else
#define NO_REGEX
#endif /* POSIX_REGEX */

#ifdef WITH_REGEX
static bool Match = false; /* dump fortunes matching a pattern */

#endif
#ifdef DEBUG
static bool Debug = false; /* print debug messages */

#endif

static unsigned char *Fortbuf = NULL; /* fortune buffer for -m */

static int Fort_len = 0, Spec_prob = 0, /* total prob specified on cmd line */
    Num_files, Num_kids,                /* totals of files and children. */
    SLEN = 160; /* max. characters in a "short" fortune */

static int32_t Seekpts[2]; /* seek pointers to fortunes */

static FILEDESC *File_list = NULL, /* Head of file list */
    *File_tail = NULL;             /* Tail of file list */
static FILEDESC *Fortfile;         /* Fortune file to use */

static STRFILE Noprob_tbl; /* sum of data for all no prob files */

#ifdef WITH_RECODE
static RECODE_REQUEST request;
static RECODE_OUTER outer;
static inline char *my_recode_string(const char *s)
{
    return recode_string(request, (const char *)s);
}
#else
static inline char *my_recode_string(const char *s) { return strdup(s); }
#endif

int add_dir(FILEDESC *);

static unsigned long my_random(const unsigned long base)
{
    unsigned long long l = 0;
    char *hard_coded_val = getenv("FORTUNE_MOD_RAND_HARD_CODED_VALS");
    if (hard_coded_val)
    {
        return ((unsigned long)atol(hard_coded_val) % base);
    }
    if (getenv("FORTUNE_MOD_USE_SRAND"))
    {
        goto fallback;
    }
    FILE *const fp = fopen("/dev/urandom", "rb");
    if (!fp)
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
    (void)snprintf(buf, sizeof(buf), "%s version %s", PROGRAM_NAME, VERSION);
    return buf;
}

static void __attribute__((noreturn)) usage(void)
{
    (void)fprintf(stderr, "%s\n", program_version());
    (void)fprintf(stderr, "%s", "fortune [-a");
#ifdef DEBUG
    (void)fprintf(stderr, "%s", "D");
#endif /* DEBUG */
    (void)fprintf(stderr, "%s", "f");
#ifdef WITH_REGEX
    (void)fprintf(stderr, "%s", "i");
#endif
    (void)fprintf(stderr, "%s", "l");
#ifndef NO_OFFENSIVE
    (void)fprintf(stderr, "%s", "o");
#endif
    (void)fprintf(stderr, "%s", "sw]");
#ifdef WITH_REGEX
    (void)fprintf(stderr, "%s", " [-m pattern]");
#endif
    (void)fprintf(stderr, "%s", " [-n number] [ [#%] file/directory/all]\n");
    exit(1);
}

#define STR(str) ((!str) ? "NULL" : (str))

/*
 * calc_equal_probs:
 *      Set the global values for number of files/children, to be used
 * in printing probabilities when listing files
 */
static void calc_equal_probs(void)
{
    Num_files = Num_kids = 0;
    FILEDESC *fiddlylist = File_list;
    while (fiddlylist)
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
static void print_list(FILEDESC *list, int lev)
{
    while (list)
    {
        fprintf(stderr, "%*s", lev * 4, "");
        if (list->percent == NO_PROB)
            if (!Equal_probs)
                /* This, with some changes elsewhere, gives proper percentages
                 * for every case fprintf(stderr, "___%%"); */
                fprintf(stderr, "%5.2f%%",
                    (100.0 - Spec_prob) * list->tbl.str_numstr /
                        Noprob_tbl.str_numstr);
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
        if (list->child)
            print_list(list->child, lev + 1);
        list = list->next;
    }
}

#ifdef WITH_REGEX
/*
 * conv_pat:
 *      Convert the pattern to an ignore-case equivalent.
 */
static char *conv_pat(char *orig)
{
    char *sp;
    char *new_buf;

    size_t cnt = 1; /* allow for '\0' */
    for (sp = orig; *sp != '\0'; sp++)
    {
        const size_t prev_cnt = cnt;
        if (isalpha(*sp))
            cnt += 4;
        else
            cnt++;
        if (prev_cnt >= cnt)
        {
            fprintf(stderr, "%s",
                "pattern too long for ignoring case; overflow!\n");
            exit(1);
        }
    }
    if (!(new_buf = malloc(cnt)))
    {
        fprintf(stderr, "%s", "pattern too long for ignoring case\n");
        exit(1);
    }

    for (sp = new_buf; *orig != '\0'; orig++)
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
    return new_buf;
}
#endif

/*
 * do_malloc:
 *      Do a malloc, checking for NULL return.
 */
static void *do_malloc(size_t size)
{
    void *new_buf = malloc(size);

    if (!new_buf)
    {
        (void)fprintf(stderr, "%s", "fortune: out of memory.\n");
        exit(1);
    }
    return new_buf;
}

/*
 * new_fp:
 *      Return a pointer to an initialized new FILEDESC.
 */
static FILEDESC *new_fp(void)
{
    FILEDESC *fp;

    fp = (FILEDESC *)do_malloc(sizeof *fp);
    fp->datfd = -1;
    fp->pos = POS_UNKNOWN;
    fp->inf = NULL;
    fp->fd = -1;
    fp->percent = NO_PROB;
    fp->read_tbl = false;
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

#ifdef MYDEBUG
static inline void debugprint(const char *msg, ...)
{
    va_list ap;

    va_start(ap, msg);
    vfprintf(stderr, msg, ap);
    fflush(stderr);
    va_end(ap);
}
#else
#define debugprint(format, ...)                                                \
    {                                                                          \
    }
#endif
/*
 * is_dir:
 *      Return true if the file is a directory, false otherwise.
 */
static int is_dir(const char *const file)
{
    struct stat sbuf;

    if (stat(file, &sbuf) < 0)
    {
        debugprint("is_dir failed for file=<%s>\n", file);
        return -1;
    }
    const bool ret = (S_ISDIR(sbuf.st_mode) ? true : false);
    debugprint("is_dir for file=<%s> gave ret=<%d>\n", file, ret);
    return ret;
}

/*
 * is_existant:
 *      Return true if the file exists, false otherwise.
 */
static int is_existant(char *file)
{
    struct stat staat;

    if (stat(file, &staat) == 0)
        return true;
    switch (errno)
    {
    case ENOENT:
    case ENOTDIR:
        return false;
    default:
        perror("fortune: bad juju in is_existant");
        exit(1);
    }
}

/*
 * is_fortfile:
 *      Return true if the file is a fortune database file.  We try and
 *      exclude files without reading them if possible to avoid
 *      overhead.  Files which start with ".", or which have "illegal"
 *      suffixes, as contained in suflist[], are ruled out.
 */
static int is_fortfile(const char *const file, char **datp)
{
    const char *sp = strrchr(file, '/');
    static const char *suflist[] = {/* list of "illegal" suffixes" */
        "dat", "pos", "c", "h", "p", "i", "f", "pas", "ftn", "ins.c", "ins,pas",
        "ins.ftn", "sml", NULL};

    DPRINTF(2, (stderr, "is_fortfile(%s) returns ", file));

    if (!sp)
        sp = file;
    else
        sp++;
    if (*sp == '.')
    {
        DPRINTF(2, (stderr, "%s", "false (file starts with '.')\n"));
        return false;
    }
    if ((sp = strrchr(sp, '.')))
    {
        sp++;
        for (int i = 0; suflist[i]; ++i)
            if (strcmp(sp, suflist[i]) == 0)
            {
                DPRINTF(2, (stderr, "false (file has suffix \".%s\")\n", sp));
                return false;
            }
    }

    const size_t do_len = (strlen(file) + 6);
    char *const datfile = do_malloc(do_len + 1);
    snprintf(datfile, do_len, "%s.dat", file);
    if (access(datfile, R_OK) < 0)
    {
        free(datfile);
        DPRINTF(2, (stderr, "%s", "false (no \".dat\" file)\n"));
        return false;
    }
    if (datp)
        *datp = datfile;
    else
        free(datfile);
    DPRINTF(2, (stderr, "%s", "true\n"));
    return true;
}

static bool path_is_absolute(const char *const path)
{
    if (path[0] == '/')
    {
        return true;
    }
#ifdef _WIN32
    if (isalpha(path[0]) && path[1] == ':' && path[2] == '/')
    {
        return true;
    }
#endif
    return false;
}
/*
 * add_file:
 *      Add a file to the file list.
 */
static int add_file(int percent, const char *file, const char *dir,
    FILEDESC **head, FILEDESC **tail, FILEDESC *parent)
{
    FILEDESC *fp;
    int fd = -1;
    char *path;
    char *sp;
    struct stat statbuf;

    if (!dir)
    {
        path = strdup(file);
    }
    else
    {
        const size_t do_len = (strlen(dir) + strlen(file) + 2);
        path = do_malloc(do_len + 1);
        snprintf(path, do_len, "%s/%s", dir, file);
    }
    if (*path == '/' &&
        !is_existant(path)) /* If doesn't exist, don't do anything. */
    {
        free(path);
        return false;
    }
    const int isdir = is_dir(path);
    if ((isdir > 0 && parent) || (isdir < 0))
    {
        free(path);
        return false; /* don't recurse */
    }

    DPRINTF(1, (stderr, "trying to add file \"%s\"\n", path));
    if ((
#ifdef _WIN32
            (!isdir) &&
#endif
            ((fd = open(path, O_RDONLY | O_BINARY)) < 0)) ||
        !path_is_absolute(path))
    {
        debugprint("sarahhhhh fd=%d path=<%s> dir=<%s> file=<%s> percent=%d\n",
            fd, path, dir, file, percent);
        bool found = false;
        if (!dir && (!strchr(file, '/')))
        {
            if (((sp = strrchr(file, '-')) != NULL) && (strcmp(sp, "-o") == 0))
            {
#define CALL__add_file(dir) add_file(percent, file, dir, head, tail, parent)
#define COND_CALL__add_file(loc_dir, dir)                                      \
    ((!strcmp((loc_dir), (dir))) ? 0 : CALL__add_file(dir))
                /* BSD-style '-o' offensive file suffix */
                *sp = '\0';
                found = CALL__add_file(LOCOFFDIR) ||
                        COND_CALL__add_file(LOCOFFDIR, OFFDIR);
                /* put the suffix back in for better identification later */
                *sp = '-';
            }
            else if (All_forts)
                found =
                    (CALL__add_file(LOCFORTDIR) || CALL__add_file(LOCOFFDIR) ||
                        COND_CALL__add_file(LOCFORTDIR, FORTDIR) ||
                        COND_CALL__add_file(LOCOFFDIR, OFFDIR));
            else if (Offend)
                found = (CALL__add_file(LOCOFFDIR) ||
                         COND_CALL__add_file(LOCOFFDIR, OFFDIR));
            else
                found = (CALL__add_file(LOCFORTDIR) ||
                         COND_CALL__add_file(LOCFORTDIR, FORTDIR));
#undef COND_CALL__add_file
#undef CALL__add_file
        }
        if (!found && !parent && !dir)
        { /* don't display an error when trying language specific files */
            if (env_lang)
            {
                char llang[512];
                char langdir[1024];
                int ret = 0;

                strncpy(llang, env_lang, sizeof(llang));
                llang[sizeof(llang) - 1] = '\0';
                char *lang = llang;

                /* the language string can be like "es:fr_BE:ga" */
                while (!ret && lang && (*lang))
                {
                    char *p = strchr(lang, ':');
                    if (p)
                        *p++ = '\0';
                    snprintf(langdir, sizeof(langdir), "%s/%s", FORTDIR, lang);

                    if (strncmp(path, lang, 2) == 0)
                        ret = 1;
                    else if (strncmp(path, langdir, strlen(FORTDIR) + 3) == 0)
                        ret = 1;
                    lang = p;
                }
                if (!ret)
                {
                    debugprint("moshe\n");
                    perror(path);
                }
            }
            else
            {
                debugprint("abe\n");
                perror(path);
            }
        }

        free(path);
        path = NULL;
        return found;
    }

    DPRINTF(2, (stderr, "path = \"%s\"\n", path));

    fp = new_fp();
    fp->fd = fd;
    fp->percent = percent;

    fp->name = strdup(file);
    fp->path = strdup(path);

    // FIXME
    fp->utf8_charset = false;
    const size_t do_len = (strlen(path) + 5);
    char *testpath = do_malloc(do_len + 1);
    snprintf(testpath, do_len, "%s.u8", path);
    //    fprintf(stderr, "State mal: %s\n", testpath);
    if (stat(testpath, &statbuf) == 0)
        fp->utf8_charset = true;

    free(testpath);
    testpath = NULL;
    //    fprintf(stderr, "Is utf8?: %i\n", fp->utf8_charset );

    fp->parent = parent;

    if ((isdir && !add_dir(fp)) || (!isdir && !is_fortfile(path, &fp->datfile)))
    {
        if (!parent)
            fprintf(
                stderr, "fortune:%s not a fortune file or directory\n", path);
        free(path);
        path = NULL;
        free(fp->datfile);
        free(fp->posfile);
        free(fp->name);
        free(fp->path);
        if (fp->fd >= 0)
            close(fp->fd);
        free(fp);
        return false;
    }

    /* This is a hack to come around another hack - add_dir returns success
     * if the directory is allowed to be empty, but we can not handle an
     * empty directory... */
    if (isdir && fp->num_children == 0)
    {
        free(path);
        path = NULL;
        free(fp->datfile);
        free(fp->posfile);
        free(fp->name);
        free(fp->path);
        if (fp->fd >= 0)
            close(fp->fd);
        free(fp);
        return true;
    }
    /* End hack. */

    if (!(*head))
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

    free(path);
    path = NULL;

    return true;
}

static int names_compare(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}
/*
 * add_dir:
 *      Add the contents of an entire directory.
 */
int add_dir(FILEDESC *fp)
{
    DIR *dir;
    struct dirent *dirent;
    char **names;
    size_t i, count_names, max_count_names;

    close(fp->fd);
    fp->fd = -1;
    if (!(dir = opendir(fp->path)))
    {
        debugprint("yonah\n");
        perror(fp->path);
        return false;
    }
    FILEDESC *tailp = NULL;
    DPRINTF(1, (stderr, "adding dir \"%s\"\n", fp->path));
    fp->num_children = 0;
    max_count_names = 200;
    count_names = 0;
    names = malloc(sizeof(names[0]) * max_count_names);
    if (!names)
    {
        debugprint("zach\n");
        perror("Out of RAM!");
        exit(-1);
    }
    while ((dirent = readdir(dir)))
    {
        if (dirent->d_name[0] == 0)
            continue;
        char *name = strdup(dirent->d_name);
        if (count_names == max_count_names)
        {
            max_count_names += 200;
            names = realloc(names, sizeof(names[0]) * max_count_names);
            if (!names)
            {
                debugprint("rebecca\n");
                perror("Out of RAM!");
                exit(-1);
            }
        }
        names[count_names++] = name;
    }
    closedir(dir);
    qsort(names, count_names, sizeof(names[0]), names_compare);

    for (i = 0; i < count_names; ++i)
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
        if (strcmp(LOCFORTDIR, fp->path) == 0 ||
            strcmp(LOCOFFDIR, fp->path) == 0)
        {
            return true;
        }
        fprintf(
            stderr, "fortune: %s: No fortune files in directory.\n", fp->path);
        return false;
    }
    return true;
}

/*
 * form_file_list:
 *      Form the file list from the file specifications.
 */

static int top_level__add_file(const char *dirpath)
{
    return add_file(NO_PROB, dirpath, NULL, &File_list, &File_tail, NULL);
}

static int cond_top_level__add_file(
    const char *dirpath, const char *possible_dup)
{
    if (!strcmp(dirpath, possible_dup))
    {
        return 0;
    }
    return top_level__add_file(dirpath);
}

static int cond_top_level__LOCFORTDIR(void)
{
    return cond_top_level__add_file(FORTDIR, LOCFORTDIR);
}

static int cond_top_level__OFFDIR(void)
{
    return cond_top_level__add_file(OFFDIR, LOCOFFDIR);
}

static int top_level_LOCFORTDIR(void)
{
    return (top_level__add_file(LOCFORTDIR) | cond_top_level__LOCFORTDIR());
}

static int form_file_list(char **files, int file_cnt)
{
    int i, percent;
    char *sp;
    char langdir[1024];
    char fullpathname[512], locpathname[512];

    if (file_cnt == 0)
    {
        if (All_forts)
        {
            return (top_level__add_file(LOCFORTDIR) |
                    top_level__add_file(LOCOFFDIR) |
                    cond_top_level__LOCFORTDIR() | cond_top_level__OFFDIR());
        }
        else if (Offend)
        {
            return (top_level__add_file(LOCOFFDIR) | cond_top_level__OFFDIR());
        }
        else
        {
            if (env_lang)
            {
                char *lang;
                char llang[512];
                int ret = 0;
                char *p;

                strncpy(llang, env_lang, sizeof(llang));
                llang[sizeof(llang) - 1] = '\0';
                lang = llang;

                /* the language string can be like "es:fr_BE:ga" */
                while (lang && (*lang))
                {
                    p = strchr(lang, ':');
                    if (p)
                        *p++ = '\0';

                    /* first try full locale */
                    ret = add_file(
                        NO_PROB, lang, NULL, &File_list, &File_tail, NULL);

                    /* if not try language name only (two first chars) */
                    if (!ret)
                    {
                        char ll[3];

                        strncpy(ll, lang, 2);
                        ll[2] = '\0';
                        ret = add_file(
                            NO_PROB, ll, NULL, &File_list, &File_tail, NULL);
                    }

                    /* if we have found one we have finished */
                    if (ret)
                        return ret;
                    lang = p;
                }
                /* default */
                return top_level_LOCFORTDIR();
            }
            else
            {
                /* no locales available, use default */
                return top_level_LOCFORTDIR();
            }
        }
    }

    for (i = 0; i < file_cnt; i++)
    {
        percent = NO_PROB;
        if (!isdigit(files[i][0]))
            sp = files[i];
        else
        {
            const int MAX_PERCENT = 100;
            bool percent_has_overflowed = false;
            percent = 0;
            for (sp = files[i]; isdigit(*sp); sp++)
            {
                percent = percent * 10 + *sp - '0';
                percent_has_overflowed = (percent > MAX_PERCENT);
                if (percent_has_overflowed)
                {
                    break;
                }
            }
            if (percent_has_overflowed || (percent > 100))
            {
                fprintf(stderr, "percentages must be <= 100\n");
                fprintf(stderr,
                    "Overflow percentage detected at argument \"%s\"!\n",
                    files[i]);
                ErrorMessage = true;
                return false;
            }
            if (percent < 0)
            {
                fprintf(stderr,
                    "Overflow percentage detected at argument \"%s\"!\n",
                    files[i]);
                ErrorMessage = true;
                return false;
            }
            if (*sp == '.')
            {
                fprintf(stderr, "%s", "percentages must be integers\n");
                ErrorMessage = true;
                return false;
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
                    fprintf(stderr, "%s", "percentages must precede files\n");
                    ErrorMessage = true;
                    return false;
                }
                sp = files[i];
            }
        }
        if (strcmp(sp, "all") == 0)
        {
            snprintf(fullpathname, sizeof(fullpathname), "%s", FORTDIR);
            snprintf(locpathname, sizeof(locpathname), "%s", LOCFORTDIR);
        }
        /* if it isn't an absolute path or relative to . or ..
           make it an absolute path relative to FORTDIR */
        else
        {
            if (strncmp(sp, "/", 1) != 0 && strncmp(sp, "./", 2) != 0 &&
                strncmp(sp, "../", 3) != 0)
            {
                snprintf(
                    fullpathname, sizeof(fullpathname), "%s/%s", FORTDIR, sp);
                snprintf(
                    locpathname, sizeof(locpathname), "%s/%s", LOCFORTDIR, sp);
            }
            else
            {
                snprintf(fullpathname, sizeof(fullpathname), "%s", sp);
                snprintf(locpathname, sizeof(locpathname), "%s", sp);
            }
        }

        if (env_lang)
        {
            char llang[512];
            int ret = 0;

            strncpy(llang, env_lang, sizeof(llang));
            llang[sizeof(llang) - 1] = '\0';
            char *lang = llang;

            /* the language string can be like "es:fr_BE:ga" */
            while (!ret && lang && (*lang))
            {
                char *p = strchr(lang, ':');
                if (p)
                    *p++ = '\0';

                /* first try full locale */
                snprintf(
                    langdir, sizeof(langdir), "%s/%s/%s", FORTDIR, lang, sp);
                ret = add_file(
                    percent, langdir, NULL, &File_list, &File_tail, NULL);

                /* if not try language name only (two first chars) */
                if (!ret)
                {
                    char ll[3];

                    strncpy(ll, lang, 2);
                    ll[2] = '\0';
                    snprintf(
                        langdir, sizeof(langdir), "%s/%s/%s", FORTDIR, ll, sp);
                    ret = add_file(
                        percent, langdir, NULL, &File_list, &File_tail, NULL);
                }

                lang = p;
            }
            /* default */
            if (!ret)
                ret = add_file(
                    percent, fullpathname, NULL, &File_list, &File_tail, NULL);
            if (!ret &&
                strncmp(fullpathname, locpathname, sizeof(fullpathname)))
                ret = add_file(
                    percent, locpathname, NULL, &File_list, &File_tail, NULL);

            if (!ret)
            {
                snprintf(locpathname, sizeof(locpathname), "%s/%s",
                    getenv("PWD"), sp);

                ret = add_file(
                    percent, locpathname, NULL, &File_list, &File_tail, NULL);
            }
            if (!ret)
            {
                return false;
            }
            if (strncmp(fullpathname, locpathname, sizeof(fullpathname)) &&
                strcmp(sp, "all") == 0)
            {
                add_file(
                    percent, locpathname, NULL, &File_list, &File_tail, NULL);
            }
        }
        else if (!add_file(
                     percent, fullpathname, NULL, &File_list, &File_tail, NULL))
            return false;
    }
    return true;
}

/*
 *    This routine evaluates the arguments on the command line
 */
static void getargs(int argc, char **argv)
{
    bool ignore_case = false;

#ifdef WITH_REGEX
    char *pat = NULL;
#endif

    int ch;

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

    while ((ch = getopt(argc, argv,
                "ac" DEBUG_GETOPT "efilm:n:" OFFENSIVE_GETOPT "suvw")) != EOF)
        switch (ch)
        {
        case 'a': /* any fortune */
            All_forts = true;
            break;
#ifdef DEBUG
        case 'D':
            Debug++;
            break;
#endif /* DEBUG */
        case 'e':
            Equal_probs = true; /* scatter un-allocted prob equally */
            break;
        case 'f': /* find fortune files */
            Find_files = true;
            break;
        case 'l': /* long ones only */
            Long_only = true;
            Short_only = false;
            break;
        case 'n':
            SLEN = atoi(optarg);
            break;
#ifndef NO_OFFENSIVE
        case 'o': /* offensive ones only */
            Offend = true;
            break;
#endif
        case 's': /* short ones only */
            Short_only = true;
            Long_only = false;
            break;
        case 'w': /* give time to read */
            Wait = true;
            break;
#ifdef NO_REGEX
        case 'i': /* case-insensitive match */
        case 'm': /* dump out the fortunes */
            (void)fprintf(stderr, "%s",
                "fortune: can't match fortunes on this system (Sorry)\n");
            exit(0);
#else             /* NO_REGEX */
        case 'm': /* dump out the fortunes */
            Match = true;
            pat = optarg;
            break;
        case 'i': /* case-insensitive match */
            ignore_case = true;
            break;
#endif            /* NO_REGEX */
        case 'u': /* Don't recode the fortune */
            No_recode = true;
            break;
        case 'v':
            (void)printf("%s\n", program_version());
            exit(0);
        case 'c':
            Show_filename = true;
            break;
        case '?':
        default:
            usage();
        }
    argc -= optind;
    argv += optind;

    if (!form_file_list(argv, argc))
    {
        if (!ErrorMessage)
        {
            fprintf(stderr, "%s", "No fortunes found\n");
        }
        exit(1); /* errors printed through form_file_list() */
    }
#ifdef DEBUG
/*      if (Debug >= 1)
 * print_list(File_list, 0); */
#endif /* DEBUG */

/* If (Find_files) print_list() moved to main */
#ifdef WITH_REGEX
    if (pat)
    {
        if (ignore_case)
            pat = conv_pat(pat);
        if (BAD_COMP(RE_COMP(pat)))
        {
            fprintf(stderr, "bad pattern: %s\n", pat);
            exit(1);
        }
        if (ignore_case)
        {
            free(pat);
        }
    }
#endif
}

/*
 * init_prob:
 *      Initialize the fortune probabilities.
 */
static void init_prob(void)
{
    FILEDESC *fp;
    int percent = 0, num_noprob = 0, frac;

    /*
     * Distribute the residual probability (if any) across all
     * files with unspecified probability (i.e., probability of 0)
     * (if any).
     */
    FILEDESC *last = NULL;
    for (fp = File_tail; fp; fp = fp->prev)
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
        fprintf(stderr, "fortune: probabilities sum to %d%%!\n", percent);
        exit(1);
    }
    else if (percent < 100 && num_noprob == 0)
    {
        fprintf(stderr,
            "fortune: no place to put residual probability (%d%%)\n", percent);
        exit(1);
    }
    else if (percent == 100 && num_noprob != 0)
    {
        fprintf(
            stderr, "fortune: no probability left to put in residual files\n");
        exit(1);
    }
    Spec_prob = percent; /* this is for -f when % is specified on cmd line */
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
            DPRINTF(1, (stderr, ", %d%% distributed over remaining fortunes\n",
                           percent));
        }
    }
    DPRINTF(1, (stderr, "%s", "\n"));

#ifdef DEBUG
/*      if (Debug >= 1)
 * print_list(File_list, 0); *//* Causes crash with new %% code */
#endif
}

/*
 * zero_tbl:
 *      Zero out the fields we care about in a tbl structure.
 */
static void zero_tbl(STRFILE *tp)
{
    tp->str_numstr = 0;
    tp->str_longlen = 0;
    tp->str_shortlen = (uint32_t)(-1);
}

/*
 * sum_tbl:
 *      Merge the tbl data of t2 into t1.
 */
static void sum_tbl(STRFILE *t1, STRFILE *t2)
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
static void get_tbl(FILEDESC *fp)
{
    int fd;
    FILEDESC *child;

    if (fp->read_tbl)
        return;
    if (!(fp->child))
    {
        if ((fd = open(fp->datfile, O_RDONLY | O_BINARY)) < 0)
        {
            perror(fp->datfile);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_version, sizeof fp->tbl.str_version) !=
            sizeof fp->tbl.str_version)
        {
            fprintf(stderr, "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_numstr, sizeof fp->tbl.str_numstr) !=
            sizeof fp->tbl.str_numstr)
        {
            fprintf(stderr, "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_longlen, sizeof fp->tbl.str_longlen) !=
            sizeof fp->tbl.str_longlen)
        {
            fprintf(stderr, "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_shortlen, sizeof fp->tbl.str_shortlen) !=
            sizeof fp->tbl.str_shortlen)
        {
            fprintf(stderr, "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.str_flags, sizeof fp->tbl.str_flags) !=
            sizeof fp->tbl.str_flags)
        {
            fprintf(stderr, "fortune: %s corrupted\n", fp->path);
            exit(1);
        }
        if (read(fd, &fp->tbl.stuff, sizeof fp->tbl.stuff) !=
            sizeof fp->tbl.stuff)
        {
            fprintf(stderr, "fortune: %s corrupted\n", fp->path);
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
        for (child = fp->child; child; child = child->next)
        {
            get_tbl(child);
            sum_tbl(&fp->tbl, &child->tbl);
        }
    }
    fp->read_tbl = true;
}

/*
 * sum_noprobs:
 *      Sum up all the noprob probabilities, starting with fp.
 */
static void sum_noprobs(FILEDESC *fp)
{
    static bool did_noprobs = false;

    if (did_noprobs)
        return;
    zero_tbl(&Noprob_tbl);
    while (fp)
    {
        get_tbl(fp);
        /* This conditional should help us return correct values for -f
         * when a percentage is specified */
        if (fp->percent == NO_PROB)
            sum_tbl(&Noprob_tbl, &fp->tbl);
        fp = fp->next;
    }
    did_noprobs = true;
}

/*
 * pick_child
 *      Pick a child from a chosen parent.
 */
static FILEDESC *pick_child(FILEDESC *parent)
{
    FILEDESC *fp;
    int choice;

    if (Equal_probs)
    {
        choice = my_random(parent->num_children);
        DPRINTF(1, (stderr, "    choice = %d (of %d)\n", choice,
                       parent->num_children));
        for (fp = parent->child; choice--; fp = fp->next)
            continue;
        DPRINTF(1, (stderr, "    using %s\n", fp->name));
        return fp;
    }
    else
    {
        get_tbl(parent);
        choice = (int)(my_random(parent->tbl.str_numstr));
        DPRINTF(1, (stderr, "    choice = %d (of %ld)\n", choice,
                       parent->tbl.str_numstr));
        for (fp = parent->child; choice >= (int)fp->tbl.str_numstr;
             fp = fp->next)
        {
            choice -= fp->tbl.str_numstr;
            DPRINTF(1, (stderr, "\tskip %s, %ld (choice = %d)\n", fp->name,
                           fp->tbl.str_numstr, choice));
        }
        DPRINTF(
            1, (stderr, "    using %s, %ld\n", fp->name, fp->tbl.str_numstr));
        return fp;
    }
}

/*
 * open_dat:
 *      Open up the dat file if we need to.
 */
static void open_dat(FILEDESC *fp)
{
    if (fp->datfd < 0 &&
        (fp->datfd = open(fp->datfile, O_RDONLY | O_BINARY)) < 0)
    {
        exit(1);
    }
}

/*
 * get_pos:
 *      Get the position from the pos file, if there is one.  If not,
 *      return a random number.
 */
static void get_pos(FILEDESC *fp)
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
    FILEDESC *fp;
    int choice;

    if (!File_list->next || File_list->percent == NO_PROB)
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
                DPRINTF(1, (stderr, "    skip \"%s\", %d%% (choice = %d)\n",
                               fp->name, fp->percent, choice));
            }
        DPRINTF(1, (stderr, "using \"%s\", %d%% (choice = %d)\n", fp->name,
                       fp->percent, choice));
    }
    if (fp->percent != NO_PROB)
        get_tbl(fp);
    else
    {
        if (fp->next)
        {
            sum_noprobs(fp);
            choice = (int)(my_random(Noprob_tbl.str_numstr));
            DPRINTF(1, (stderr, "choice = %d (of %ld) \n", choice,
                           Noprob_tbl.str_numstr));
            while (choice >= (int)fp->tbl.str_numstr)
            {
                choice -= (int)fp->tbl.str_numstr;
                fp = fp->next;
                DPRINTF(1, (stderr, "    skip \"%s\", %ld (choice = %d)\n",
                               fp->name, fp->tbl.str_numstr, choice));
            }
            DPRINTF(1,
                (stderr, "using \"%s\", %ld\n", fp->name, fp->tbl.str_numstr));
        }
        get_tbl(fp);
    }
    if (fp->tbl.str_numstr == 0)
    {
        fprintf(stderr, "%s", "fortune: no fortune found\n");
        exit(1);
    }
    if (fp->child)
    {
        DPRINTF(1, (stderr, "%s", "picking child\n"));
        fp = pick_child(fp);
    }
    Fortfile = fp;
    get_pos(fp);
    open_dat(fp);
    lseek(fp->datfd,
        (off_t)(sizeof fp->tbl + (size_t)fp->pos * sizeof Seekpts[0]), 0);
    if ((read(fp->datfd, &Seekpts[0], sizeof Seekpts[0]) < 0) ||
        (read(fp->datfd, &Seekpts[1], sizeof Seekpts[1]) < 0))
    {
        exit(1);
    }
    Seekpts[0] = (int32_t)ntohl((uint32_t)Seekpts[0]);
    Seekpts[1] = (int32_t)ntohl((uint32_t)Seekpts[1]);
}

/*
 * open_fp:
 *      Assocatiate a FILE * with the given FILEDESC.
 */
static void open_fp(FILEDESC *fp)
{
    if (!fp->inf && !(fp->inf = fdopen(fp->fd, "r")))
    {
        perror(fp->path);
        exit(1);
    }
}

#ifdef WITH_REGEX
/*
 * maxlen_in_list
 *      Return the maximum fortune len in the file list.
 */
static int maxlen_in_list(FILEDESC *list)
{
    FILEDESC *fp;
    int len, maxlen = 0;

    for (fp = list; fp; fp = fp->next)
    {
        if (fp->child)
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
static void matches_in_list(FILEDESC *list)
{
    unsigned char *sp;
    unsigned char *p; /* -allover */
    unsigned char ch; /* -allover */
    FILEDESC *fp;
    int in_file, nchar;
    char *output;

    for (fp = list; fp; fp = fp->next)
    {
        if (fp->child)
        {
            matches_in_list(fp->child);
            continue;
        }
        DPRINTF(1, (stderr, "searching in %s\n", fp->path));
        open_fp(fp);
        sp = Fortbuf;
        in_file = false;
        while (fgets((char *)sp, Fort_len, fp->inf))
        {
            if (!STR_ENDSTRING(sp, fp->tbl))
            {
                sp += strlen((const char *)sp);
            }
            else
            {
                *sp = '\0';
                nchar = (int)(sp - Fortbuf);

                if (fp->utf8_charset && (!No_recode))
                {
                    output = my_recode_string((const char *)Fortbuf);
                }
                else
                {
                    output = (char *)Fortbuf;
                }
                /* Should maybe rot13 Fortbuf -allover */

                if (fp->tbl.str_flags & STR_ROTATED)
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
                if ((nchar < SLEN || !Short_only) &&
                    (nchar > SLEN || !Long_only) && RE_EXEC(output))
                {
                    if (!in_file)
                    {
                        fprintf(
                            stderr, "(%s)\n%c\n", fp->name, fp->tbl.str_delim);
                        Found_one = true;
                        in_file = true;
                    }
                    fputs(output, stdout);
                    printf("%c\n", fp->tbl.str_delim);
                }

                if (fp->utf8_charset && (!No_recode))
                {
                    free(output);
                    output = NULL;
                }

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
    Fortbuf = do_malloc((unsigned int)Fort_len + 10);

    Found_one = false;
    matches_in_list(File_list);
    return Found_one;
    /* NOTREACHED */
}
#endif

static void display(FILEDESC *fp)
{
    char *p, ch;
    unsigned char line[BUFSIZ];

    open_fp(fp);
    fseek(fp->inf, (long)Seekpts[0], SEEK_SET);
    if (Show_filename)
        printf("(%s)\n%%\n", fp->name);
    for (Fort_len = 0; fgets((char *)line, sizeof line, fp->inf) &&
                       !STR_ENDSTRING(line, fp->tbl);
         Fort_len++)
    {
        if (fp->tbl.str_flags & STR_ROTATED)
        {
            for (p = (char *)line; (ch = *p); ++p)
            {
                if (isupper(ch) && isascii(ch))
                    *p = 'A' + (ch - 'A' + 13) % 26;
                else if (islower(ch) && isascii(ch))
                    *p = 'a' + (ch - 'a' + 13) % 26;
            }
        }
        if (fp->utf8_charset && (!No_recode))
        {
            char *output = my_recode_string((const char *)line);
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
    int nchar;
    char line[BUFSIZ];

    if (!(Fortfile->tbl.str_flags & (STR_RANDOM | STR_ORDERED)))
        nchar = (Seekpts[1] - Seekpts[0]) - 2; /* for %^J delimiter */
    else
    {
        open_fp(Fortfile);
        fseek(Fortfile->inf, (long)Seekpts[0], SEEK_SET);
        nchar = 0;
        while (fgets(line, sizeof line, Fortfile->inf) &&
               !STR_ENDSTRING(line, Fortfile->tbl))
            nchar += strlen(line);
    }
    Fort_len = nchar;
    return nchar;
}

static int mymax(int i, int j) { return (i >= j ? i : j); }

static void free_desc(FILEDESC *ptr)
{
    while (ptr)
    {
        free_desc(ptr->child);
        free(ptr->datfile);
        free(ptr->posfile);
        free(ptr->name);
        free(ptr->path);
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
#ifdef WITH_RECODE
    const char *ctype;
#endif

    int exit_code = 0;
    env_lang = getenv("LC_ALL");
    if (!env_lang)
        env_lang = getenv("LC_MESSAGES");
    if (!env_lang)
        env_lang = getenv("LANGUAGE");
    if (!env_lang)
        env_lang = getenv("LANG");
#ifdef _WIN32
    if (!env_lang)
    {
        env_lang = "en";
    }
#endif

#ifndef DONT_CALL_GETARGS
    getargs(ac, av);
#endif

#ifdef WITH_RECODE
    outer = recode_new_outer(true);
    request = recode_new_request(outer);
#endif

    setlocale(LC_ALL, "");

#ifdef WITH_RECODE
#ifdef _WIN32
    ctype = "C";
#else
    ctype = nl_langinfo(CODESET);
    if (!ctype || !*ctype)
    {
        ctype = "C";
    }
    else if (strcmp(ctype, "ANSI_X3.4-1968") == 0)
    {
        ctype = "ISO-8859-1";
    }
#endif
    const size_t do_len = strlen(ctype) + 7 + 1;
    char *crequest = do_malloc(do_len + 1);
    snprintf(crequest, do_len, "UTF-8..%s", ctype);
    recode_scan_request(request, crequest);
    free(crequest);
#endif

#ifdef WITH_REGEX
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
        srandom((unsigned int)(time((time_t *)NULL) + getpid()));
        do
        {
            get_fort();
        } while ((Short_only && fortlen() > SLEN) ||
                 (Long_only && fortlen() <= SLEN));

        display(Fortfile);

        if (Wait)
        {
            fortlen();
            sleep((unsigned int)mymax(Fort_len / CPERS, MINW));
        }
    }
cleanup:
#ifdef WITH_RECODE
    recode_delete_request(request);
    recode_delete_outer(outer);
#endif

    /* Free the File_list */
    free_desc(File_list);
    free(Fortbuf);
    exit(exit_code);
}
