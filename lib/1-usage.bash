#!/usr/bin/env bash

declare spoon_args
declare identifier

spoon_about() {
    if has_short_flag h "${spoon_args[@]}" || has_long_flag help "${spoon_args[@]}"; then
        print_help
        exit 0
    fi
    if has_long_flag version "${spoon_args[@]}"; then
        spoon_log "$SPOON_VERSION"
        exit 0
    fi
}

print_help() {
    cat <<EOF
usage: spoon [flags] [identifier]
flags:
  -h, --help             display this message and exit
  -i, --interactive      interactive fuzzy search amongst the instances (requires fzf)
  -p, --preprod          preprod instances only
  -P, --prod             production instances only
  -1, --first            if there are multiple matching instances, select the first one without a prompt
  -a, --all              if there are multiple matching instances, select all of them without a prompt
  -n, --dry-run          list instances, but don't call ssh
  -d, --docker           enter the docker container of the application
  -r, --refresh          refresh the cache, even if it's up-to-date
  -w, --no-cache-write   don't write the cache file
  -v, --verbose          debug logging
identifier:
  Instance-id (must start with i-) or service name.
  If left empty, interactive mode is assumed.
EOF
}

spoon_set_args() {
    identifier="$(get_identifier "${spoon_args[@]}")"

    if has_short_flag i "${spoon_args[@]}" || has_long_flag interactive "${spoon_args[@]}"; then arg_interactive=1; else arg_interactive=0; fi
    if has_short_flag p "${spoon_args[@]}" || has_long_flag preprod "${spoon_args[@]}"; then arg_preprod=1; else arg_preprod=0; fi
    if has_short_flag P "${spoon_args[@]}" || has_long_flag prod "${spoon_args[@]}"; then arg_prod=1; else arg_prod=0; fi
    if has_short_flag 1 "${spoon_args[@]}" || has_long_flag first "${spoon_args[@]}"; then arg_first=1; else arg_first=0; fi
    if has_short_flag a "${spoon_args[@]}" || has_long_flag all "${spoon_args[@]}"; then arg_all=1; else arg_all=0; fi
    if has_short_flag n "${spoon_args[@]}" || has_long_flag dry-run "${spoon_args[@]}"; then arg_dry_run=1; else arg_dry_run=0; fi
    if has_short_flag d "${spoon_args[@]}" || has_long_flag docker "${spoon_args[@]}"; then arg_docker=1; else arg_docker=0; fi
    if has_short_flag r "${spoon_args[@]}" || has_long_flag no-cache-read "${spoon_args[@]}"; then arg_no_cache_read=1; else arg_no_cache_read=0; fi
    if has_short_flag w "${spoon_args[@]}" || has_long_flag no-cache-write "${spoon_args[@]}"; then arg_no_cache_write=1; else arg_no_cache_write=0; fi
    if has_short_flag v "${spoon_args[@]}" || has_long_flag verbose "${spoon_args[@]}"; then arg_verbose=1; else arg_verbose=0; fi
    # shellcheck disable=SC2034
    if has_short_flag V "${spoon_args[@]}"; then arg_verbose=1 && arg_very_verbose=1; else arg_very_verbose=0; fi

    if [[ "${#spoon_args[@]}" -lt 1 ]] || [[ "${identifier}" =~ ^- ]]; then
        very_verbose_log "empty identifier, setting mode to interactive"
        identifier=""
        arg_interactive=1
    fi
}

spoon_check_args() {
    if [[ "${arg_prod}" = 1 ]] && [[ "${arg_preprod}" = 1 ]]; then
        spoon_log "Invalid arguments: -P/--prod and -p/--preprod are mutually exclusive."
        exit 1
    fi
    if [[ "${arg_first}" = 1 ]] && [[ "${arg_all}" = 1 ]]; then
        spoon_log "Invalid arguments: -1/--first and -a/--all are mutually exclusive."
        exit 1
    fi
}

spoon_verybose_print_args() {
    very_verbose_log "identifier=${identifier}"
    very_verbose_log "arg_interactive=${arg_interactive}"
    very_verbose_log "arg_preprod=${arg_preprod}"
    very_verbose_log "arg_prod=${arg_prod}"
    very_verbose_log "arg_first=${arg_first}"
    very_verbose_log "arg_dry_run=${arg_dry_run}"
    very_verbose_log "arg_docker=${arg_docker}"
    very_verbose_log "arg_no_cache_read=${arg_no_cache_read}"
    very_verbose_log "arg_no_cache_write=${arg_no_cache_write}"
}
