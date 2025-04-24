.PHONY: all cil tests repl

all: rscil cil tests repl
rscil: src/rscil.rs
	rustc src/rscil.rs -o rscil
tests: rscil cil
	./rscil src/tests.cil
# TODO run src/cil.cil with cil.cil
# TODO run src/tests.cil with cil.cil
cil: rscil tests
	./rscil interpret src/cil.cil src/test/example_self_hosted.cil
# ./rscil interpret src/cil.cil src/test/strings.cil
# ./rscil interpret src/cil.cil src/core/lexer.cil
repl: rscil cil
	rlwrap ./rscil src/core/repl.cil
