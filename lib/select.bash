spoon_select_from_multiple() {
    if [[ $arg_all = 0 ]] && [[ $node_count -gt 1 ]]; then
        nodes_data="$(echo "${nodes}" | jq '.[] | .id + " " + .service + " " + (if .publicIp then .publicIp else ("*" + .privateIp) end) + " (" + .state + ")"' | tr -d '\"')"
        echo "${nodes_data}"| nl '-s) ' | column -t
        echo "*)  all"
        read -rp '==> ' reply
        if [[ "${reply}" = "" ]]; then
            verbose_log "[spoon] no instances selected"
            nodes='[]'
            return
        fi
        if [[ "${reply}" = '*' ]]; then
            verbose_log "[spoon] all instances selected"
        else
            jq_range_expression="$(jqrangify "${reply}")"
            [[ "${arg_verybose}" = 1 ]] && echo "[spoon] jq range expression: ${jq_range_expression}"
            if ! nodes="$(echo "${nodes}" | jq "${jq_range_expression}" 2>/dev/null)"; then
                echo "[spoon] jq error: invalid selector"
                exit 1
            fi
            node_count=$(echo "${nodes}" | jq '. | length')
            if [[ "${node_count}" -eq 0 ]]; then
                echo "[spoon] no instances selected"
                nodes='[]'
                return
            fi
            [[ "${arg_verybose}" = 1 ]] && echo -e "[spoon] selected instances:\\n${nodes}"
        fi
    fi
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
