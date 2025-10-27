#!/bin/bash

# You have the ability to choose whether to launch tests in parallel or in sequence
# Default is in sequence
# In parallel -> less waiting time, but less precise benchmarking


# Configuration
TIME_LIMIT=2            # seconds per test case -> TLE
use_parallel=0          # Change this to 1 if you want to make tests run in parallel 
PARALLEL_THRESHOLD=5    # If quick test time > this, run tests in parallel
NUM_PARALLEL_JOBS=6     # Number of parallel jobs

g++ -std=c++17 -O2 -o checker checker.cpp || exit 1
CHECKER="./checker"     # Path to checker executable (must accept: checker input tested_out expected_out -> exit 0 = OK)

# Function to measure time and memory for a single test
# Args: bin input_file output_file
measure_test() {
    local bin=$1
    local input_file=$2
    local output_file=$3

    local temp_file
    temp_file=$(mktemp)

    # Run with timeout to prevent hanging tests
    timeout --foreground ${TIME_LIMIT}s /usr/bin/time -f "%e %M" -o "$temp_file" "$bin" < "$input_file" > "$output_file" 2>&1
    local exit_code=$?

    local elapsed_time max_memory
    read -r elapsed_time max_memory < "$temp_file" 2>/dev/null
    rm -f "$temp_file"

    # Handle timeout case
    if [ $exit_code -eq 124 ]; then
        # 124 = timeout
        echo "$TIME_LIMIT 0 TIMEOUT"
    else
        echo "${elapsed_time:-0} ${max_memory:-0} OK"
    fi
}

# Run checker; returns checker exit code or special codes:
#  0  -> OK
#  1+ -> WA (or checker-specific non-zero)
# 126 -> checker missing or not executable
# 127 -> expected output missing
run_checker_on_expected() {
    local input_file=$1
    local tested_out=$2
    local expected_out=$3

    if [ ! -x "$CHECKER" ]; then
        return 126
    fi

    if [ ! -e "$expected_out" ]; then
        return 127
    fi

    "$CHECKER" "$input_file" "$tested_out" "$expected_out" >/dev/null 2>&1
    return $?
}

