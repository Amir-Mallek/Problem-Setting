#!/bin/bash

# Configuration
PARALLEL_THRESHOLD=5  # If max time > this, run tests in parallel
NUM_PARALLEL_JOBS=6   # Number of parallel jobs

# Function to measure time and memory for a single test
measure_test() {
    local bin=$1
    local input_file=$2
    local output_file=$3
    
    # Create unique temp file for this measurement
    local temp_file=$(mktemp)
    
    # Use /usr/bin/time for memory measurement (GNU time format)
    # %e = elapsed real time, %M = maximum resident set size in KB
    /usr/bin/time -f "%e %M" -o "$temp_file" "$bin" < "$input_file" > "$output_file" 2>&1
    
    # Read the timing results
    local elapsed_time max_memory
    read elapsed_time max_memory < "$temp_file"
    rm -f "$temp_file"
    
    echo "$elapsed_time $max_memory"
}

# Function to run tests in parallel
run_parallel_tests() {
    local bin=$1
    local name=$2
    
    echo "  Running tests in parallel (max $NUM_PARALLEL_JOBS jobs)..."
    
    # Create a temporary directory for individual result files
    local temp_dir=$(mktemp -d)
    
    for input_file in inputs/*.in; do
        [ -e "$input_file" ] || continue
        test_name=$(basename "$input_file" .in)
        
        (
            # Each process writes to its own file - NO RACE CONDITION
            result=$(measure_test "$bin" "$input_file" "/dev/null")
            echo "$test_name $result" > "$temp_dir/${test_name}.result"
        ) &
        
        # Limit number of parallel jobs
        while [ $(jobs -r | wc -l) -ge $NUM_PARALLEL_JOBS ]; do
            sleep 0.1
        done
    done
    
    # Wait for all background jobs to complete
    wait
    
    # Read results into global arrays
    declare -g -A test_times
    declare -g -A test_mems
    
    # Collect all results from individual files
    for result_file in "$temp_dir"/*.result; do
        [ -e "$result_file" ] || continue
        read -r test_name elapsed memory < "$result_file"
        test_times[$test_name]=$elapsed
        test_mems[$test_name]=$memory
        printf "    %-30s time: %8.3fs | mem: %8d KB\n" "$test_name" "$elapsed" "$memory"
    done
    
    rm -rf "$temp_dir"
}

# Function to run tests sequentially
run_sequential_tests() {
    local bin=$1
    local name=$2
    
    declare -g -A test_times
    declare -g -A test_mems
    
    for input_file in inputs/*.in; do
        [ -e "$input_file" ] || continue
        
        test_name=$(basename "$input_file" .in)
        
        result=$(measure_test "$bin" "$input_file" "/dev/null")
        elapsed=$(echo "$result" | awk '{print $1}')
        memory=$(echo "$result" | awk '{print $2}')
        
        test_times[$test_name]=$elapsed
        test_mems[$test_name]=$memory
        
        printf "    %-30s time: %8.3fs | mem: %8d KB\n" "$test_name" "$elapsed" "$memory"
    done
}

# Loop through all .cpp files in solutions/
echo "================================================"
echo "Testing Solutions"
echo "================================================"

for src in solutions/*.cpp; do
    [ -e "$src" ] || continue
    name=$(basename -- "$src" .cpp)
    bin="./${name}_bin"
    
    echo ""
    echo "[$name]"
    echo "  Compiling..."
    g++ -std=c++17 -O2 -o "$bin" "$src"
    if [ $? -ne 0 ]; then
        echo "  ✗ Compilation failed"
        continue
    fi
    
    # Quick test to estimate if solution is slow
    first_input=$(ls inputs/*.in 2>/dev/null | head -n 1)
    use_parallel=0
    
    if [ -n "$first_input" ]; then
        quick_result=$(measure_test "$bin" "$first_input" "/dev/null")
        quick_time=$(echo "$quick_result" | awk '{print $1}')
        
        if (( $(echo "$quick_time > $PARALLEL_THRESHOLD" | bc -l) )); then
            use_parallel=1
            echo "  ⚠ Solution appears slow (${quick_time}s on first test), using parallel bincution"
        fi
    fi
    
    declare -A test_times
    declare -A test_mems
    
    if [ $use_parallel -eq 1 ]; then
        run_parallel_tests "$bin" "$name"
    else
        echo "  Running tests:"
        run_sequential_tests "$bin" "$name"
    fi
    
    # Calculate statistics
    total_time=0
    max_time=0
    min_time=999999
    total_mem=0
    max_mem=0
    min_mem=999999
    count=0
    
    for test_name in "${!test_times[@]}"; do
        elapsed=${test_times[$test_name]}
        memory=${test_mems[$test_name]}
        
        ((count++))
        total_time=$(echo "$total_time + $elapsed" | bc)
        total_mem=$(echo "$total_mem + $memory" | bc)
        
        if (( $(echo "$elapsed > $max_time" | bc -l) )); then
            max_time=$elapsed
        fi
        if (( $(echo "$elapsed < $min_time" | bc -l) )); then
            min_time=$elapsed
        fi
        if (( $(echo "$memory > $max_mem" | bc -l) )); then
            max_mem=$memory
        fi
        if (( $(echo "$memory < $min_mem" | bc -l) )); then
            min_mem=$memory
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo "  ✗ No tests completed"
        rm -f "$bin"
        continue
    fi
    
    avg_time=$(echo "scale=3; $total_time / $count" | bc)
    avg_mem=$(echo "scale=0; $total_mem / $count" | bc)
    
    echo ""
    printf "  Summary:\n"
    printf "    Time: total=%.3fs | avg=%.3fs | min=%.3fs | max=%.3fs\n" "$total_time" "$avg_time" "$min_time" "$max_time"
    printf "    Mem:  avg=%dKB | min=%dKB | max=%dKB\n" "$avg_mem" "$min_mem" "$max_mem"
    
    rm -f "$bin"
done

echo ""
echo "================================================"
echo "Benchmark Complete!"
echo "================================================"