spoon_set_args() {
    identifier="${spoon_args[-1]}"

    if [[ "${identifier}" =~ ^- ]]; then
        echo identifier must not be empty
        exit 1
    fi

    if has_short_flag p "${spoon_args[@]}" || has_long_flag preprod "${spoon_args[@]}"; then arg_preprod=1; else arg_preprod=0; fi
    if has_short_flag P "${spoon_args[@]}" || has_long_flag prod "${spoon_args[@]}"; then arg_prod=1; else arg_prod=0; fi
    if has_short_flag 1 "${spoon_args[@]}" || has_long_flag first "${spoon_args[@]}"; then arg_first=1; else arg_first=0; fi
    if has_short_flag a "${spoon_args[@]}" || has_long_flag all "${spoon_args[@]}"; then arg_all=1; else arg_all=0; fi
    if has_short_flag n "${spoon_args[@]}" || has_long_flag dry-run "${spoon_args[@]}"; then arg_dry_run=1; else arg_dry_run=0; fi
    if has_short_flag d "${spoon_args[@]}" || has_long_flag docker "${spoon_args[@]}"; then arg_docker=1; else arg_docker=0; fi
    if has_short_flag r "${spoon_args[@]}" || has_long_flag no-cache-read "${spoon_args[@]}"; then arg_no_cache_read=1; else arg_no_cache_read=0; fi
    if has_short_flag w "${spoon_args[@]}" || has_long_flag no-cache-write "${spoon_args[@]}"; then arg_no_cache_write=1; else arg_no_cache_write=0; fi
    if has_short_flag v "${spoon_args[@]}" || has_long_flag verbose "${spoon_args[@]}"; then arg_verbose=1; else arg_verbose=0; fi
    if has_short_flag V "${spoon_args[@]}"; then arg_verbose=1 && arg_verybose=1; else arg_verybose=0; fi
}

has_short_flag() {
    flag="$1"
    shift
    args="$*"
    for arg in $args; do
        if [ "${arg:0:1}" = - ] && [ "${arg:1:1}" != - ] && [[ "$arg" =~ $flag ]]; then
            return 0
        fi
    done
    return 1
}

has_long_flag() {
    flag="$1"
    shift
    args="$*"
    for arg in $args; do
        if [ "${arg:0:2}" = -- ] && [[ "$arg" == "--$flag" ]]; then
            return 0
        fi
    done
    return 1
}

spoon_check_args() {
    if [[ "${arg_prod}" = 1 ]] && [[ "${arg_preprod}" = 1 ]]; then
        echo "Invalid arguments: -P/--prod and -p/--preprod are mutually exclusive."
        exit 1
    fi
    if [[ "${arg_first}" = 1 ]] && [[ "${arg_all}" = 1 ]]; then
        echo "Invalid arguments: -1/--first and -a/--all are mutually exclusive."
        exit 1
    fi
}

spoon_verybose_print_args() {
    if [[ "${arg_verybose}" = 1 ]]; then
        echo "[spoon] identifier=${identifier}"
        echo "[spoon] arg_preprod=${arg_preprod}"
        echo "[spoon] arg_prod=${arg_prod}"
        echo "[spoon] arg_first=${arg_first}"
        echo "[spoon] arg_dry_run=${arg_dry_run}"
        echo "[spoon] arg_docker=${arg_docker}"
        echo "[spoon] arg_no_cache_read=${arg_no_cache_read}"
        echo "[spoon] arg_no_cache_write=${arg_no_cache_write}"
    fi
}