# Run tests in parallel
run_parallel_tests() {
    local bin=$1
    local name=$2

    echo "  Running tests in parallel (max $NUM_PARALLEL_JOBS jobs)..."

    local temp_dir
    temp_dir=$(mktemp -d)

    for input_file in inputs/*.in; do
        [ -e "$input_file" ] || continue
        test_name=$(basename "$input_file" .in)

        (
            local out_file="$temp_dir/${test_name}.out"
            result=$(measure_test "$bin" "$input_file" "$out_file")
            read -r elapsed memory status <<< "$result"

            expected_out="answers/${test_name}.out"

            if [ "$status" == "TIMEOUT" ]; then
                checker_status=999  # Special code for TLE
            else
                run_checker_on_expected "$input_file" "$out_file" "$expected_out"
                checker_status=$?
            fi

            printf "%s %s %s %d\n" "$test_name" "$elapsed" "$memory" "$checker_status" > "$temp_dir/${test_name}.result"
        ) &

        # throttle background jobs
        while [ $(jobs -r | wc -l) -ge $NUM_PARALLEL_JOBS ]; do
            sleep 0.1
        done
    done

    wait

    declare -g -A test_times
    declare -g -A test_mems
    declare -g -A test_checks

    for result_file in "$temp_dir"/*.result; do
        [ -e "$result_file" ] || continue
        read -r test_name elapsed memory checker_status < "$result_file"
        test_times[$test_name]=$elapsed
        test_mems[$test_name]=$memory
        test_checks[$test_name]=$checker_status

        if [ "$checker_status" -eq 0 ]; then
            check_str="OK"
        elif [ "$checker_status" -eq 999 ]; then
            check_str="TLE"
        elif [ "$checker_status" -eq 127 ]; then
            check_str="NOOUT"
        elif [ "$checker_status" -eq 126 ]; then
            check_str="NOCHECK"
        else
            check_str="WA"
        fi

        printf "    %-30s time: %8.3fs | mem: %8d KB | result: %s\n" "$test_name" "$elapsed" "$memory" "$check_str"
    done

    rm -rf "$temp_dir"
}

# Run tests sequentially
run_sequential_tests() {
    local bin=$1
    local name=$2

    declare -g -A test_times
    declare -g -A test_mems
    declare -g -A test_checks

    for input_file in inputs/*.in; do
        [ -e "$input_file" ] || continue

        test_name=$(basename "$input_file" .in)

        temp_out=$(mktemp)
        result=$(measure_test "$bin" "$input_file" "$temp_out")
        read -r elapsed memory status <<< "$result"

        if [ "$status" == "TIMEOUT" ]; then
            checker_status=999  # special code for TLE
        else
            expected_out="answers/${test_name}.ans"
            run_checker_on_expected "$input_file" "$temp_out" "$expected_out"
            checker_status=$?
        fi

        test_times[$test_name]=$elapsed
        test_mems[$test_name]=$memory
        test_checks[$test_name]=$checker_status

        if [ "$checker_status" -eq 0 ]; then
            check_str="OK"
        elif [ "$checker_status" -eq 999 ]; then
            check_str="TLE"
        elif [ "$checker_status" -eq 127 ]; then
            check_str="NOOUT"
        elif [ "$checker_status" -eq 126 ]; then
            check_str="NOCHECK"
        else
            check_str="WA"
        fi

        printf "    %-30s time: %8.3fs | mem: %8d KB | result: %s\n" "$test_name" "$elapsed" "$memory" "$check_str"

        rm -f "$temp_out"
    done
}

# Main loop over solutions
echo "==================================================================================="
echo "                               Testing Solutions"
echo "==================================================================================="


for src in solutions/*.cpp; do
    [ -e "$src" ] || continue
    name=$(basename -- "$src" .cpp)
    bin="./${name}_bin"

    echo "-----------------------------------------------------------------------------------"
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

    if [ -n "$first_input" ]; then
        quick_result=$(measure_test "$bin" "$first_input" "/dev/null")
        quick_time=$(echo "$quick_result" | awk '{print $1}')

        if (( $(echo "$quick_time > $PARALLEL_THRESHOLD" | bc -l) )); then
            use_parallel=1
            echo "  ⚠ Solution appears slow (${quick_time}s on first test), using parallel execution"
        fi
    fi

    declare -A test_times
    declare -A test_mems
    declare -A test_checks

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

    ok_count=0
    wa_count=0
    tle_count=0
    noout_count=0
    nocheck_count=0

    for test_name in "${!test_times[@]}"; do
        elapsed=${test_times[$test_name]}
        memory=${test_mems[$test_name]}
        checker_status=${test_checks[$test_name]}

        ((count++))
        total_time=$(echo "$total_time + $elapsed" | bc)
        total_mem=$(echo "$total_mem + $memory" | bc)

        (( $(echo "$elapsed > $max_time" | bc -l) )) && max_time=$elapsed
        (( $(echo "$elapsed < $min_time" | bc -l) )) && min_time=$elapsed
        (( $(echo "$memory > $max_mem" | bc -l) )) && max_mem=$memory
        (( $(echo "$memory < $min_mem" | bc -l) )) && min_mem=$memory

        case "$checker_status" in
            0)   ((ok_count++)) ;;
            999) ((tle_count++)) ;;
            127) ((noout_count++)) ;;
            126) ((nocheck_count++)) ;;
            *)   ((wa_count++)) ;;
        esac
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
    printf "    Checks: OK=%d | WA=%d | TLE=%d | NOOUT=%d | NOCHECK=%d\n" "$ok_count" "$wa_count" "$tle_count" "$noout_count" "$nocheck_count"

    rm -f "$bin"
done

rm -f "$CHECKER"

echo ""
echo "==================================================================================="
echo "                              Benchmark Complete!"
echo "==================================================================================="

