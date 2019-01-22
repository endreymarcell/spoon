spoon_ssh() {
    node_count=$(echo "${nodes}" | jq '. | length')
    verbose_log "[spoon] number of instances: ${node_count}"
    if [[ "${node_count}" -gt 1 ]]; then
        ips=$(echo "${nodes}" | jq '.[].publicIp' | tr -d '"' | xargs)
        verbose_log "[spoon] IP addresses:"
        [[ "${arg_verbose}" = 1 ]] && for ip in ${ips}; do echo "${ip}"; done
        ssh_multiple "${ips}"
    elif [[ "${node_count}" -eq 1 ]]; then
        ip=$(echo "${nodes}" | jq '.[0].publicIp' | tr -d '"')
        verbose_log "[spoon] IP address: ${ip}"
        ssh_single -o StrictHostKeyChecking=no -l root  "${ip}"
    fi
}

ssh_single() {
    [[ "${arg_dry_run}" = 1 ]] && return
    verbose_log "[spoon] calling ssh"
    if [[ "${arg_docker}" = 1 ]]; then
        ssh "${@}" -t 'HN=`hostname | cut -f 2 --delimiter=-`; INST_ID=`docker ps | grep $HN-app | cut -f 1 -d " "`; docker exec -ti $INST_ID bash -c '"'"'bash --init-file <(echo ". ../virtualenv/bin/activate")'"'"
    else
        ssh "${@}"
    fi
}

ssh_multiple() {
    [[ "${arg_dry_run}" = 1 ]] && return
    check_cssh_availability
    if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        verbose_log "[spoon] calling i2cssh"
        # I actually need the word splitting here, hence the lack of quotes
        # shellcheck disable=SC2086
        i2cssh --login root $1
        echo hint: press Cmd+Shift+I to send your keyboard input to all the instances
    else
        verbose_log "[spoon] calling csshx"
        # I actually need the word splitting here, hence the lack of quotes
        # shellcheck disable=SC2086
        csshx --login root $1
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
