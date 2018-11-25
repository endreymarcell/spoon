#!/usr/bin/env bash

setup() {
	export -f aws ssh csshx i2cssh
	echo "$(mock_create)" > mock_aws_path
	echo "$(mock_create)" > mock_ssh_path
	echo "$(mock_create)" > mock_csshx_path
	echo "$(mock_create)" > mock_i2cssh_path
}

teardown() {
	rm -f mock_aws_path mock_ssh_path mock_csshx_path mock_i2cssh_path
}

debug() {
	echo "# ${@}" 1>&3
}

aws() {
	bash "$(cat mock_aws_path)" "${@}"
}

ssh() {
	bash "$(cat mock_ssh_path)" "${@}"
}

csshx() {
	bash "$(cat mock_csshx_path)" "${@}"
}

i2cssh() {
	bash "$(cat mock_i2cssh_path)" "${@}"
}
