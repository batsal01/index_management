#!/bin/bash
# By default, delete older logs than 35 days
DA=$(date -d "35 days ago" +%Y%m%d)
TODAY=$(date +%Y.%m.%d)
EU='elastic'
EP='password'
LOGFILE=/tmp/delete.log

COMMAND=$(curl -s -XGET http://127.0.0.1:9200/_cat/indices?pretty -u $EU:$EP)

# Logging
if [ -n "$LOGFILE" ] && ! [ -e $LOGFILE ]; then
  touch $LOGFILE
fi

echo "$COMMAND" | while read LINES
do
  SELECTED=$(echo $LINES | awk '{print $3}' | grep 20[0-9][0-9] | awk -F'-' '{print$(NF-0)}' | sed 's/\.//g')
  echo "$SELECTED" | while read EMPTY_LINES
  do
  [ -z "$EMPTY_LINES" ] && continue
  if [ "$EMPTY_LINES" -lt "$DA" ]
  then
    DEL=$(echo $LINES | awk '{print $3}')
    echo "DELETING $DEL" >> $LOGFILE
    curl -s -XDELETE "http://127.0.0.1:9200/$DEL" -u $EU:$EP > /dev/null
  fi
  done
done
