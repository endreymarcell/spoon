#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"
source "$BATS_TEST_DIRNAME/../lib/0-utils.bash"


@test "Spoon gets the VPC jumphosts from the config for VPC nodes (single jumphost)." {
    set_config_to '{"vpcJumphosts": {"vpc-1": ["9.9.9.9"]}}'
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single-vpc.json)"

    run $spoon foo

    assert_success
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '-J root@9.9.9.9'
}

@test "Spoon gets the VPC jumphosts from the config for VPC nodes (multiple jumphosts)." {
    set_config_to '{"vpcJumphosts": {"vpc-1": ["9.9.9.9", "8.8.8.8", "7.7.7.7"]}}'
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single-vpc.json)"

    run $spoon foo

    assert_success
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '-J root@9.9.9.9,root@8.8.8.8,root@7.7.7.7'
}

@test "If the config file is invalid, spoon exits." {
    set_config_to not a JSON
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single-vpc.json)"

    run $spoon foo

    assert_failure
    assert_output "[spoon] Error: $CONFIG_FILE_PATH is not valid JSON"
}

@test "If the VPC ID is not listed in the config file, spoon exits." {
    set_config_to '{"vpcJumphosts": {"vpc-somethingelse": ["9.9.9.9", "8.8.8.8", "7.7.7.7"]}}'
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single-vpc.json)"

    run $spoon foo

    assert_failure
    assert_output "[spoon] Error: vpc-1 is not listed in /root/.spoon/config.json"
}

@test "If the selected instance is in VPC, the private IP is used, even if a public IP is also present." {
    set_config_to '{"vpcJumphosts": {"vpc-1": ["9.9.9.9"]}}'
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single-vpc-both-public-private-ip.json)"

    run $spoon foo

    assert_success
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '-o StrictHostKeyChecking=no -J root@9.9.9.9 -l root 2.2.2.2'
}