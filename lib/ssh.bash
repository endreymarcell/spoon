spoon_ssh() {
    node_count=$(echo "${nodes}" | jq '. | length')
    verbose_log "[spoon] number of instances: ${node_count}"
    if ! is_vpc=$(check_vpc); then
        echo Cannot mix VPC and non-VPC nodes.
        exit 1
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

check_vpc() {
    vpc_node_count=$(echo "${nodes}" | jq 'map(select(.vpc)) | length')
    non_vpc_node_count=$(echo "${nodes}" | jq 'map(select(.vpc == null)) | length')
    if [[ $node_count = $vpc_node_count ]]; then
        echo 1
    elif [[ $node_count = $non_vpc_node_count ]]; then
        echo 0
    else
        return 1
    fi
}

ssh_multiple_vpc() {
    verbose_log All nodes are in VPC.
    ips=$(echo "${nodes}" | jq '.[].privateIp' | tr -d '"' | xargs)
    verbose_log "[spoon] IP addresses:"
    [[ "${arg_verbose}" = 1 ]] && for ip in ${ips}; do echo "${ip}"; done
    echo to be implemented
    exit 1
}

ssh_multiple_non_vpc() {
    verbose_log None of the nodes are in VPC.
    ips=$(echo "${nodes}" | jq '.[].publicIp' | tr -d '"' | xargs)
    verbose_log "[spoon] IP addresses:"
    [[ "${arg_verbose}" = 1 ]] && for ip in ${ips}; do echo "${ip}"; done
    [[ "${arg_dry_run}" = 1 ]] && return
    check_cssh_availability
    if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        verbose_log "[spoon] calling i2cssh"
        # I actually need the word splitting here, hence the lack of quotes
        # shellcheck disable=SC2086
        i2cssh --login root $ips
        echo hint: press Cmd+Shift+I to send your keyboard input to all the instances
    else
        verbose_log "[spoon] calling csshx"
        # I actually need the word splitting here, hence the lack of quotes
        # shellcheck disable=SC2086
        csshx --login root $ips
    fi
}

check_cssh_availability() {
    verbose_log "[spoon] TERM_PROGRAM is ${TERM_PROGRAM}"
    if [[ "${TERM_PROGRAM}" == iTerm.app ]]; then
        if ! command -v i2cssh >/dev/null; then
            echo Please install i2cssh to SSH to multiple instances.
            exit 1
        fi
    else
        if ! command -v csshx >/dev/null; then
            echo Please install csshX to SSH to multiple instances.
            exit 1
        fi
    fi
}

ssh_single_vpc() {
    verbose_log The selected node is in VPC.
    ip=$(echo "${nodes}" | jq '.[0].privateIp' | tr -d '"')
    verbose_log "[spoon] IP address: ${ip}"
    echo to be implemented
    exit 1
}

ssh_single_non_vpc() {
    verbose_log The selected node is not in VPC.
    ip=$(echo "${nodes}" | jq '.[0].publicIp' | tr -d '"')
    verbose_log "[spoon] IP address: ${ip}"
    [[ "${arg_dry_run}" = 1 ]] && return
    verbose_log "[spoon] calling ssh"
    if [[ "${arg_docker}" = 1 ]]; then
        ssh -o StrictHostKeyChecking=no -l root "${ip}" -t 'HN=`hostname | cut -f 2 --delimiter=-`; INST_ID=`docker ps | grep $HN-app | cut -f 1 -d " "`; docker exec -ti $INST_ID bash -c '"'"'bash --init-file <(echo ". ../virtualenv/bin/activate")'"'"
    else
        ssh -o StrictHostKeyChecking=no -l root "${ip}"
    fi
}
