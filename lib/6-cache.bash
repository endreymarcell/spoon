#!/usr/bin/env bash

declare arg_no_cache_read
declare arg_no_cache_write
declare CACHE_FILE_PATH
declare SPOON_HOME_DIR

spoon_build_cache() {
    if [[ "$arg_no_cache_write" == 1 ]]; then
        verbose_log "cache writing is disabled"
    elif is_cache_present && is_cache_fresh && is_cache_valid && [[ "$arg_no_cache_read" == 0 ]]; then
        verbose_log "cache is up-to-date and refresh was not requested, no further action needed"
    elif find "${CACHE_FILE_PATH}.tmp" >/dev/null 2>&1; then
        verbose_log "cache is already being built, see ${CACHE_FILE_PATH}.tmp"
    else
        verbose_log "building cache in the background..."
        cache_nodes_from_aws &
    fi
}

cache_nodes_from_aws() {
    [[ ! -d "$SPOON_HOME_DIR" ]] && mkdir -p "$SPOON_HOME_DIR"
    # the linter incorrectly assumes that I want to expand an expression here
    # shellcheck disable=SC2016
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].{id: InstanceId, publicIp: PublicIpAddress, privateIp: PrivateIpAddress, state: State.Name, service: (Tags[?Key == `"Name"`].Value)[0], vpc: VpcId}[0]' | jq 'map(select(.service != "null" and .service != null))' > "${CACHE_FILE_PATH}.tmp"
    mv "${CACHE_FILE_PATH}.tmp" "${CACHE_FILE_PATH}"
}
