# Perf-null

This is a set of small programs for testing startup costs using perf.

Yes, this is mostly pointless, but it was fun to do it and to look at
the numbers.

You'll need lots of packages installed to make all of the programs to
work. They should all be available in (Debian) Sid:

- java: openjdk-6-jdk openjdk-6-jre-zero icedtea-6-jre-cacao
  icedtea-6-jre-jamvm gcj-4.6 gcj-4.8 gcj-4.9 gcj-5
- python: python2.7 python3.4 pypy
- etc.

Main target is `make log`, and it is recommended to run it via
`./run.sh`, which is a simple wrapper that should make runs more
consistent. A simple test run (to check that all binaries/scripts run
correctly) can be done via `make test`.

Note: all the extremely trivial code here is under the Apache License,
Version 2.0. See LICENSE.
