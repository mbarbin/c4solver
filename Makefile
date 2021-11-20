.PHONY: all test fmt clean lint

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
