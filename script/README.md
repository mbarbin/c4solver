# Bench scripts

The scripts in this directory are meant to be executed from the root
path of the repository. They allow one to run specific benches, and to
gradually fill the bench-db saved at the root.

## Build required

The script require the executable to be prealably build. Make sure to
first run a build:

```bash
make
```

## Example:

```bash
./script/run-minmax-rs.sh
```

See the aggregated benches with:


```bash
make show-benches
```
