# spoon

__Note: spoon is being rewritten from scratch. To see the the README for the last version released via homebrew, [click here](https://github.com/endreymarcell/spoon/blob/ec81fcdcae1b809fc2889c8bd8a71b530ac99d06/README.md).__

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

__Identifier:__  
Either (the part of) a service name, or the instance ID (if the `-i` flag is provided).  
