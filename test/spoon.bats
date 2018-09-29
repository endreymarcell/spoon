#!/usr/bin/env bats

spoon="$BATS_TEST_DIRNAME/../spoon"

aws() {
	touch trallalla
}

@test "tests are running" {
  run $spoon
  [ "$status" -eq 1 ]
}

@test "I can mock external calls" {
  export -f aws
	run $spoon soci
  [ "$status" -eq 0 ]
}
