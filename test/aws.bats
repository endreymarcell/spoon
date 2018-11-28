#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "If called with an identifier, spoon should query aws." {
	run $spoon foo
	assert_equal $(mock_get_call_num $mock_aws_path) 1
}

@test "If called without the instance-id flag, spoon should query aws filtering for the service_name tag." {
	run $spoon foo
	[[ $(mock_get_call_args $mock_aws_path) =~ '--filters Name=tag:Name,Values=*foo*' ]]
}

@test "If called with the instance-id flag, spoon should query aws filtering for instance id." {
	run $spoon -i foo
	[[ $(mock_get_call_args $mock_aws_path) =~ '--instance-ids foo' ]]
}

@test "If the aws query errors out, spoon should print an error message and exit with 1." {
	mock_set_side_effect $mock_aws_path "exit 1"
	run $spoon foo
	assert_line "Encountered an error while using awscli. Please make sure it's installed and you are authorized to make requests."
	assert_failure
}

@test "If no instances are returned from aws, spoon should report this." {
	mock_set_output $mock_aws_path '[]'
	run $spoon foo
	assert_failure
	assert_output "No instances found for identifier 'foo'."
}

@test "If one instance is returned, spoon should attempt to ssh to it." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"
	run $spoon foo
	assert_success
	assert_equal $(mock_get_call_num $mock_ssh_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '1.1.1.1'
}

@test "If multiple instances are returned, spoon should check the availability of a cssh utility (csshx on Terminal)." {
	# setup
	export mock_command_path="$(mock_create)"
	function command() {
		bash "${mock_command_path}" "${@}"
	}
	export -f command

	# GIVEN
	mock_set_status $mock_command_path 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=Apple_Terminal run $spoon foo

	#THEN
	assert_failure
	assert_output "Please install csshX to SSH to multiple instances."
	assert_equal $(mock_get_call_num $mock_csshx_path) 0

	# teardown
	unset mock_command_path command
}

@test "If multiple instances are returned, spoon should check the availability of a cssh utility (i2cssh on iTerm2)." {
	# setup
	export mock_command_path="$(mock_create)"
	function command() {
		bash "${mock_command_path}" "${@}"
	}
	export -f command

	# GIVEN
	mock_set_status $mock_command_path 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=iTerm.app run $spoon foo

	#THEN
	assert_failure
	assert_output "Please install i2cssh to SSH to multiple instances."
	assert_equal $(mock_get_call_num $mock_i2cssh_path) 0

	# teardown
	unset mock_command_path command
}

@test "If multiple instances are returned, and a cssh utility is available (csshx on Terminal), spoon should pass all the IPs to it." {
	# setup
	export mock_command_path="$(mock_create)"
	function command() {
		bash "${mock_command_path}" "${@}"
	}
	export -f command

	# GIVEN
	mock_set_status $mock_command_path 0
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=Apple_Terminal run $spoon foo

	#THEN
	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" '1.1.1.1 2.2.2.2 3.3.3.3'

	# teardown
	unset mock_command_path command
}

@test "If multiple instances are returned, and a cssh utility is available (i2cssh on iTerm2), spoon should pass all the IPs to it." {
	# setup
	export mock_command_path="$(mock_create)"
	function command() {
		bash "${mock_command_path}" "${@}"
	}
	export -f command

	# GIVEN
	mock_set_status $mock_command_path 0
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=iTerm.app run $spoon foo

	#THEN
	assert_success
	assert_equal $(mock_get_call_num $mock_i2cssh_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_i2cssh_path)" '1.1.1.1 2.2.2.2 3.3.3.3'

	# teardown
	unset mock_command_path command
}

@test "Dry run: one instance." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"
	run $spoon -n foo
	assert_success
	assert_equal $(mock_get_call_num $mock_ssh_path) 0
}

@test "Dry run: multiple instances." {
	# setup
	export mock_command_path="$(mock_create)"
	function command() {
		bash "${mock_command_path}" "${@}"
	}
	export -f command

	# GIVEN
	mock_set_status $mock_command_path 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=Apple_Terminal run $spoon -n foo

	#THEN
	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 0

	# teardown
	unset mock_command_path command
}

@test "Filtering for prod: no instances returned." {
	skip
}

@test "Filtering for prod: one instance returned." {
	skip
}

@test "Filtering for prod: multiple instances returned." {
	skip
}

@test "Filtering for preprod: no instances returned." {
	skip
}

@test "Filtering for preprod: one instance returned." {
	skip
}

@test "Filtering for preprod: multiple instances returned." {
	skip
}

@test "First insance flag with no instances" {
	skip
}

@test "First insance flag with one instance" {
	skip
}

@test "First insance flag with multiple instances" {
	skip
}
