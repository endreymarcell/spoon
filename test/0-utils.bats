#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/lib/bats-support/load.bash"
source "$BATS_TEST_DIRNAME/lib/bats-assert/load.bash"
source "$BATS_TEST_DIRNAME/lib/bats-utils.bash"

source "$BATS_TEST_DIRNAME/../lib/0-utils.bash"

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

@test "get_identifier" {
    assert_equal "$(get_identifier '')" ''
    assert_equal "$(get_identifier 'foo')" 'foo'
    assert_equal "$(get_identifier '-f')" ''
    assert_equal "$(get_identifier '--foo')" ''
    assert_equal "$(get_identifier '-f bar')" 'bar'
    assert_equal "$(get_identifier '--foo bar')" 'bar'
    assert_equal "$(get_identifier 'bar -f')" 'bar'
    assert_equal "$(get_identifier 'bar --foo')" 'bar'
    assert_equal "$(get_identifier '-f bar -b')" 'bar'
    assert_equal "$(get_identifier '--foo bar --baz')" 'bar'
    assert_equal "$(get_identifier '-f --foo bar -b --baz')" 'bar'
    assert_equal "$(get_identifier '-f --foo -b --bar baz')" 'baz'
    assert_equal "$(get_identifier 'foo -b --bar -s --spam')" 'foo'
    assert_equal "$(get_identifier '-1Pd --verbose something')" 'something'
    assert_equal "$(get_identifier '-1Pd something --verbose')" 'something'
    assert_equal "$(get_identifier 'something -1Pd --verbose')" 'something'
}

@test "jqrangify" {
    assert_equal "$(jqrangify 1)" '.[0:1] + []'
    assert_equal "$(jqrangify 1, 2)" '.[0:1] + .[1:2] + []'
    assert_equal "$(jqrangify 1-2)" '.[0:2] + []'
    assert_equal "$(jqrangify 1, 3, 5-10)" '.[0:1] + .[2:3] + .[4:10] + []'
}
