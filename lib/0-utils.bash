#!/usr/bin/env bash

declare arg_verbose
declare arg_very_verbose

SPOON_HOME_DIR=~/.spoon
CONFIG_FILE_PATH="${SPOON_HOME_DIR}/config.json"
CACHE_FILE_PATH="${SPOON_HOME_DIR}/cache.json"
CACHE_EXPIRY_HOURS=24

spoon_log() {
    echo -e "[spoon] ${*}"
}

verbose_log() {
    [[ "${arg_verbose}" = 1 ]] && spoon_log "[verbose] ${*}" >&2
}

very_verbose_log() {
    [[ "${arg_very_verbose}" = 1 ]] && spoon_log "[very verbose] ${*}" >&2
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

get_identifier() {
    # Grab the one word from a list of words that doesn't begin with a dash.
    # "-f --foo something --bar -b" --> "something"
    #
    # Some people, when confronted with a problem, think
    # "I know, I'll use regular expressions."
    # Now they have two problems.
    echo "$*" | sed 's|-[^ ]* ||g' | sed 's| -[^ ]*||g' | sed 's|^-[^ ]*$||'
}

is_cache_present() {
    find "$CACHE_FILE_PATH" >/dev/null 2>&1
}

is_cache_fresh() {
    find "$CACHE_FILE_PATH" -mmin -$((60*CACHE_EXPIRY_HOURS)) | grep -q .
}

is_cache_valid() {
    jq . "$CACHE_FILE_PATH" >/dev/null 2>&1
}

get_config() {
    jq_expression="$1"
    [[ ! -d "$SPOON_HOME_DIR" ]] && mkdir -p "$SPOON_HOME_DIR"
    [[ ! -f "$CONFIG_FILE_PATH" ]] && echo '{}' > "$CONFIG_FILE_PATH"
    if ! jq . "$CONFIG_FILE_PATH" >/dev/null 2>&1; then
        spoon_log "Error: $CONFIG_FILE_PATH is not valid JSON" 1>&2
        exit 1
    fi
    if ! result="$(jq "$jq_expression" "$CONFIG_FILE_PATH" 2>&1)"; then
        spoon_log "Error while executing jq '${jq_expression}' $CONFIG_FILE_PATH" 1>&2
        exit 1
    fi
    echo "$result"
}

jqrangify() {
    # The easiest way I found to select multiple items, including ranges, from the array
    # is converting all indices to jq range expressions to extract subarrays
    # and adding these all together.
    # e.g '1, 3, 5-10' --> jq '.[0:1] + .[2:3] + .[4:10]'
    expr=""
    for item in $(echo "${*}" | tr , ' '); do
        # note: for single numbers 'lower' and 'upper' end up being the same
        lower="${item//-*/}"
        upper="${item//*-/}"
        # arrays are 0-indexed, spoon numbers instances from 1, hence the substraction
        jqrangified_item="$((lower - 1)):${upper}"
        expr="${expr} .[${jqrangified_item}] +"
    done
    # append [] at the end to deal with the trailing + sign
    echo "${expr} []" | xargs
}
