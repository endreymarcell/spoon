#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "If some, but not all nodes are in VPC, spoon exits." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-mixed.json)"

    run $spoon -a foo

    assert_failure
    assert_output --partial "[spoon] Cannot mix VPC and non-VPC nodes."
}

@test "If not all nodes are in the same VPC, spoon exits." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-different-vpc.json)"

    run $spoon -a foo

    assert_failure
    assert_output --partial "[spoon] All nodes must be in the same VPC."
}

@test "Spoon passes the correct jumphost param to csshx (single jumphost)." {
    set_config_to '{"vpcJumphosts": {"vpc-1": ["9.9.9.9"]}}'
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-vpc.json)"

    run $spoon -a foo

    assert_success
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" '--ssh_args -J root@9.9.9.9'
}

@test "Spoon passes the correct jumphost param to csshx (multiple jumphosts)." {
    set_config_to '{"vpcJumphosts": {"vpc-1": ["9.9.9.9", "8.8.8.8"]}}'
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-vpc.json)"

    run $spoon -a foo

    assert_success
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" '--ssh_args -J root@9.9.9.9,root@8.8.8.8'
}

@test "Spoon passes the correct jumphost param to i2cssh (single jumphost)." {
    set_config_to '{"vpcJumphosts": {"vpc-1": ["9.9.9.9"]}}'
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-vpc.json)"

    TERM_PROGRAM=iTerm.app run $spoon -a foo

    assert_success
    assert_equal_regex "$(mock_get_call_args $mock_i2cssh_path)" '-XJ=root@9.9.9.9'
}

@test "Spoon passes the correct jumphost param to i2cssh (multiple jumphosts)." {
    set_config_to '{"vpcJumphosts": {"vpc-1": ["9.9.9.9", "8.8.8.8"]}}'
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-vpc.json)"

    TERM_PROGRAM=iTerm.app run $spoon -a foo

    assert_success
    assert_equal_regex "$(mock_get_call_args $mock_i2cssh_path)" '-XJ=root@9.9.9.9,root@8.8.8.8'
}
