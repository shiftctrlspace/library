#!/bin/bash -
#
# File:        scan-library.sh
#
# Description: A utility that receives a path to a Calibre Library and
#              scans significant (non-metadata) files in the directory
#              using the VirusTotal API. "Significant" files are files
#              like PDF, ePub, etc., i.e., not `.opf` or `.db` files.
#
# Examples:    Use `scan-library.sh` to scan the Calibre Library in a
#              user's `Documents` folder:
#
#                  scan-library.sh "~/Documents/Calibre Library"
#
# License:     GPL3+
#
###############################################################################
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
###############################################################################

# Cleanup on exit, or when interrupted for any reason.
trap 'cleanup' QUIT EXIT

# CONSTANTS
readonly file_list="$(mktemp /tmp/filelist.XXXXX)"
readonly analyses="$(mktemp /tmp/analyses.XXXXX)"

# DEFAULT ARGUMENTS.
scan_dir="."

# Function: cleanup
#
# Removes temporary files when the script terminates.
cleanup () {
    rm -f "$file_list"
    rm -f "$analyses"
}

# Function: usage
usage () {
    echo "$0 <path/to/library/dir>"
}

# Function: main
#
# Do the thing!
main () {
    # Process command-line arguments.
    while test $# -gt 0; do
        if [ x"$1" == x"--" ]; then
            # detect argument termination
            shift
            break
        fi
        case "$1" in
            -? | --usage | --help )
                usage
                exit
                ;;

            * )
                break
                ;;
        esac
    done

    # Collect runtime parameters.
    scan_dir="$1"

    # Find all the files in the Library, but not the generated files.
    find "$scan_dir" -type f \
        -not -name 'metadata.db' \
        -not -name 'metadata_db_prefs_backup.json' \
        -not -name 'metadata_pre_restore.db' \
        -not -name '*.jpg' -not -name '*.opf' \
        -print > "$file_list"

    while read line; do
        echo "Hashing file $line..."
        hash=$(shasum -a 256 "$line" | cut -d ' ' -f 1)
        # Get last analysis time of file.
        echo "Getting info for file with hash $hash..."
        results=$(vt file "$hash" --exclude total_votes.*)
        if [ -z "$results" ]; then
            echo "Scanning file $line..."
            vt scan file "$line" | tail -n 1 >> "$analyses"
        else
            echo "Results for file $line:"
            echo "$results" | grep -A 7 'last_analysis_stats:'
        fi
        sleep 3
    done < "$file_list"

    while read line; do
        file="$(echo -n "$line" | rev | cut -d ' ' -f 2- | rev)"
        analysis_id="$(echo -n "$line" | rev | cut -d ' ' -f 1 | rev)"
        echo "Analysis for file $file:"
        vt analysis "$analysis_id" --include stats.* --include status
        sleep 3
    done < "$analyses"
}

main "$@"
