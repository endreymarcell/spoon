#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/lib/bats-support/load.bash"
source "$BATS_TEST_DIRNAME/lib/bats-assert/load.bash"
source "$BATS_TEST_DIRNAME/lib/bats-utils.bash"

source "$BATS_TEST_DIRNAME/../spoon"

@test "has_short_flag" {
    assert_function_failure has_short_flag x spoon foo
    assert_function_failure has_short_flag x spoon -y
    assert_function_failure has_short_flag x spoon -a -b -c foo
    assert_function_failure has_short_flag x spoon -abc
    assert_function_success has_short_flag x spoon -x
    assert_function_success has_short_flag x spoon -x -a -b -c
    assert_function_success has_short_flag x spoon -a -b -c -x
    assert_function_success has_short_flag x spoon -xyz
    assert_function_success has_short_flag x spoon -abcx
    assert_function_success has_short_flag x spoon -abxcd
}

@test "has_long_flag" {
    assert_function_failure has_long_flag bar spoon foo
    assert_function_failure has_long_flag bar spoon foo -y
    assert_function_failure has_long_flag bar spoon foo -bar
    assert_function_success has_long_flag bar spoon foo --bar
    assert_function_success has_long_flag bar spoon foo --bar --baz
    assert_function_success has_long_flag bar spoon foo -x --bar -y
}

@test "jqrangify" {
    assert_equal "$(jqrangify 1)" '.[0:1] + []'
    assert_equal "$(jqrangify 1, 2)" '.[0:1] + .[1:2] + []'
    assert_equal "$(jqrangify 1-2)" '.[0:2] + []'
    assert_equal "$(jqrangify 1, 3, 5-10)" '.[0:1] + .[2:3] + .[4:10] + []'
}
