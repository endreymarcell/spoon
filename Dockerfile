FROM ubuntu:latest

RUN apt-get update && apt-get install -y git jq shellcheck bsdmainutils
RUN git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core && \
	cd /tmp/bats-core && \
	./install.sh /usr/local

RUN mkdir ~/.cache

WORKDIR /spoon
CMD bats test/*.bats
