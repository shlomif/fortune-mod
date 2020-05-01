#pragma once

static void input_fn_2_data_fn(void)
{
    if (strlen(input_filename) > COUNT(data_filename) - 10)
    {
        fprintf(stderr, "%s\n", "input filname is too long");
        exit(1);
    }
    /* Hmm.  Don't output anything if we can help it.
     * fprintf(stderr, "Input file: %s\n",input_filename); */
    char *const extc = strrchr(input_filename, '.');
    if (!extc)
    {
        snprintf(data_filename, COUNT(data_filename), "%s.dat", input_filename);
    }
    else
    {
        strncpy(data_filename, input_filename, COUNT(data_filename));
        LAST(data_filename) = '\0';
        *extc = '\0';
    }
}
