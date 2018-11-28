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

@test "If multiple instances are returned, spoon should attempt to ssh to all of them via csshx." {
	skip
}

@test "If multiple instances are returned in iTerm, spoon should attempt to ssh to all of them via i2cssh." {
	skip
}

@test "Dry run: no instances." {
	skip
}

@test "Dry run: one instance." {
	skip
}

@test "Dry run: multiple instances." {
	skip
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
