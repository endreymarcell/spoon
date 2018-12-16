#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "If there is no cache file, spoon queries aws." {
	skip
}

@test "If there an outdated cache file, spoon queries aws." {
	skip
}

@test "If there is a recent cache file, spoon does not query aws." {
	skip
}

@test "If there is an invalid cache file, spoon queries aws." {
	skip
}

@test "If there is a recent cache file but cache reading is disabled, spoon queries aws." {
	skip
}

@test "spoon can find a single instance in the cache based on their service name." {
	skip
}

@test "spoon can find multiple instances in the cache based on their service name." {
	skip
}

@test "spoon can find a single isntance in the cache based on their instance-id." {
	skip
}

@test "If there is no cache file, spoon builds one after running." {
	skip
}

@test "If there is an outdated cache file, spoon builds a new one after running." {
	skip
}

@test "If there is a recent cache file, spoon does not build one after running." {
	skip
}

@test "If there is no cache file but cache writing is disabled, spoon does not build one after running." {
	skip
}

@test "If there is no cache file, spoon builds one after running even if no instances were selected (empty specifier)." {
	skip
}

@test "If there is no cache file, spoon builds one after running even if no instances were selected (out-of-range specifier)." {
	skip
}

@test "If there is no cache file, spoon builds one after running even if ssh failed." {
	skip
}
