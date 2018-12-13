#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "Docker flag calls SSH with the container command" {
    mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"

    run $spoon foo -d foo

    assert_success
    assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" 'HN=`hostname | cut -f 2 --delimiter=-`; INST_ID=`docker ps | grep $HN-app | cut -f 1 -d " "`; docker exec -ti $INST_ID bash -c '"'"'bash --init-file <(echo ". ../virtualenv/bin/activate")'"'"
}
