#! /usr/bin/python

# Copyright (c) 2024 Ingo van Lil ( https://github.com/inguin )
# Author: Ingo van Lil ( https://github.com/inguin )
# Author: Shlomi Fish ( https://www.shlomifish.org/ )
#

import subprocess
import sys

'''

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

'''

'''

python3 util/find_duplicate_fortunes.py \
    $(git ls ./datfiles/ | grep -vE 'CMa|/data/' |
    perl -E '@l=(<>);sub aa{return shift()=~m#^datfiles/off#ms;};
    @o=sort{(aa($a)<=>aa($b)) or ($a cmp $b)}@l;say@o;'
    )

'''


def files_processing_transaction(filenames_list):
    """docstring for files_processing_transaction"""

    locations_by_text = {}

    for filename in filenames_list:
        with open(filename) as fh:
            text = ""
            startlineno = 1

            for lineno, line in enumerate(fh, 1):
                if line == "%\n":
                    if text not in locations_by_text:
                        locations_by_text[text] = []
                    locations_by_text[text].append(
                        (filename, startlineno, lineno)
                    )
                    text = ""
                    startlineno = lineno + 1
                else:
                    text += line

            if text:
                if text not in locations_by_text:
                    locations_by_text[text] = []
                locations_by_text[text].append((filename, startlineno, lineno))

    byfn = {}
    for text, locations in locations_by_text.items():
        if len(locations) > 1:
            print(f"Multiple occurrences of '{text.__repr__()[:60]}':")
            for filename, startlineno, lineno in locations[1:]:
                if filename not in byfn:
                    byfn[filename] = []
                byfn[filename].append((startlineno, lineno))
                # print(f"{filename}:{startlineno}:{lineno}")

    for filename, matches in byfn.items():
        m = list(reversed(sorted(matches)))
        print(filename, m)
        with open(filename) as fh:
            lines = fh.readlines()
        for start, end in m:
            lines = lines[:(start - 1)] + lines[(end+0):]
        with open(filename, "wt") as fh:
            for li in lines:
                fh.write(li)


if sys.argv[1:] == ['--fortune-mod-dwim']:
    cmd = ("git ls ./datfiles/ | grep -vE 'CMa|/data/' |"
           "perl -E '@l=(<>);sub aa{return shift()=~m#^datfiles/off#ms;};"
           "@o=sort{(aa($a)<=>aa($b)) or ($a cmp $b)}@l;say@o;'")
    outputbytes = subprocess.check_output(cmd, shell=True)
    output = outputbytes.decode('utf-8')
    filenames_list = output.split("\n")
    # print(filenames_list)
    filenames_list = [x for x in filenames_list if len(x) > 0]
    files_processing_transaction(filenames_list=filenames_list)
else:
    files_processing_transaction(filenames_list=sys.argv)
