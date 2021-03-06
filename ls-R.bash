#!/bin/bash

if [ "$1" = -h ]; then
    echo "Usage: lsr [directory [, dir]*]"
    echo "  Displays a nicer form of \`ls -R\`"
    exit 1
fi

ls -R "$@" | sed -e '
# Delete empty lines
/^[ \t]*$/d;
# If the line is a directory, store to the hold buffer
/^[^ \t].*:$/ { 
  s/^\.\([a-z]*\):$/\1/; 
  s/^\.\///; s/:$/\//; 
  h; 
  d;
}; 
# Grab the hold buffer (a path)
G; 
# Join it with the current filename
s/^\(.*\)\n\(.*\)/\2\1/
'