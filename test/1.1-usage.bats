#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "If called with the help flag, spoon should print the help text and exit with 0." {
    run $spoon -h
    assert_success
    assert_line "usage: spoon [flags] [identifier]"
}

@test "If trying to filter for prod and preprod at the same time, spoon should complain and exit with 1." {
    run $spoon -p -P foo
    assert_failure
    assert_output "Invalid arguments: -P/--prod and -p/--preprod are mutually exclusive."
}

@test "If trying to SSH to the first and all instances at the same time, spoon should complain and exit with 1." {
    run $spoon -1 -a foo
    assert_failure
    assert_output "Invalid arguments: -1/--first and -a/--all are mutually exclusive."
}
