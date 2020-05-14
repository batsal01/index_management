#!/bin/bash
# By default, delete older logs than 35 days
ES="http://127.0.0.1:9200"
ESU="elastic"
ESP="password"
DA=$(date -d "35 days ago" +%Y%m%d)
INDEX_NAME="<your_index_name_here>"
#Example: INDEX_NAME=".monitoring"
LOGFILE=/tmp/delete.log

# Get the indices from elasticsearch
INDICES_TEXT=$(curl -s -u $ESU:$ESP "$ES/_cat/indices?v" | awk '/'$INDEX_NAME'/{match($0, /[:blank]*('$INDEX_NAME'.[^ ]+)[:blank]*/, m); print m[1];}' | sort -r)
# Logging
if [ -n "$LOGFILE" ] && ! [ -e $LOGFILE ]; then
  touch $LOGFILE
fi

# Delete indices
declare -a INDEX=($INDICES_TEXT)
  for index in ${INDEX[@]};do
    if [ -n "$index" ]; then
        INDEX_DATE=$(echo $index | sed -n 's/.*\([0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}\).*/\1/p' | sed 's/\.//g')
        if [ $DA -ge $(date -d $INDEX_DATE +"%Y%m%d")  ]; then
            clear && echo "Deleting index: $index at `date "+[%Y-%m-%d %H:%M:%S]"`" >> $LOGFILE
            curl -s -XDELETE "$ES/$index/" -u $ESU:$ESP > /dev/null
        fi
    fi
  done
exit 0
