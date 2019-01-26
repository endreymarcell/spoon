#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

source "$BATS_TEST_DIRNAME/../lib/0-utils.bash"

@test "If there's no $CONFIG_FILE_DIR directory, get_config creates it." {
    rm -rf $CONFIG_FILE_DIR
    
    get_config

    assert test -d $CONFIG_FILE_DIR
}

@test "If there's no $CONFIG_FILE_PATH file, get_config creates a valid JSON file." {
    rm -rf $CONFIG_FILE_DIR
    mkdir $CONFIG_FILE_DIR
    
    get_config

    assert test -f $CONFIG_FILE_PATH
    assert_equal "$(cat $CONFIG_FILE_PATH)" '{}'
}

@test "If $CONFIG_FILE_PATH is not valid JSON, get_config exits." {
    set_config_to invalid contents
    
    assert_function_failure get_config .
}

@test "If $CONFIG_FILE_PATH is valid JSON but the passed jq expression fails on it, get_config exits." {
    set_config_to '{"something": 1}'
    
    assert_function_failure get_config .something.else
}

@test "If $CONFIG_FILE_PATH is valid JSON and the passed jq expression succeeds, get_config succeeds." {
    set_config_to '{"something": 1}'
    
    assert_function_success get_config .something
}
