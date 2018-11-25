.PHONY: test debug lint

test:
	bats test/*.bats

debug:
	bats -t test/*.bats | grep '^# '

lint:
	shellcheck spoon
