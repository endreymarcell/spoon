spoon_usage_and_help() {
    if [[ ${#spoon_args[@]} -lt 1 ]]; then
        print_help
        exit 1
    fi

    if has_short_flag h "${spoon_args[@]}" || has_long_flag help "${spoon_args[@]}"; then
        print_help
        exit 0
    fi
}

print_help() {
    echo "usage: spoon [flags] <identifier>"
    echo flags:
    echo "-h, --help             display this message and exit"
    echo "-p, --preprod          preprod instances only"
    echo "-P, --prod             production instances only"
    echo "-1, --first            if there are multiple matching instances, select the first one without a prompt"
    echo "-a, --all              if there are multiple matching instances, select all of them without a prompt"
    echo "-n, --dry-run          list instances, but don't call ssh"
    echo "-d, --docker           enter the docker container of the application"
    echo "-r, --refresh          refresh the cache, even if it's up-to-date"
    echo "-w, --no-cache-write   don't write the cache file"
    echo "-v, --verbose          debug logging"
}
