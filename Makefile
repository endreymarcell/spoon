.PHONY: develop test debug lint

develop:
	git submodule init
	git submodule update
	make test
	make lint

test:
	docker run --rm -t -v "${PWD}:/spoon" endreymarca/bats-ext

debug:
	docker run --rm -ti -v "${PWD}:/spoon" endreymarca/bats-ext bash

lint:
	docker run -ti -v "${PWD}:/spoon" endreymarca/bats-ext shellcheck -x spoon lib/*
