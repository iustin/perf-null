PROGS = \
	asm/null \
	c/c-diet-null \
	c/c-libc-static-null c/c-libc-dynamic-null \
	c/c++-static-null c/c++-dynamic-null \
	haskell/null-single haskell/null-threaded \
	ocaml/null-byte ocaml/null-opt \
	java/null-gcj-4.6 java/null-gcj-4.8 \
	java/null-gcj-4.9 java/null-gcj-5

SCRIPTS = \
	dash/null.dash bash/null.bash \
	mksh/null.mksh mksh/null.mksh-static \
	perl/null.pl \
	awk/null.mawk awk/null.gawk \
	ruby/null.rb18 ruby/null.rb19 \
	php/null.php php/null.php-n \
	tcl/null.tcl84 tcl/null.tcl85 tcl/null.tcl86

#METRICS = \
#	cycles,instructions,branches,branch-misses \
#	dtlb-loads,dtlb-load-misses,itlb-loads,itlb-load-misses \
#	cycles,instructions,cache-references,cache-misses \
#	cycles,instructions,stalled-cycles-frontend,stalled-cycles-backend

METRICS = cycles,instructions,branches,branch-misses,cpu-clock,task-clock,major-faults,minor-faults,cs

JAVA_VMS = server zero cacao jamvm
# see below for how this is called
JAVA_INVOCS = $(JAVA_VMS:%="java -cp java -% Null")

PYTHON_VERSIONS ?= python2.7 python3.4 pypy
PYTHON_VARIANTS = "" -O -S
PYTHON_INVOCS = $(foreach py,$(PYTHON_VERSIONS), \
	$(foreach opt,$(PYTHON_VARIANTS), "$(py) $(opt) python/null.py"))

LUA_VERSIONS ?= lua5.1 lua5.2 luajit
LUA_INVOCS = $(LUA_VERSIONS:%="% lua/null.lua")

EXTRA_RUN = /bin/true

ALL_TARGETS = \
  $(PROGS:%=./%) \
  $(SCRIPTS:%=./%) \
  $(JAVA_INVOCS) \
  $(PYTHON_INVOCS) \
  $(LUA_INVOCS) \
  $(EXTRA_RUN)

REPS ?= 100

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

java/null-gcj-%: java/Null.java
	gcj-$* --main=Null -o $@ $<
	strip $@

java/Null.class: java/Null.java Makefile
	javac $<

log: $(PROGS) $(SCRIPTS) java/Null.class Makefile
	@rm -f log; \
	for prog in $(ALL_TARGETS); do \
	  echo $$prog; \
	  for metric in $(METRICS); do \
	    LC_ALL=C $(PERF) stat -e "$$metric" -r $(REPS) -o log --append $$prog; \
	  done; \
	done

test: $(PROGS) $(SCRIPTS) java/Null.class Makefile
	@for prog in $(ALL_TARGETS); do \
	  echo $$prog; \
	  $$prog; \
	done

clean:
	cd asm && rm -f *.o
	cd haskell && rm -f *.hi *.o
	cd ocaml && rm -f *.cmo *.cmi *.cmx *.o
	cd java && rm -f *.class
	rm -f $(PROGS)

report:
	LC_ALL=en_US.UTF-8 awk -f dump.awk log

.PHONY: log clean report test
