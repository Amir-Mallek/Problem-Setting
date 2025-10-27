## Test Genration and Benchmarking in 8 simple steps

1) make a copy of this repo
2) edit `gen.cpp`, `sol.cpp` and `checker.cpp` files
3) add `.cpp` files to the `solutions/` folder 
4) `rm -f inputs/*`
5) `rm -f outputs/*`
6) `./c.sh gen.cpp`
7) `./gen-outs.sh`
8) `./compare-sols.sh`

Note : when comparing solutions, and when some o them take too much time,
consider changing their extension to `.cppp` to stop them from being tested by the `compare-sols.sh`


Potential improvement : put a time limit for each execution using the `timeout` command 
