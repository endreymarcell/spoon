#!/usr/bin/env bats

load "$BATS_TEST_DIRNAME/environment.sh"
load "/usr/local/lib/bats-mock.bash"

@test "If called without arguments, spoon should print the help text and exit with 1." {
	run $spoon
	[ "$status" -eq 1 ]
	[ "$output" = "usage: spoon [flags] <identifier>" ]
}

@test "If called with the help flag, spoon should print the help text and exit with 0." {
	run $spoon -h
	[ "$status" -eq 0 ]
	[ "$output" = "usage: spoon [flags] <identifier>" ]
}

@test "If called with flags only, spoon should complain and exit with 1." {
	run $spoon -flags
	[ "$status" -eq 1 ]
	[ "$output" = "identifier must not be empty" ]
}

@test "If called with an identifier, spoon should query aws." {
	run $spoon foo
	[ $(mock_get_call_num $mock_aws_path) -eq 1 ]
}
