#pragma once

static char *input_filename = NULL, output_filename[MAXPATHLEN] = "";
static void set_output_filename(const char *s)
{
    if (s)
    {
        (void)strncpy(output_filename, s, sizeof(output_filename));
        LAST(output_filename) = '\0';
    }
}
