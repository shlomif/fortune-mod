#pragma once

static void input_fn_2_data_fn(void)
{
    if (strlen(input_filename) > COUNT(data_filename) - 10)
    {
        perror("input is too long");
        exit(1);
    }
    /* Hmm.  Don't output anything if we can help it.
     * fprintf(stderr, "Input file: %s\n",input_filename); */
    char *const extc = strrchr(input_filename, '.');
    if (!extc)
    {
        sprintf(data_filename, "%s.dat", input_filename);
    }
    else
    {
        strcpy(data_filename, input_filename);
        *extc = '\0';
    }
}
