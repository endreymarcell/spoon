#!/usr/bin/env bash

declare arg_all
declare arg_interactive

spoon_select_from_multiple() {
    if [[ $arg_all = 0 ]] && [[ $node_count -gt 1 ]]; then
        nodes_data="$(echo "${nodes}" | jq '.[] | .id + " " + .service + " " + (if .publicIp then .publicIp else "-" end) + " " + (if .privateIp then "*" + .privateIp else "-" end) + " " + (if .vpc then .vpc else "-" end) + " (" + .state + ")"' | tr -d '\"')"
        if [[ "$arg_interactive" = 1 ]]; then
            select_indices_with_fzf
        else
            select_indices_with_selector
        fi
        very_verbose_log "selected indices: $selected_indices"
        if [[ "${selected_indices}" = "" ]]; then
            verbose_log "no instances selected"
            nodes='[]'
            return
        elif [[ "${selected_indices}" = '*' ]]; then
            verbose_log "all instances selected"
        else
            jq_range_expression="$(jqrangify "${selected_indices}")"
            very_verbose_log "jq range expression: ${jq_range_expression}"
            if ! nodes="$(echo "${nodes}" | jq "${jq_range_expression}" 2>/dev/null)"; then
                spoon_log "jq error: invalid selector"
                exit 1
            fi
            node_count=$(echo "${nodes}" | jq '. | length')
            if [[ "${node_count}" -eq 0 ]]; then
                spoon_log "no instances selected"
                nodes='[]'
                return
            fi
            very_verbose_log "selected instances:\\n${nodes}"
        fi
    fi
}

select_indices_with_fzf() {
    if ! command -v fzf >/dev/null 2>&1; then
        spoon_log "please install fzf to use interactive mode (https://github.com/junegunn/fzf)"
        exit 1
    fi
    verbose_log "selecting nodes with fzf"
    selected_lines="$(echo "${nodes_data}"| nl '-s) ' | column -t | fzf --multi --reverse --header="(Tab to select multiple)")"
    selected_indices="$(echo "$selected_lines" | awk '{print $1}' | tr -d ')' | xargs)"
}

select_indices_with_selector() {
    verbose_log "selecting nodes with the built-in prompt"
    echo "${nodes_data}"| nl '-s) ' | column -t
    echo "*)  all"
    echo "(ranges are also allowed, eg. 1, 3, 5-8)"
    read -rp '==> ' selected_indices
}
