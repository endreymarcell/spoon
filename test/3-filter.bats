#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "Filtering for prod: no instances returned." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-preprod-only.json)"

    run $spoon -P foo

    assert_failure
    assert_output "[spoon] No instances found for identifier 'foo' after filtering for prod."
}

@test "Filtering for prod: one instance returned." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-one-prod-one-preprod.json)"

    run $spoon -P foo

    assert_success
    assert_equal $(mock_get_call_num $mock_ssh_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '1.1.1.1'
}

@test "Filtering for prod: multiple instances returned." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-prod-only.json)"

    run $spoon -P foo <<< ''

    assert_success
    assert_output "$(cat ${BATS_TEST_DIRNAME}/expected-output/multiple-prod-only)"
}

@test "Filtering for preprod: no instances returned." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-prod-only.json)"

    run $spoon -p foo

    assert_failure
    assert_output "[spoon] No instances found for identifier 'foo' after filtering for preprod."
}

@test "Filtering for preprod: one instance returned." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-one-prod-one-preprod.json)"

    run $spoon -p foo

    assert_success
    assert_equal $(mock_get_call_num $mock_ssh_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '2.2.2.2'
}

@test "Filtering for preprod: multiple instances returned." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-preprod-only.json)"

    run $spoon -p foo <<< ''

    assert_success
    assert_output "$(cat ${BATS_TEST_DIRNAME}/expected-output/multiple-preprod-only)"
}

@test "First instance flag with no instances" {
    mock_set_output $mock_aws_path '[]'

    run $spoon -1 foo

    assert_failure
    assert_output "[spoon] No instances returned from AWS for identifier 'foo'."
}

@test "First instance flag with one instance" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"

    run $spoon -1 foo

    assert_success
    assert_equal $(mock_get_call_num $mock_ssh_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '1.1.1.1'
}

@test "First instance flag with multiple instances" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

    run $spoon -1 foo

    assert_success
    assert_equal $(mock_get_call_num $mock_ssh_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '1.1.1.1'
}

@test "All instances flag with no instances" {
    mock_set_output $mock_aws_path '[]'

    run $spoon -a foo

    assert_failure
    assert_output "[spoon] No instances returned from AWS for identifier 'foo'."
}

@test "All instances flag with one instance" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"

    run $spoon -a foo

    assert_success
    assert_equal $(mock_get_call_num $mock_ssh_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '1.1.1.1'
}

@test "All instances flag with multiple instances" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

    run $spoon -a foo

    assert_success
    assert_equal $(mock_get_call_num $mock_csshx_path) 1
    assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" '1.1.1.1 2.2.2.2 3.3.3.3'
}

@test "Private IP is printed for VPC instances" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-vpc.json)"

    run $spoon foo <<< ''

    assert_success
    assert_output "$(cat ${BATS_TEST_DIRNAME}/expected-output/multiple-vpc)"
}

@test "Public IP, private IP and VPC ID are all printed properly." {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-public-private-mixed-ip.json)"

    run $spoon foo <<< ''

    assert_success
    assert_output "$(cat ${BATS_TEST_DIRNAME}/expected-output/multiple-public-private-mixed-ip)"
}
