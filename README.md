# spoon

[![CircleCI](https://circleci.com/gh/endreymarcell/spoon.svg?style=svg)](https://circleci.com/gh/endreymarcell/spoon)
[![Shellcheck](https://img.shields.io/badge/code%20style-shellcheck-lightgrey.svg)](https://github.com/koalaman/shellcheck)

Easily SSH into EC2 nodes.

## Installation

```
brew tap endreymarcell/homebrew-marca
brew install spoon
```
Requirements: [awscli](https://aws.amazon.com/cli/), [jq](https://stedolan.github.io/jq/)  
Optional:  
* cluster SSH: [csshx](https://github.com/brockgr/csshx) (if you're using Terminal) or [i2cssh](https://github.com/wouterdebie/i2cssh) (if you're using iTerm2)  
* interactive mode: [fzf](https://github.com/junegunn/fzf)  

## Usage

`spoon [options] [identifier]`

__Options:__  
`-h` or `--help`  
&nbsp;&nbsp;&nbsp;&nbsp;print usage information and exit  
`-v` or `--verbose`  
&nbsp;&nbsp;&nbsp;&nbsp;enable verbose logging  
`-n` or `--dry-run`  
&nbsp;&nbsp;&nbsp;&nbsp;print selected IPs but don't initiate SSH connection  
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

Single-letter options can be combined, ie. you can write `spoon -1pd` instead of `spoon -1 -p -d`.  

__Identifier:__  
If the identifier starts with `i-`, it is recognised as an instence-id. Otherwise, it's taken to be a service name, or at least part of it.  
If no identifier is passed, interactive mode is assumed.  

## Accessing nodes inside VPC

If the nodes you want to access are inside a VPC you need to specify your _VPC jump host(s)_.  
A jump host is a node that is accessible from the internet and can access the VPC,
effectively acting as a bridge between the two networks.

To do that you have to add these lines to your `~/.spoon/config.json` file:
```json
{
  "vpcJumphosts": {
    "<VPC-ID>": [
      "<<Jump-Host-Ip-1>>",
      "<<Jump-Host-Ip-2>>"
    ]
  }
}
```

Example:
```json
{
  "vpcJumphosts": {
    "vpc-abcd1234": [
      "1.2.3.4"
    ],
    "vpc-asdfasdf": [
      "1.2.3.4",
      "200.171.41.43"
    ],
    "vpc-ABCDEFGH": [
      "52.23.42.184"
    ]
  }
}
```

## Contribution
Pull requests are welcome.  
Run tests with `make test` (requires Docker) and the linter with `make lint` (requires [shellcheck](https://github.com/koalaman/shellcheck)).  
There's also a [CircleCI job](https://circleci.com/gh/endreymarcell/spoon).
