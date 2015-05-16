PROGS = \
	asm/null \
	c/c-diet-null \
	c/c-libc-static-null c/c-libc-dynamic-null \
	c/c++-static-null c/c++-dynamic-null \
	haskell/null-single haskell/null-threaded \
	ocaml/null-byte ocaml/null-opt \
	java/null-gcj

SCRIPTS = \
	dash/null.dash bash/null.bash \
	mksh/null.mksh mksh/null.mksh-static \
	lua/null.lua51 lua/null.lua52 lua/null.luajit \
	perl/null.pl \
	awk/null.mawk awk/null.gawk \
	ruby/null.rb18 ruby/null.rb19 \
	php/null.php php/null.php-n \
	tcl/null.tcl84 tcl/null.tcl85 tcl/null.tcl86 \
	python/null.py26 python/null.py26-s \
	python/null.py27 python/null.py27-s python/null.py27-o \
	python/null.py32 python/null.py32-s python/null.py32-o \
	python/null.pypy python/null.pypy-s

#METRICS = \
#	cycles,instructions,branches,branch-misses \
#	dtlb-loads,dtlb-load-misses,itlb-loads,itlb-load-misses \
#	cycles,instructions,cache-references,cache-misses \
#	cycles,instructions,stalled-cycles-frontend,stalled-cycles-backend

METRICS = cycles,instructions,branches,branch-misses,cpu-clock,task-clock,major-faults,minor-faults,cs

JAVA_VMS = server zero cacao jamvm
# see below for how this is called
JAVA_INVOCS = $(JAVA_VMS:%="java -cp java -% Null")

EXTRA_RUN = /bin/true

REPS = 100

PERF ?= perf

all: $(PROGS) java/Null.class

$(PROGS): Makefile

asm/null: asm/null.s
	as -o asm/null.o $<
	ld -o $@ asm/null.o
	strip $@

c-diet-%: %.c
	diet gcc -O2 -Wall -o $@ $<
	strip $@

c-libc-static-%: %.c
	gcc -static -O2 -Wall -o $@ $<
	strip $@

c-libc-dynamic-%: %.c
	gcc -O2 -Wall -o $@ $<
	strip $@

c++-static-%: %.c
	g++ -static -O2 -Wall -o $@ $<
	strip $@

c++-dynamic-%: %.c
	g++ -O2 -Wall -o $@ $<
	strip $@

haskell/null-single: haskell/null.hs
	ghc --make -O2 -Wall -o $@ $<
	strip $@

haskell/null-threaded: haskell/null.hs
	ghc --make -O2 -Wall -threaded -o $@ $<
	strip $@

ocaml/null-byte: ocaml/null.ml
	ocamlc -o $@ $<
	# no stripping as this is not an elf file

ocaml/null-opt: ocaml/null.ml
	ocamlopt -o $@ $<
	strip $@

java/null-gcj: java/Null.java
	gcj-4.6 --main=Null -o $@ $<
	strip $@

java/Null.class: java/Null.java Makefile
	javac $<

log: $(PROGS) $(SCRIPTS) java/Null.class Makefile
	rm -f log; \
	for prog in $(PROGS:%=./%) $(SCRIPTS:%=./%) $(EXTRA_RUN) $(JAVA_INVOCS); do \
	  echo $$prog; \
	  for metric in $(METRICS); do \
	    LC_ALL=C $(PERF) stat -e "$$metric" -r $(REPS) -o log --append $$prog; \
	  done; \
	done

.PHONY: log

clean:
	cd asm && rm -f *.o
	cd haskell && rm -f *.hi *.o
	cd ocaml && rm -f *.cmo *.cmi *.cmx *.o
	cd java && rm -f *.class
	rm -f $(PROGS)
