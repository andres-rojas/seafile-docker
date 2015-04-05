#!/user/bin/env bash
set -e

./seafile.sh start && ./seahub.sh start

pids () { pgrep 'sea|ccnet|python' | xargs ps -o pid,comm; }
show_pids () { echo 'Running Seafile processes:'; pids; }

RUNNING_PIDS=`pids`
show_pids

while :
do
  CURRENT_PIDS=`pids`
  if ! diff <(echo $CURRENT_PIDS) <(echo $RUNNING_PIDS); then
    RUNNING_PIDS=$CURRENT_PIDS

    echo
    echo 'Change detected!'
    show_pids
  fi
  sleep 5
done
