# =============================================================================
# CMake configuration
# =============================================================================

croot() {
    local dir="$PWD"

    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/CMakeLists.txt" ]]; then
            cd "$dir"
            return
        fi
        dir="${dir:h}"
    done

    echo "No CMake project found."
    return 1
}

cbuild() {
    local build_dir="${1:-build}"

    if [[ ! -d "$build_dir" ]]; then
        echo "Build directory not found: $build_dir"
        return 1
    fi

    cmake --build "$build_dir"
}

ctest-build() {
    local build_dir="${1:-build}"

    if [[ ! -d "$build_dir" ]]; then
        echo "Build directory not found: $build_dir"
        return 1
    fi

    ctest --test-dir "$build_dir"
}
