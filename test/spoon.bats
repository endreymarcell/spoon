#!/usr/bin/env bats

spoon="$BATS_TEST_DIRNAME/../spoon"
load "$BATS_TEST_DIRNAME/mocks.sh"

setup() {
	export -f aws ssh csshx i2cssh
}

teardown() {
	rm -f aws_called ssh_called csshx_called i2cssh_called
}

debug() {
	echo "# ${@}" 1>&3
}

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
	[ -f aws_called ]
}
