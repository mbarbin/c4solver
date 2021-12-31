.PHONY: all
all:
	dune build
	cargo build --release

.PHONY: test
test:
	dune runtest
	cargo test

.PHONY: fmt
fmt:
	dune build @fmt --auto-promote
	cargo fmt --all

.PHONY: lint
lint:
	opam lint
	opam-dune-lint

.PHONY: ocaml-doc
ocaml-doc:
	opam exec -- dune build @doc

.PHONY: rust-doc
rust-doc:
	cargo doc --workspace

.PHONY: doc
doc: ocaml-doc rust-doc

.PHONY: clean
clean:
	dune clean
	cargo clean

.PHONY: show-benches
show-benches:
	dune exec c4solver -- bench show > benchmark.txt
	dune exec c4solver -- bench show

.PHONY: gen-scripts
gen-scripts:
	dune exec c4solver gen-scripts -- --script-dir ${PWD}/script
	chmod +x ${PWD}/script/*.sh
