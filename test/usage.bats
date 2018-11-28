#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "If called without arguments, spoon should print the help text and exit with 1." {
	run $spoon
	assert_failure
	assert_output "usage: spoon [flags] <identifier>"
}

@test "If called with the help flag, spoon should print the help text and exit with 0." {
	run $spoon -h
	assert_success
	assert_output "usage: spoon [flags] <identifier>"
}

@test "If called with flags only, spoon should complain and exit with 1." {
	run $spoon -flags
	assert_failure
	assert_output "identifier must not be empty"
}
