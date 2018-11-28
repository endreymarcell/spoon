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
