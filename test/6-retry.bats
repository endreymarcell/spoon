#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "If SSH fails after reading the cache, spoon should retry." {
	set_cache_to "$(cat $BATS_TEST_DIRNAME/data/single.json)"
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"
	mock_set_status $mock_ssh_path 1

    run $spoon -w foo

    assert_success
    assert_equal $(mock_get_call_num $mock_aws_path) 1
    assert_equal $(mock_get_call_num $mock_ssh_path) 2
}

@test "If SSH (with docker) fails after reading the cache, spoon should retry." {
	set_cache_to "$(cat $BATS_TEST_DIRNAME/data/single.json)"
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"
	mock_set_status $mock_ssh_path 1

    run $spoon -dw foo

    assert_success
    assert_equal $(mock_get_call_num $mock_aws_path) 1
    assert_equal $(mock_get_call_num $mock_ssh_path) 2
}

@test "If csshx fails after reading the cache, spoon should retry." {
	set_cache_to "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"
	mock_set_status $mock_csshx_path 1

    run $spoon -aw foo

    assert_success
    assert_equal $(mock_get_call_num $mock_aws_path) 1
    assert_equal $(mock_get_call_num $mock_csshx_path) 2
}

@test "If i2cssh fails after reading the cache, spoon should retry." {
	set_cache_to "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"
	mock_set_status $mock_i2cssh_path 1

    TERM_PROGRAM=iTerm.app run $spoon -aw foo

    assert_success
    assert_equal $(mock_get_call_num $mock_aws_path) 1
    assert_equal $(mock_get_call_num $mock_i2cssh_path) 2
}
