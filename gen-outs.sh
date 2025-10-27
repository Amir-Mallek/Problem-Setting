#!/bin/bash

echo "==================================================================================="
echo "                              Generating Answers"
echo "==================================================================================="


# Ensure required directories exist
mkdir -p answers

# Compile the solution
echo "Compiling sol.cpp..."
g++ -std=c++17 -O2 -o sol sol.cpp

# Check if compilation succeeded
if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

echo "Running all test cases..."
echo

max_time=0
total_time=0
count=0

for input_file in inputs/*.in; do
    [ -e "$input_file" ] || continue  # Skip if no files found

    filename=$(basename -- "$input_file")
    output_file="answers/${filename%.in}.ans"

    echo -n "Running ${filename} ... "

    start_time=$(date +%s.%N)
    ./sol < "$input_file" > "$output_file"
    end_time=$(date +%s.%N)

    elapsed=$(echo "$end_time - $start_time" | bc)
    printf "time: %.3fs\n" "$elapsed"

    # Update max and total
    greater=$(echo "$elapsed > $max_time" | bc)
    if [ "$greater" -eq 1 ]; then
        max_time=$elapsed
    fi

    total_time=$(echo "$total_time + $elapsed" | bc)
    count=$((count + 1))
done

rm -f sol

echo
echo "Total tests run: $count"
printf "Max time: %.3fs\n" "$max_time"
printf "Total time: %.3fs\n" "$total_time"
