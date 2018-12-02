#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "Dry run: one instance." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"
	run $spoon -n foo
	assert_success
	assert_equal $(mock_get_call_num $mock_ssh_path) 0
}

@test "Dry run: multiple instances." {
	skip "have to figure out how to pass input to spoon from bats"

	# GIVEN
	mock_set_status $mock_command_path 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=Apple_Terminal run $spoon -n foo

	#THEN
	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 0
}
