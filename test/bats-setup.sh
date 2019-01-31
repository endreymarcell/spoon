#!/usr/bin/env bash

# source bats helpers
source "$BATS_TEST_DIRNAME/lib/bats-support/load.bash"
source "$BATS_TEST_DIRNAME/lib/bats-assert/load.bash"
source "$BATS_TEST_DIRNAME/lib/bats-mock/src/bats-mock.bash"
source "$BATS_TEST_DIRNAME/lib/bats-utils.bash"

# utils
source "$BATS_TEST_DIRNAME/../lib/0-utils.bash"
set_config_to() {
	value="$*"
	[[ ! -d "$SPOON_HOME_DIR" ]] && mkdir -p "$SPOON_HOME_DIR"
	echo "$value" > "$CONFIG_FILE_PATH"
}
set_cache_to() {
	value="$*"
	[[ ! -d "$SPOON_HOME_DIR" ]] && mkdir -p "$SPOON_HOME_DIR"
	echo "$value" > "$CACHE_FILE_PATH"
}

# setup test environment
setup() {
	export mock_aws_path="$(mock_create)"
	export mock_ssh_path="$(mock_create)"
	export mock_csshx_path="$(mock_create)"
	export mock_i2cssh_path="$(mock_create)"
	export mock_fzf_path="$(mock_create)"
	export mock_command_path="$(mock_create)"

	export -f aws ssh csshx i2cssh fzf command

	spoon="$BATS_TEST_DIRNAME/../spoon"

	rm -rf $SPOON_HOME_DIR
}

# overwrite executables with mocks
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

fzf() {
	bash "${mock_fzf_path}" "${@}"
}

command() {
	bash "${mock_command_path}" "${@}"
}
