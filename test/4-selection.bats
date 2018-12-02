#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "Selection: no instances selected" {
	# GIVEN
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	# WHEN
	TERM_PROGRAM=Apple_Terminal run $spoon -P foo <<< ''

	#THEN
	assert_success
	assert_equal $(mock_get_call_num $mock_ssh_path) 0
}

@test "Selection: all instances selected via *" {
	skip "TODO"
}

@test "Selection: invalid selector (letters)" {
	skip "TODO"
}

@test "Selection: a single instance selected" {
	# GIVEN
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	# WHEN
	TERM_PROGRAM=Apple_Terminal run $spoon -P foo <<< 1

	#THEN
	assert_success
	assert_equal $(mock_get_call_num $mock_ssh_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '1.1.1.1'
}

@test "Selection: multiple single instances selected" {
	skip "TODO"
}

@test "Selection: single instance index out of range" {
	skip "TODO"
}

@test "Selection: one range selected" {
	skip "TODO"
}

@test "Selection: multiple ranges selected" {
	skip "TODO"
}

@test "Selection: range selector out of range" {
	skip "TODO"
}

@test "Selection: single and range selectors mixed" {
	skip "TODO"
}
