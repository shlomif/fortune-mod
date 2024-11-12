#! /usr/bin/python
'''

python3 util/find_duplicate_fortunes.py \
    $(git ls ./datfiles/ | grep -vE 'CMa|/data/' |
    perl -E '@l=(<>);sub aa{return shift()=~m#^datfiles/off#ms;};
    @o=sort{(aa($a)<=>aa($b)) or ($a cmp $b)}@l;say@o;'
    )

'''
import sys

locations_by_text = {}

for filename in sys.argv:
    with open(filename) as fh:
        text = ""
        startlineno = 1

        for lineno, line in enumerate(fh, 1):
            if line == "%\n":
                if text not in locations_by_text:
                    locations_by_text[text] = []
                locations_by_text[text].append((filename, startlineno, lineno))
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
