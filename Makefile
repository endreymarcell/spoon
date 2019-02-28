.PHONY: test debug lint

test:
	docker run --rm -t -v "${PWD}:/spoon" endreymarca/bats-ext

debug:
	docker run --rm -ti -v "${PWD}:/spoon" endreymarca/bats-ext bash

lint:
	shellcheck -x spoon lib/*
