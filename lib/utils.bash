CONFIG_FILE_PATH=~/.spoon/config.json
CACHE_FILE_PATH=~/.cache/spoon_aws_cache.json
CACHE_EXPIRY_HOURS=24

verbose_log() {
    [[ "${arg_verbose}" = 1 ]] && echo -e "${@}" >&2
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

is_cache_fresh() {
    if [[ "$(find "$CACHE_FILE_PATH" -mmin -$((60*CACHE_EXPIRY_HOURS)) -print0 2>/dev/null | xargs -0)" != "" ]]; then
        return 0
    else
        return 1
    fi
}

is_cache_valid() {
    jq . "$CACHE_FILE_PATH" >/dev/null 2>&1
}

get_config() {
    jq_expression="$1"
    if [[ ! -f "$CONFIG_FILE_PATH" ]]; then
        echo '{}' > $CONFIG_FILE_PATH
    fi
    if ! $(jq . "$CONFIG_FILE_PATH" >/dev/null); then
        echo "[spoon] Error: $CONFIG_FILE_PATH is not valid JSON" 1>&2
        exit 1
    fi
    jq "$jq_expression" "$CONFIG_FILE_PATH"
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
