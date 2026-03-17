#!/usr/bin/python

import re
import sys

# Correctly formatted attribution: double tabs + double dashes, and remainder indented
GOOD_ATTRIBUTION_RE = r"\n\t\t-- [^\n ][^\n]*(\n\t\t   [^\n]*)*$"

# Incorrect formatted attribution: Whitespace or incorrect numbers of dashes
BAD_ATTRIBUTION_SPACING_RE = r"\n[\t ]*--? *([^\n]*[a-zA-Z.]{2,}[^\n]*)$"
BAD_ATTRIBUTION_DASHES_RE = r"\n\t\t(-|-{3,}) *([^-\n][^\n]*[a-zA-Z.]{2,}[^\n]*)$"


def process(fortune: str) -> str:
    if re.search(GOOD_ATTRIBUTION_RE, fortune):
        return fortune
    if re.search(BAD_ATTRIBUTION_SPACING_RE, fortune):
        return re.sub(BAD_ATTRIBUTION_SPACING_RE, "\n\t\t-- \\g<1>", fortune)
    if re.search(BAD_ATTRIBUTION_DASHES_RE, fortune):
        return re.sub(BAD_ATTRIBUTION_DASHES_RE, "\n\t\t-- \\g<2>", fortune)
    return fortune


def main() -> None:
    current = list[str]()
    with open(sys.argv[1], "r", encoding="utf-8") as in_file:
        for line in in_file:
            if line == "%\n":
                print(process("".join(current)), line, end="", sep="")
                current.clear()
            else:
                current.append(line)
    assert not current, "Last line must be a single %."
    # Another script already ensures this


main()
