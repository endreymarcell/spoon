#!/usr/bin/env bash

declare arg_preprod
declare arg_prod
declare arg_first
declare identifier

spoon_filter_for_environment() {
    if [[ $arg_preprod = 1 ]]; then
        verbose_log filtering for preprod
        nodes=$(echo "${nodes}" | jq 'map(select(.service | test("preprod|-pp|nonprod")))')
        very_verbose_log "nodes after filtering for preprod:\\n${nodes}"
        node_count=$(echo "${nodes}" | jq '. | length')
        if [[ "${node_count}" -eq 0 ]]; then
            spoon_log "No instances found for identifier '${identifier}' after filtering for preprod."
            exit 1
        fi
    elif [[ $arg_prod = 1 ]]; then
        verbose_log filtering for prod
        nodes=$(echo "${nodes}" | jq 'map(select(.service | test("preprod|-pp|nonprod") | not))')
        very_verbose_log "nodes after filtering for prod:\\n${nodes}"
        node_count=$(echo "${nodes}" | jq '. | length')
        if [[ "${node_count}" -eq 0 ]]; then
            spoon_log "No instances found for identifier '${identifier}' after filtering for prod."
            exit 1
        fi
    fi
}

spoon_filter_for_first() {
    if [[ $arg_first = 1 ]]; then
        verbose_log selecting the first instance
        nodes=$(echo "${nodes}" | jq '[.[0]]')
        very_verbose_log "first instance selected:\\n${nodes}"
        node_count=1
    fi
}
