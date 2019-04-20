#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "If multiple instances are returned, spoon should check the availability of a cssh utility (csshx on Terminal)." {
    mock_set_status $mock_command_path 1
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

    run $spoon -V foo <<< '*'

    assert_failure
    assert_line "[spoon] please install csshX to SSH to multiple instances (https://github.com/brockgr/csshx)"
    assert_equal $(mock_get_call_num $mock_csshx_path) 0
}

@test "If multiple instances are returned, spoon should check the availability of a cssh utility (i2cssh on iTerm2)." {
    mock_set_status $mock_command_path 1
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

    TERM_PROGRAM=iTerm.app run $spoon foo <<< '*'

    assert_failure
    assert_line "[spoon] please install i2cssh to SSH to multiple instances (https://github.com/wouterdebie/i2cssh)"
    assert_equal $(mock_get_call_num $mock_i2cssh_path) 0
}

@test "If multiple instances are returned, and a cssh utility is available (csshx on Terminal), spoon should pass all the IPs to it." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

    run $spoon foo <<< '*'

    assert_success
    assert_equal $(mock_get_call_num $mock_csshx_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" '1.1.1.1 2.2.2.2 3.3.3.3'
}

@test "If multiple instances are returned, and a cssh utility is available (i2cssh on iTerm2), spoon should pass all the IPs to it." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

    TERM_PROGRAM=iTerm.app run $spoon foo <<< '*'

    assert_success
    assert_equal $(mock_get_call_num $mock_i2cssh_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_i2cssh_path)" '1.1.1.1 2.2.2.2 3.3.3.3'
}
