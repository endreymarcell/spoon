# spoon

__Note: spoon is being rewritten from scratch. To see the the README for the last version released via homebrew, [click here](https://github.com/endreymarcell/spoon/blob/ec81fcdcae1b809fc2889c8bd8a71b530ac99d06/README.md).__  

[![CircleCI](https://circleci.com/gh/endreymarcell/spoon.svg?style=svg)](https://circleci.com/gh/endreymarcell/spoon)
[![Shellcheck](https://img.shields.io/badge/code%20style-shellcheck-lightgrey.svg)](https://github.com/koalaman/shellcheck)

Easily SSH into EC2 nodes.  

## Installation

Requirements: awscli, jq  
Optional: csshx or i2cssh  

```
brew tap endreymarcell/homebrew-marca
brew install spoon
```

## Usage

`spoon [options] identifier`  

Options:  
`-h` or `--help`  
`-v` or `--verbose`  
`-n` or `--dry-run`  
`-p` or `--preprod`  
`-P` or `--prod`  
`-1` or `--first`  
