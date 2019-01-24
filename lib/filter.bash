spoon_filter_for_environment() {
    if [[ $arg_preprod = 1 ]]; then
        nodes=$(echo "${nodes}" | jq 'map(select(.service | test("preprod|-pp")))')
        verbose_log "[spoon] nodes after filtering for preprod:\n${nodes}"
        node_count=$(echo "${nodes}" | jq '. | length')
        if [[ "${node_count}" -eq 0 ]]; then
            echo "No instances found for identifier '${identifier}' after filtering for preprod."
            exit 1
        fi
    elif [[ $arg_prod = 1 ]]; then
        nodes=$(echo "${nodes}" | jq 'map(select(.service | test("preprod|-pp") | not))')
        verbose_log "[spoon] nodes after filtering for prod:\n${nodes}"
        node_count=$(echo "${nodes}" | jq '. | length')
        if [[ "${node_count}" -eq 0 ]]; then
            echo "No instances found for identifier '${identifier}' after filtering for prod."
            exit 1
        fi
    fi
}

spoon_filter_for_first() {
    if [[ $arg_first = 1 ]]; then
        nodes=$(echo "${nodes}" | jq '[.[0]]')
        verbose_log "[spoon] first instance selected:\\n${nodes}"
        node_count=1
    fi
}
