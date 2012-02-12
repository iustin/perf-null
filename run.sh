#!/bin/sh

# rebuild everything
make clean
make
# preseed filesystem cache
make log REPS=2
# now do the real run
chrt -r 5 taskset -c 0 make log REPS=500
LC_ALL=en_US.UTF-8 awk -f dump.awk log
