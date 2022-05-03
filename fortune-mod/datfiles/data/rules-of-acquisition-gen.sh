#!/bin/sh

# -------------------------------------------------------------------------
#                                                                         -
#  Created by Fonic <https://github.com/fonic>                            -
#  Date: 12/28/21                                                         -
#                                                                         -
# -------------------------------------------------------------------------

# Configuration
csv_delimiter="|"
title_template="Ferengi Rule of Acquisition %s:"
rule_template="%s"
source_template="-- %s"
footer_template="%%"
line_maxlen=78

# Check command line
infile="$1"
shift
outfile="$1"
shift
if test "$#" -ne 0
then
	echo "Usage: $0 INFILE OUTFILE"
	exit 2
fi

format="${title_template}\\n${rule_template}\\n${source_template}\\n${footer_template}\\n"

# Convert CSV to DAT + wrap long lines + remove trailing whitespace
while IFS="${csv_delimiter}" read -r number rule source
do
	printf -- "${format}" "${number}" "${rule}" "${source}"
done < "${infile}" | fold -sw "${line_maxlen}" | sed -e 's/[[:space:]]*$//' > "${outfile}"
