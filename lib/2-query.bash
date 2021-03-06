#!/usr/bin/env bash

declare arg_no_cache_read
declare arg_no_cache_write
declare identifier

spoon_get_instances() {
    verbose_log "getting instances"
    if [[ "$arg_no_cache_read" == 1 ]]; then
        verbose_log "cache reading is disabled, querying aws"
        get_instances_from_aws
    elif ! is_cache_present; then
        verbose_log "cache is not found at ${CACHE_FILE_PATH}, querying aws"
        get_instances_from_aws
    elif ! is_cache_fresh; then
        verbose_log "cache at ${CACHE_FILE_PATH} is outdated, querying aws"
        get_instances_from_aws
    elif ! is_cache_valid; then
        verbose_log "cache at ${CACHE_FILE_PATH} is not a valid JSON file, querying aws"
        get_instances_from_aws
    else
        spoon_log "reading cache at ${CACHE_FILE_PATH}"
        export is_using_cache=1
        get_instances_from_cache
    fi
}

is_identifier_instance_id() {
    test "${identifier:0:2}" = i-
}

get_instances_from_cache() {
    if is_identifier_instance_id; then
        nodes=$(jq "map(select(.id == \"${identifier}\"))" "$CACHE_FILE_PATH")
    else
        nodes=$(jq "map(select(.service | test(\".*${identifier}.*\")))" "$CACHE_FILE_PATH")
    fi

    nodes="$(echo "${nodes}" | jq 'sort_by(.service)')"
    very_verbose_log "instances returned from the cache:\\n${nodes}"

    node_count=$(echo "${nodes}" | jq '. | length')
    if [[ "${node_count}" -eq 0 ]]; then
        spoon_log "No instances found in the cache for identifier '${identifier}'."
        exit 1
    fi
}

get_instances_from_aws() {
    if is_expected_long_query; then
        spoon_log "Querying AWS... (this might take up to 10 seconds)"
    else
        spoon_log Querying AWS...
    fi
    if is_identifier_instance_id; then
        nodes=$(query_aws_by_id "$identifier")
    else
        nodes=$(query_aws_by_name "$identifier")
    fi
    # I don't want to cram the entire if statement into the condition of another one
    # shellcheck disable=SC2181
    if [[ "$?" -ne 0 ]]; then
        spoon_log "Encountered an error while using awscli. Please make sure it's installed and you are authorized to make requests."
        exit 1
    fi

    nodes="$(echo "${nodes}" | jq 'sort_by(.service)')"
    very_verbose_log "instances returned from aws:\\n${nodes}"

    spoon_build_cache

    node_count=$(echo "${nodes}" | jq '. | length')
    if [[ "${node_count}" -eq 0 ]]; then
        spoon_log "No instances returned from AWS for identifier '${identifier}'."
        exit 1
    fi
}

query_aws() {
    verbose_log "querying aws..."
    very_verbose_log query to load instances from aws:
    # the linter incorrectly assumes that I want to expand an expression here
    # shellcheck disable=SC2016
    very_verbose_log aws ec2 describe-instances --query 'Reservations[*].Instances[*].{id: InstanceId, publicIp: PublicIpAddress, privateIp: PrivateIpAddress, state: State.Name, service: (Tags[?Key == `"Name"`].Value)[0], vpc: VpcId}[0]' "${@}"
    # The backticks are part of the JMESPath expression and should be
    # passed literally, not interpolated - disable relevant shellcheck rule.
    # shellcheck disable=SC2016
    if nodes="$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{id: InstanceId, publicIp: PublicIpAddress, privateIp: PrivateIpAddress, state: State.Name, service: (Tags[?Key == `"Name"`].Value)[0], vpc: VpcId}[0]' "${@}")"; then
        # TODO if possible, this filtering should already be done as part of the query
        nodes_with_service_name="$(echo "${nodes}" | jq 'map(select(.service != "null" and .service != null))')"
        echo "${nodes_with_service_name}"
    else
        return 1
    fi
}

query_aws_by_name() {
    verbose_log "query aws by service name"
    query_aws --filters "Name=tag:Name,Values=*$1*"
}

query_aws_by_id() {
    verbose_log "query aws by id"
    query_aws --instance-ids "$1"
}

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
    very_verbose_log query to cache instances from aws:
    # the linter incorrectly assumes that I want to expand an expression here
    # shellcheck disable=SC2016
    very_verbose_log aws ec2 describe-instances --query 'Reservations[*].Instances[*].{id: InstanceId, publicIp: PublicIpAddress, privateIp: PrivateIpAddress, state: State.Name, service: (Tags[?Key == `"Name"`].Value)[0], vpc: VpcId}[0]'
    # the linter incorrectly assumes that I want to expand an expression here
    # shellcheck disable=SC2016
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].{id: InstanceId, publicIp: PublicIpAddress, privateIp: PrivateIpAddress, state: State.Name, service: (Tags[?Key == `"Name"`].Value)[0], vpc: VpcId}[0]' | jq 'map(select(.service != "null" and .service != null))' > "${CACHE_FILE_PATH}.tmp"
    mv "${CACHE_FILE_PATH}.tmp" "${CACHE_FILE_PATH}"
}

is_expected_long_query() {
    if [[ "${identifier}" = "" ]]; then
        verbose_log "Empty identifier, expecting long-running query."
        return 0
    fi
    if ! is_cache_present; then
        verbose_log No cache file present, cannot estimate query time.
        return 1
    fi

    if is_identifier_instance_id; then
        outdated_cached_nodes_count=$(jq "map(select(.id == \"${identifier}\")) | length" "$CACHE_FILE_PATH")
    else
        outdated_cached_nodes_count=$(jq "map(select(.service | test(\".*${identifier}.*\"))) | length" "$CACHE_FILE_PATH")
    fi
    verbose_log "Estimating query size: ${outdated_cached_nodes_count} occurrences found in the outdated cache."
    if [[ "$outdated_cached_nodes_count" -ge 20 ]]; then
        verbose_log "This is above the threshold, expecting long-running query."
        return 0
    else
        verbose_log "This is below the threshold, expecting quick query."
        return 1
    fi
}
