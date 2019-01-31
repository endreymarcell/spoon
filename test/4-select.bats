#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "Selection: no instances selected" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< ''

    assert_success
    assert_equal $(mock_get_call_num $mock_ssh_path) 0
}

@test "Selection: all instances selected via *" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< '*'

    assert_success
    assert_equal $(mock_get_call_num $mock_csshx_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" \
        "1.1.1.1 2.2.2.2 3.3.3.3 4.4.4.4 5.5.5.5 6.6.6.6 7.7.7.7 8.8.8.8 9.9.9.9"
}

@test "Selection: invalid selector (letters)" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< gibberish

    assert_failure
    assert_line "[spoon] jq error: invalid selector"
}

@test "Selection: a single instance selected" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< 1

    assert_success
    assert_equal $(mock_get_call_num $mock_ssh_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '1.1.1.1'
}

@test "Selection: multiple single instances selected" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< '1, 5'

    assert_success
    assert_equal $(mock_get_call_num $mock_csshx_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" '1.1.1.1 5.5.5.5'
}

@test "Selection: single instance index out of range" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< 99

    assert_success
    assert_equal $(mock_get_call_num $mock_ssh_path) 0
}

@test "Selection: one range selected" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< '1-5'

    assert_success
    assert_equal $(mock_get_call_num $mock_csshx_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" \
        '1.1.1.1 2.2.2.2 3.3.3.3 4.4.4.4 5.5.5.5'
}

@test "Selection: multiple ranges selected" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< '1-3, 7-9'

    assert_success
    assert_equal $(mock_get_call_num $mock_csshx_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" \
        '1.1.1.1 2.2.2.2 3.3.3.3 7.7.7.7 8.8.8.8 9.9.9.9'
}

@test "Selection: range selector out of range" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< '8-12'

    assert_success
    assert_equal $(mock_get_call_num $mock_csshx_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" "8.8.8.8 9.9.9.9"
}

@test "Selection: single and range selectors mixed" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

    run $spoon foo <<< '2, 4-6, 8'

    assert_success
    assert_equal $(mock_get_call_num $mock_csshx_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" "2.2.2.2 4.4.4.4 5.5.5.5 6.6.6.6 8.8.8.8"
}

@test "Interactive mode: if fzf is not installed, spoon exits." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"
    mock_set_status $mock_command_path 1

    run $spoon -i foo

    assert_failure
    assert_output '[spoon] please install fzf to use interactive mode (https://github.com/junegunn/fzf)'
}

@test "Interactive mode: if fzf is installed, spoon calls it." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"
    mock_set_status $mock_command_path 0

    run $spoon -i foo

    assert_success
    assert_equal $(mock_get_call_num $mock_command_path) 1
}

@test "If no argument is passed to spoon, interactive mode is assumed." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"
    mock_set_status $mock_command_path 0

    run $spoon

    assert_success
    assert_equal $(mock_get_call_num $mock_command_path) 1
}
