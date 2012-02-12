PROGS = \
	c/c-diet-static-null c/c-diet-dynamic-null \
	c/c-libc-static-null c/c-libc-dynamic-null \
	c/c++-static-null c/c++-dynamic-null \
	haskell/null-single haskell/null-threaded \
	ocaml/null-byte ocaml/null-opt

SCRIPTS = \
	dash/null.dash bash/null.bash \
	lua/null.lua51 lua/null.lua52 lua/null.luajit \
	perl/null.pl ruby/null.rb \
	php/null.php php/null.php-n \
	tcl/null.tcl84 tcl/null.tcl85 tcl/null.tcl86 \
	python/null.py26 python/null.py26-s \
	python/null.py27 python/null.py27-s \
	python/null.py32 python/null.py32-s \
	python/null.pypy

METRICS = \
	cycles,instructions,branches,branch-misses \
	dtlb-loads,dtlb-load-misses,itlb-loads,itlb-load-misses \
	cycles,instructions,cache-references,cache-misses \
	cycles,instructions,stalled-cycles-frontend,stalled-cycles-backend

REPS = 100

all: $(PROGS)

$(PROGS): Makefile

c-diet-static-%: %.c
	diet gcc -static -O2 -Wall -o $@ $<
	strip $@

c-diet-dynamic-%: %.c
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

log: $(PROGS) $(SCRIPTS) Makefile
	rm -f log; \
	for prog in $(PROGS) $(SCRIPTS); do \
	  echo $$prog; \
	  for metric in $(METRICS); do \
	    LC_ALL=C perf stat -e "$$metric" -r $(REPS) -o log --append ./$$prog; \
	  done; \
	done

.PHONY: log

clean:
	cd haskell && rm -f *.hi *.o
	cd ocaml && rm -f *.cmo *.cmi *.cmx *.o
	rm -f $(PROGS)
