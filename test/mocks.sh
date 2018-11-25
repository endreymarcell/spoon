#!/usr/bin/env bash

aws() {
	touch aws_called
}

ssh() {
	touch ssh_called
}

csshx() {
	touch csshx_called
}

i2cssh() {
	touch i2cssh_called
}
