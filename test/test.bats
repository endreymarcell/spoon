#!/usr/bin/env bats

spoon="$BATS_TEST_DIRNAME/../spoon"

@test "tests are running" {
  run $spoon
  [ "$status" -eq 1 ]
  [ "$output" = "spoon went tits up" ]
}
