## Test Genration and Benchmarking in 4 simple steps

1) Make a copy of this repository.
2) Edit the `gen.cpp`, `sol.cpp` and `checker.cpp` files.
3) Add the `cpp` solution files to be tested to the `solutions/` folder.
4) Exceute : `./run.sh`


### Notes

- The checker is mandatory. It is a decision the we made. You also have to follow the structure of the `checker.cpp` file that you find in this repository.

- You can change the configuration parameters in the `compare-sols.sh`, but we recommend to keep the default.

- When comparing solutions, and when some of them are taking too much time, these are multiple solutions [easy ones first] :
  - change the extension to `.cppp` to stop the file from being tested by the `compare-sols.sh`
  - just change the time limit
  - use parallel testing
  - add a new feature that stops the testing on the first TLE 