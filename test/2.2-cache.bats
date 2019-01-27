#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"
source "$BATS_TEST_DIRNAME/../lib/0-utils.bash"

cache=$CACHE_FILE_PATH

@test "If there is no cache file, spoon queries aws." {
	run $spoon foo

	assert_equal $(mock_get_call_num $mock_aws_path) 2
}

@test "If there is an outdated cache file, spoon queries aws." {
	set_cache_to '[]'
	touch -d "25 hours ago" $cache

	run $spoon foo

	assert_equal $(mock_get_call_num $mock_aws_path) 2
}

@test "If there is a recent cache file, spoon does not query aws." {
	set_cache_to '[]'

	run $spoon foo

	assert_equal $(mock_get_call_num $mock_aws_path) 0
}

@test "If there is an invalid cache file, spoon queries aws." {
	set_cache_to invalid data

	run $spoon foo

	assert_equal $(mock_get_call_num $mock_aws_path) 2
}

@test "If there is a recent cache file but cache reading is disabled, spoon queries aws." {
	set_cache_to '[]'

	run -r $spoon foo

	assert_equal $(mock_get_call_num $mock_aws_path) 0
}

@test "spoon can find a single instance in the cache based on their service name." {
	set_cache_to "$(cat $BATS_TEST_DIRNAME/data/single.json)"

	run $spoon fooservice

	assert_equal $(mock_get_call_num $mock_ssh_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" 1.1.1.1
}

@test "spoon can find multiple instances in the cache based on their service name." {
	set_cache_to "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	run $spoon fooservice <<< '*'

	assert_equal $(mock_get_call_num $mock_csshx_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" "1.1.1.1 2.2.2.2 3.3.3.3"
}

@test "spoon can find a single instance in the cache based on their instance-id." {
	set_cache_to "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	run $spoon -i i-abcd2345

	assert_equal $(mock_get_call_num $mock_ssh_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" 2.2.2.2
}

@test "If there is no cache file, spoon builds one after running." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)" 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)" 2

	run $spoon foo

	assert_equal "$(cat $cache | jq .)" "$(cat $BATS_TEST_DIRNAME/data/multiple.json | jq .)"
}

@test "If there is an outdated cache file, spoon builds a new one after running." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)" 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)" 2
	set_cache_to '[]'
	touch -d "25 hours ago" $cache

	run $spoon foo

	assert_equal "$(cat $cache | jq .)" "$(cat $BATS_TEST_DIRNAME/data/multiple.json | jq .)"
}

@test "If there is a recent cache file, spoon does not build one after running." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"
	set_cache_to '[]'

	run $spoon foo

	assert_equal "$(cat $cache)" "[]"
}

@test "If there is a recent cache file but refresh is requested, spoon does build one after running." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)" 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)" 2
	set_cache_to '[]'

	run $spoon -r foo

	assert_equal "$(cat $cache)" "$(cat $BATS_TEST_DIRNAME/data/multiple.json | jq .)"
}

@test "If there is no cache file but cache writing is disabled, spoon does not build one after running." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"

	run $spoon -w foo

	assert_equal "$(ls $cache)" ""
}

@test "If there is no cache file but cache writing is already in progress, spoon does not build one after running." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)"
	[[ ! -d "$SPOON_HOME_DIR" ]] && mkdir -p "$SPOON_HOME_DIR"
	touch "${cache}.tmp"

	run $spoon foo

	assert_equal "$(ls $cache)" ""
}

@test "If there is no cache file, spoon builds one after running even if no instances were selected (empty specifier)." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)" 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)" 2

	run $spoon foo <<< ''

	assert_equal "$(cat $cache | jq .)" "$(cat $BATS_TEST_DIRNAME/data/multiple.json | jq .)"
}

@test "If there is no cache file, spoon builds one after running even if no instances were selected (out-of-range specifier)." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)" 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)" 2

	run $spoon foo <<< '99'

	assert_equal "$(cat $cache | jq .)" "$(cat $BATS_TEST_DIRNAME/data/multiple.json | jq .)"
}

@test "If there is no cache file, spoon builds one after running even if no instances were found." {
	mock_set_output $mock_aws_path "[]" 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)" 2

	run $spoon foo

	assert_equal "$(cat $cache | jq .)" "$(cat $BATS_TEST_DIRNAME/data/multiple.json | jq .)"
}

@test "If there is no cache file, spoon builds one after running even if ssh failed." {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/single.json)" 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)" 2
	mock_set_status $mock_ssh_path 1

	run $spoon foo

	assert_equal "$(cat $cache | jq .)" "$(cat $BATS_TEST_DIRNAME/data/multiple.json | jq .)"
}
