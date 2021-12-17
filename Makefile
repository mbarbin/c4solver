.PHONY: all test fmt clean lint show-benches

all:
	dune build
	cargo build --release

test:
	dune runtest
	cargo test

fmt:
	dune build @fmt --auto-promote
	cargo fmt --all

lint:
	opam lint
	opam-dune-lint

clean:
	dune clean
	cargo clean

show-benches:
	dune exec c4solver -- bench show > benchmark.txt
	dune exec c4solver -- bench show
