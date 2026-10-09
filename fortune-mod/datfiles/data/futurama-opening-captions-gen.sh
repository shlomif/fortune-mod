#!/bin/sh

# -------------------------------------------------------------------------
#                                                                         -
#  Created by Fonic <https://github.com/fonic>                            -
#  Date: 10/08/26                                                         -
#                                                                         -
#  Converts Futurama CSV to fortune-mod DAT (POSIX-compatible).           -
#                                                                         -
# -------------------------------------------------------------------------

# Configuration
CSV_DELIMITER="|"
TITLE_TEMPLATE="Futurama:"
QUOTE_TEMPLATE="%s"
SOURCE_TEMPLATE="-- %s \"%s\""
FOOTER_TEMPLATE="%%"
LINE_MAXLEN=78

# Check command line
if [ $# -ne 2 ]; then
	echo "Usage: ${0##*/} INFILE OUTFILE"
	exit 2
fi
infile="$1"
outfile="$2"

# Convert CSV to DAT + wrap long lines + remove trailing whitespace
while IFS="${CSV_DELIMITER}" read -r ssee title quote; do
	printf -- "${TITLE_TEMPLATE}\n"
	printf -- "${QUOTE_TEMPLATE}\n" "${quote}"
	printf -- "${SOURCE_TEMPLATE}\n" "${ssee}" "${title}"
	printf -- "${FOOTER_TEMPLATE}\n"
done < "${infile}" | fold -sw ${LINE_MAXLEN} | sed -e 's/[[:space:]]*$//' > "${outfile}"
