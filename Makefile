.PHONY: all test fmt clean

all:
	dune build

test:
	dune runtest

fmt:
	dune build @fmt --auto-promote

clean:
	dune clean
