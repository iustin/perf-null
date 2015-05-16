#!/bin/sh

CHRT=${CHRT:-chrt -r 5}
TASKSET=${TASKSET:-taskset -c 0}

# rebuild everything
make clean
make
# preseed filesystem cache
make log REPS=2
# now do the real run
$CHRT $TASKSET make log REPS=500
make report
