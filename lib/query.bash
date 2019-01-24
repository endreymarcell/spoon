#!/usr/bin/env bash

declare arg_no_cache_read
declare arg_verybose
declare identifier

spoon_get_instances() {
    verbose_log "[spoon] getting instances"
    if [[ "$arg_no_cache_read" == 1 ]]; then
        verbose_log "[spoon] cache reading is disabled, querying aws"
        get_instances_from_aws
    elif ! is_cache_fresh; then
        verbose_log "[spoon] cache at ${CACHE_FILE_PATH} is outdated, querying aws"
        get_instances_from_aws
    elif ! is_cache_valid; then
        verbose_log "[spoon] cache at ${CACHE_FILE_PATH} is not a valid JSON file, querying aws"
        get_instances_from_aws
    else
        verbose_log "[spoon] reading cache at ${CACHE_FILE_PATH}"
        get_instances_from_cache
    fi
}

is_identifier_instance_id() {
    if [[ "${identifier:0:2}" = i- ]]; then
        return 0
    else
        return 1
    fi
}

get_instances_from_cache() {
    if is_identifier_instance_id; then
        nodes=$(jq "map(select(.id == \"${identifier}\"))" "$CACHE_FILE_PATH")
    else
        nodes=$(jq "map(select(.service | test(\".*${identifier}.*\")))" "$CACHE_FILE_PATH")
    fi

    nodes="$(echo "${nodes}" | jq 'sort_by(.service)')"
    [[ "${arg_verybose}" = 1 ]] && echo -e "[spoon] instances returned from the cache:\\n${nodes}"

    node_count=$(echo "${nodes}" | jq '. | length')
    if [[ "${node_count}" -eq 0 ]]; then
        echo "No instances found in the cache for identifier '${identifier}'."
        exit 1
    fi
}

get_instances_from_aws() {
    if is_identifier_instance_id; then
        nodes=$(query_aws_by_id "$identifier")
    else
        nodes=$(query_aws_by_name "$identifier")
    fi
    # I don't want to cram the entire if statement into the condition of another one
    # shellcheck disable=SC2181
    if [[ "$?" -ne 0 ]]; then
        echo "[spoon] Encountered an error while using awscli. Please make sure it's installed and you are authorized to make requests."
        exit 1
    fi

    nodes="$(echo "${nodes}" | jq 'sort_by(.service)')"
    [[ "${arg_verybose}" = 1 ]] && echo -e "[spoon] instances returned from aws:\\n${nodes}"

    node_count=$(echo "${nodes}" | jq '. | length')
    if [[ "${node_count}" -eq 0 ]]; then
        echo "No instances returned from AWS for identifier '${identifier}'."
        exit 1
    fi
}

query_aws() {
    verbose_log "[spoon] querying aws..."
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
    query_aws --filters "Name=tag:Name,Values=*$1*"
}

query_aws_by_id() {
    verbose_log "query aws by id"
    query_aws --instance-ids "$1"
}
