.PHONY: test lint

test:
	bats test/test.bats

lint:
	shellcheck spoon
