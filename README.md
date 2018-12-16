# spoon

[![CircleCI](https://circleci.com/gh/endreymarcell/spoon.svg?style=svg)](https://circleci.com/gh/endreymarcell/spoon)
[![Shellcheck](https://img.shields.io/badge/code%20style-shellcheck-lightgrey.svg)](https://github.com/koalaman/shellcheck)

Easily SSH into EC2 nodes.

## Installation

```
brew tap endreymarcell/homebrew-marca
brew install spoon
```
Requirements: [awscli](https://aws.amazon.com/cli/), [jq](https://stedolan.github.io/jq/) (spoon installs these automatically if they're missing)  
Optional: [csshx](https://github.com/brockgr/csshx) or [i2cssh](https://github.com/wouterdebie/i2cssh)  

(Note: spoon is a single executable bash script, so if you can't/don't want to use Homebrew, you can just copy the file and put it on your path.)  

## Usage

`spoon [options] identifier`

__Options:__  
`-h` or `--help`  
&nbsp;&nbsp;&nbsp;&nbsp;print usage information and exit  
`-v` or `--verbose`  
&nbsp;&nbsp;&nbsp;&nbsp;enable verbose logging  
`-n` or `--dry-run`  
&nbsp;&nbsp;&nbsp;&nbsp;print selected IPs but don't initiate SSH connection  
`-i` or `--instance-id`  
&nbsp;&nbsp;&nbsp;&nbsp;find instance by id rather than service name  
`-p` or `--preprod`  
&nbsp;&nbsp;&nbsp;&nbsp;filter for preprod instances  
`-P` or `--prod`  
&nbsp;&nbsp;&nbsp;&nbsp;filter for production instances  
`-1` or `--first`  
&nbsp;&nbsp;&nbsp;&nbsp;if there are multiple instances, select the first one without a prompt  
`-a` or `--all`  
&nbsp;&nbsp;&nbsp;&nbsp;if there are multiple instances, select all of them without a prompt  
`-d` or `--docker`  
&nbsp;&nbsp;&nbsp;&nbsp;enter the docker container of the application on the instance  
`-r` or `--no-cache-read`  
&nbsp;&nbsp;&nbsp;&nbsp;don't try to read instances from the cache  
`-w` or `--no-cache-write`  
&nbsp;&nbsp;&nbsp;&nbsp;don't cache instances  

__Identifier:__  
Either (the part of) a service name, or the instance ID (if the `-i` flag is provided).  

## Contribution
Pull requests are welcome.  
Run tests with `make test` (requires [bats-core](https://github.com/bats-core/bats-core)) and the linter with `make lint` (requires [shellcheck](https://github.com/koalaman/shellcheck)).  
There's also a [CircleCI job](https://circleci.com/gh/endreymarcell/spoon).
