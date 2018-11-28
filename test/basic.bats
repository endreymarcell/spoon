#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

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
