#!/usr/bin/env bash

declare nodes
declare arg_dry_run
declare arg_docker
declare CONFIG_FILE_PATH

spoon_ssh() {
    node_count=$(echo "${nodes}" | jq '. | length')
    verbose_log "number of instances: ${node_count}"
    if ! is_vpc=$(check_all_or_none_vpc); then
        spoon_log Cannot mix VPC and non-VPC nodes.
        exit 1
    fi
    if [[ "$is_vpc" = 1 ]]; then
        if ! check_same_vpc; then
            spoon_log All nodes must be in the same VPC.
            exit 1
        fi
    fi
    if [[ "${node_count}" -gt 1 ]]; then
        if [[ $is_vpc = 1 ]]; then
            ssh_multiple_vpc
        else
            ssh_multiple_non_vpc
        fi
    elif [[ "${node_count}" -eq 1 ]]; then
        if [[ $is_vpc = 1 ]]; then
            ssh_single_vpc
        else
            ssh_single_non_vpc
        fi
    fi
}

check_all_or_none_vpc() {
    vpc_node_count=$(echo "${nodes}" | jq 'map(select(.vpc)) | length')
    non_vpc_node_count=$(echo "${nodes}" | jq 'map(select(.vpc == null)) | length')
    if [[ "$node_count" = "$vpc_node_count" ]]; then
        echo 1
    elif [[ "$node_count" = "$non_vpc_node_count" ]]; then
        echo 0
    else
        return 1
    fi
}

check_same_vpc() {
    num_unique_vpc_ids="$(echo "${nodes}" | jq '.[] | .vpc' | sort | uniq | wc -l | xargs)"
    if [[ "$num_unique_vpc_ids" -gt 1 ]]; then
        return 1
    fi
}

ssh_multiple_vpc() {
    verbose_log "All nodes are in VPC."

    ips=$(echo "${nodes}" | jq '.[].privateIp' | tr -d '"' | xargs)
    verbose_log "IP addresses:\\n${ips// /\\n}"

    vpc=$(echo "${nodes}" | jq '.[0].vpc' | tr -d '"')
    verbose_log "VPC ID: ${vpc}"
    if ! vpc_config="$(get_config ".vpcJumphosts[\"$vpc\"]")"; then
        spoon_log "Error while reading $CONFIG_FILE_PATH"
        exit 1
    fi
    if [[ "$vpc_config" = "null" ]]; then
        spoon_log "Error: ${vpc} is not listed in $CONFIG_FILE_PATH"
        exit 1
    fi
    very_verbose_log "VPC jumphost config:" && echo "$vpc_config"
    jumphosts="$(echo "$vpc_config" | jq 'map("root@" + .) | join(",")' | tr -d '"')"

    if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        verbose_log "Preparing to call i2cssh"
        execute_ssh i2cssh -XJ="$jumphosts" "$ips"
        spoon_log hint: press Cmd+Shift+I to send your keyboard input to all the instances
    else
        verbose_log "Preparing to call csshx"
        csshx_ssh_args="-l root -o StrictHostKeyChecking=no -J $jumphosts"
        execute_ssh csshx "$ips"
    fi
}

ssh_multiple_non_vpc() {
    verbose_log "None of the nodes are in VPC."
    ips=$(echo "${nodes}" | jq '.[].publicIp' | tr -d '"' | xargs)
    verbose_log "IP addresses:\\n${ips// /\\n}"

    if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        verbose_log "Preparing to call i2cssh"
        execute_ssh i2cssh "$ips"
        spoon_log hint: press Cmd+Shift+I to send your keyboard input to all the instances
        # passing -o options (StrictHostKeyChecking) to i2cssh is currently not supported
        # see https://github.com/wouterdebie/i2cssh/issues/89 and https://github.com/wouterdebie/i2cssh/issues/79
    else
        verbose_log "Preparing to call csshx"
        csshx_ssh_args="-l root -o StrictHostKeyChecking=no"
        execute_ssh csshx "$ips"
    fi
}

check_cssh_availability() {
    verbose_log "TERM_PROGRAM is ${TERM_PROGRAM}"
    if [[ "${TERM_PROGRAM}" == iTerm.app ]]; then
        if ! command -v i2cssh >/dev/null; then
            spoon_log "please install i2cssh to SSH to multiple instances (https://github.com/wouterdebie/i2cssh)"
            exit 1
        fi
    else
        if ! command -v csshx >/dev/null; then
            spoon_log "please install csshX to SSH to multiple instances (https://github.com/brockgr/csshx)"
            exit 1
        fi
    fi
}

ssh_single_vpc() {
    verbose_log "The selected node is in VPC."
    ip=$(echo "${nodes}" | jq '.[0].privateIp' | tr -d '"')
    verbose_log "IP address: ${ip}"
    vpc=$(echo "${nodes}" | jq '.[0].vpc' | tr -d '"')
    verbose_log "VPC: ${vpc}"
    if ! vpc_config="$(get_config ".vpcJumphosts[\"$vpc\"]")"; then
        exit 1
    fi
    if [[ "$vpc_config" = "null" ]]; then
        spoon_log "Error: ${vpc} is not listed in $CONFIG_FILE_PATH"
        exit 1
    fi
    very_verbose_log "VPC jumphost config:" && echo "$vpc_config"
    jumphosts="$(echo "$vpc_config" | jq 'map("root@" + .) | join(",")' | tr -d '"')"
    verbose_log "Preparing to call SSH"
    if [[ "${arg_docker}" = 1 ]]; then
        execute_ssh ssh_with_docker -J "$jumphosts" "$ip"
    else
        execute_ssh ssh -J "$jumphosts" "$ip"
    fi
}

ssh_single_non_vpc() {
    verbose_log "The selected node is not in VPC."
    ip=$(echo "${nodes}" | jq '.[0].publicIp' | tr -d '"')
    verbose_log "IP address: $ip"
    verbose_log "Preparing to call SSH"
    if [[ "${arg_docker}" = 1 ]]; then
        execute_ssh ssh_with_docker "$ip"
    else
        execute_ssh ssh "$ip"
    fi
}

execute_ssh() {
    # I need to pass 'ssh_with_docker' but want to log 'ssh' only
    very_verbose_log "${*//_with_docker/}"
    ssh_executable="$1"
    shift
    ssh_options="$*"
    if [[ "${arg_dry_run}" = 1 ]]; then
        verbose_log "Dry run, exiting."
        exit 0
    fi
    if [[ "$ssh_executable" =~ csshx ]] || [[ "$ssh_executable" =~ i2cssh ]]; then
        check_cssh_availability
    fi
    case "$ssh_executable" in
        ssh)
            # shellcheck disable=SC2086
            ssh -o StrictHostKeyChecking=no -l root $ssh_options
            ;;
        ssh_with_docker)
            # shellcheck disable=SC2086
            ssh -o StrictHostKeyChecking=no -l root $ssh_options -t 'HN=`hostname | cut -f 2 --delimiter=-`; INST_ID=`docker ps | grep $HN-app | cut -f 1 -d " "`; docker exec -ti $INST_ID bash -c '"'"'bash --init-file <(echo ". ../virtualenv/bin/activate")'"'"
            ;;
        csshx)
            # shellcheck disable=SC2086
            csshx --ssh_args "$csshx_ssh_args" $ssh_options
            ;;
        i2cssh)
            # shellcheck disable=SC2086
            i2cssh -Xl=root $ssh_options
            ;;
    esac
}
