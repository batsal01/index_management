#!/bin/bash

ES="http://<HOST>:<PORT>"
#Example: ES="http://127.0.0.1:9200"
ESU="<elastic_username>"
#Example: ESU="elastic"
ESP="<elastic_user_password>"
#Example: ESP="password"
DA=$(date -d "X day(s) ago" +%Y%m%d)
#Example: DA=$(date -d "35 days ago" +%Y%m%d)
INDEX_NAME="<your_index_name_here>"
#Example: INDEX_NAME="wazuh-monitoring-3"
LOGFILE=/tmp/delete.log

INDICES=$(curl -s -u $ESU:$ESP "$ES/_cat/indices?v" | awk '/'$INDEX_NAME'/{match($0, /[:blank]*('$INDEX_NAME'.[^ ]+)[:blank]*/, m); print m[1];}' | sort -r)

# Logging into a file
if [ -n "$LOGFILE" ] && ! [ -e $LOGFILE ]; then
  touch $LOGFILE
fi

# Delete indices
declare -a INDEX=($INDICES)
  for index in ${INDEX[@]};do
    if [ -n "$index" ]; then
        INDEX_DATE=$(echo $index | sed -n 's/.*\([0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}\).*/\1/p' | sed 's/\.//g')
        if [ $DA -ge $(date -d $INDEX_DATE +"%Y%m%d")  ]; then
            echo $(date +%Y-%m-%d\ %H:%M:%S)" Deleting index> $index." >> $LOGFILE
            curl -s -XDELETE "$ES/$index/" -u $ESU:$ESP >> $LOGFILE
        fi
    fi
  done
exit 0
