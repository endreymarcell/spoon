.PHONY: test lint

test:
	bats test/*.bats

lint:
	shellcheck spoon
