#!/usr/bin/env bash

declare ssh_failed
declare is_using_cache

spoon_smart_retry() {
    if [[ "$ssh_failed" = 1 ]] && [[ "$is_using_cache" = 1 ]]; then
        spoon_log SSH failed after reading from cache, retrying but skipping the cache this time...
        export arg_no_cache_read=1

        spoon_get_instances
        spoon_filter_for_environment
        spoon_filter_for_first
        spoon_select_from_multiple

        spoon_ssh
    fi
}
