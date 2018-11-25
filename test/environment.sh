#!/usr/bin/env bash

# create mocks and export mock utility functions
setup() {
	export mock_aws_path="$(mock_create)"
	export mock_ssh_path="$(mock_create)"
	export mock_csshx_path="$(mock_create)"
	export mock_i2cssh_path="$(mock_create)"
	spoon="$BATS_TEST_DIRNAME/../spoon"
	export -f aws ssh csshx i2cssh
}


# allow printing debug output during tests, call with 'make debug'
debug() {
	echo "# ${@}" 1>&3
}


# mock out programs called by spoon
aws() {
	bash "${mock_aws_path}" "${@}"
}

ssh() {
	bash "${mock_ssh_path}" "${@}"
}

csshx() {
	bash "${mock_csshx_path}" "${@}"
}

i2cssh() {
	bash "${mock_i2cssh_path}" "${@}"
}
