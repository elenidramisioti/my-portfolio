#!/bin/bash

#Onomatepwnmyo: Eleni Dramisioti
#AM:3240046

#if no arguments are given, print only my Id 
if [ $# -eq 0 ]; then
     echo "3240046"
     exit 0
fi

#initialization of all variables 
FILE=""
ID=""
BORN_SINCE=""
BORN_UNTIL=""
SHOW_FIRSTNAMES=0
SHOW_LASTNAMES=0
SHOW_BROWSERS=0

#parse all command-line arguments in any order 
while [ $# -gt 0 ]; do
    case "$1" in 
        -f)
            FILE="$2"
            shift 2
            ;;
        -id)
            ID="$2"
            shift 2
            ;;
        --firstnames)
            SHOW_FIRSTNAMES=1
            shift
            ;;
        --lastnames)
            SHOW_LASTNAMES=1
            shift
            ;;
        --born-since)
            BORN_SINCE="$2"
            shift 2
            ;;
        --born-until)
            BORN_UNTIL="$2"
            shift 2
            ;;
        --browsers)
            SHOW_BROWSERS=1
            shift
            ;;
        *)

            shift
            ;;
    esac
done
#check if the file exists
if [ -n  "$FILE" ] && [ ! -f "$FILE" ]; then
    exit 0
fi
#if only -f is given print the whole file without any comment 
if [ -n "$FILE" ] && [ -z "$ID" ] && [ "$SHOW_FIRSTNAMES" -eq 0 ] && [ "$SHOW_LASTNAMES" -eq 0 ] && [ -z "$BORN_SINCE" ] && [ -z "$BORN_UNTIL" ] && [ "$SHOW_BROWSERS" -eq 0 ]; then
    grep  -v '^#' "$FILE"
    exit 0
fi
#search for a specific user id and the output format is: firstName lastName birthday
if [ -n "$ID" ]; then 
    LINE=$(grep -v '^#' "$FILE" | awk -F"|" -v id="$ID" '$1==id')
    if [ -n "$LINE" ]; then
        FIRST=$(echo "$LINE" | awk -F"|" '{print $3}')
        LAST=$(echo "$LINE" | awk -F"|" '{print $2}')
        BDAY=$(echo "$LINE" | awk -F"|" '{print $5}')
       echo "$FIRST $LAST $BDAY"
    fi
    exit 0
fi
#print all first names in alphabetical order
if [ "$SHOW_FIRSTNAMES" -eq 1 ]; then
    grep -v '^#' "$FILE" | awk -F"|" '{print $3}' | sort -u
    exit 0
fi
#print all last names in alphabetical order
if [ "$SHOW_LASTNAMES" -eq 1 ]; then
   grep -v '^#' "$FILE" | awk -F"|" '{print $2}' | sort -u
   exit 0
fi
#filter users based on their birthday range and print each matching line exactly aas it appears in the given file 
if [ -n "$BORN_SINCE" ] || [ -n "$BORN_UNTIL" ]; then
   grep -v '^#' "$FILE" | while IFS="|" read -r id lastName firstName gender birthday joinDate locationIP browserUsed; do
   ok=1

  if [ -n "$BORN_SINCE" ] && [[ "$birthday"  < "$BORN_SINCE" ]]; then
      ok=0;
  fi

  if [ -n "$BORN_UNTIL" ] && [[ "$birthday" > "$BORN_UNTIL" ]]; then
      ok=0;
  fi

  if [ "$ok" -eq 1 ]; then
      echo "$id|$lastName|$firstName|$gender|$birthday|$joinDate|$locationIP|$browserUsed"
      fi 
  done
  exit 0
fi
#print all browsers and the number of users
if [ "$SHOW_BROWSERS" -eq 1 ]; then
    grep -v '^#' "$FILE" | awk -F"|" '{print $8}' | sort | uniq -c | \
    awk '{print $2" "$1}'
    exit 0
fi
