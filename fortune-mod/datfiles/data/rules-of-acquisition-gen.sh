#!/bin/sh

# -------------------------------------------------------------------------
#                                                                         -
#  Created by Fonic <https://github.com/fonic>                            -
#  Date: 12/28/21                                                         -
#                                                                         -
# -------------------------------------------------------------------------

# Configuration
CSV_DELIMITER="|"
TITLE_TEMPLATE="Ferengi Rule of Acquisition %s:"
RULE_TEMPLATE="%s"
SOURCE_TEMPLATE="-- %s"
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
while IFS="${CSV_DELIMITER}" read -r number rule source; do
	printf -- "${TITLE_TEMPLATE}\n" "${number}"
	printf -- "${RULE_TEMPLATE}\n" "${rule}"
	printf -- "${SOURCE_TEMPLATE}\n" "${source}"
	printf -- "${FOOTER_TEMPLATE}\n"
done < "${infile}" | fold -sw ${LINE_MAXLEN} | sed -e 's/[[:space:]]*$//' > "${outfile}"
