(lang dune 3.11)

(name c4solver)

(using cinaps 1.3)

(generate_opam_files)

(license "AGPL-3.0-or-later")

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin")

(source
 (github mbarbin/c4solver))

(documentation "https://mbarbin.github.io/c4solver/odoc/")

(package
 (name c4solver)
 (synopsis "A solver for the connect4 game")
 (description "A solver for the connect4 game")
 (depends
  (ocaml
   (>= 5.1))
  (dune
   (>= 3.11))
  (ANSITerminal
   (>= 0.8.3))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (bignum
   (and
    (>= v0.16)
    (< v0.17)))
  (cinaps
   (and
    :with-test
    (>= v0.15.1)))
  (core
   (and
    (>= v0.16)
    (< v0.17)))
  (command-unix-for-opam
   (>= 0.0.1))
  (expect_test_helpers_core
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (mtime
   (>= 2.0))
  (mtime-extended
   (>= 2.0))
  (ppx_jane
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    (>= v0.16)
    (< v0.17)))
  (stdint
   (>= 0.7))
  (stdio
   (and
    (>= v0.16)
    (< v0.17)))
  (textutils
   (and
    (>= v0.16)
    (< v0.17)))))
