.PHONY: all test fmt clean lint show-benches

all:
	dune build

test:
	dune runtest

fmt:
	dune build @fmt --auto-promote

lint:
	opam lint
	opam-dune-lint

clean:
	dune clean

show-benches:
	dune exec c4solver -- bench show > benchmark.txt
	dune exec c4solver -- bench show
