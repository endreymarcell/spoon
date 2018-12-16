.PHONY: test debug lint

test:
	docker run -v "${PWD}:/spoon" endreymarca/bats-ext

debug:
	docker run -ti -v "${PWD}:/spoon" endreymarca/bats-ext bash

lint:
	shellcheck spoon
