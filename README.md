# spoon

Easily SSH into EC2 nodes.  
[![CircleCI](https://circleci.com/gh/endreymarcell/spoon.svg?style=svg)](https://circleci.com/gh/endreymarcell/spoon)
[![Shellcheck](https://img.shields.io/badge/code%20style-shellcheck-lightgrey.svg)](https://github.com/koalaman/shellcheck)

## Installation

```
brew tap endreymarcell/homebrew-marca
brew install spoon
```

## Usage

`spoon [-ieo1dv] identifier`

__search modifiers:__  
    `-i`    use instance id rather than instance name  
    `-1`    use the first instance, even when there are more than one results  
    `-e`    only list preprod instances (if applicable), only works when filtering for name  
    `-o`    only list production instances (if applicable), only works when filtering for name  

__after-search utilities (only for single instances):__  
    `-d`    log into the docker container on the instance  
    `-v`    activate to virtualenv on the instance  

Typing `spoon help` will also list these options.  

## Examples

List all signup instances:  
```bash
$ spoon signup
```

List all preprod tokenbroker instances:  
```bash
$ spoon -e tokenbr
```

Directly log into the first available production licenseprovisioning instance:  
```bash
$ spoon -1o provi
```

Directly log into the first available authservice instance and activate the virtualenv:  
```bash
$ spoon -1v tationser
```
_Note: the names of "presentationservice" and "presentationcontentservice" share a long prefix, therefore I typed the middle of the name to get an unambigious identifier with only a couple of characters._  

List all preprod socialauthservice instances, select one, log in and enter the docker container:  
```bash
$ spoon -ed sociala
```
_Note: please keep in mind that since your search term will be insterted between catch-all wildcards, searching for `authservice` will also bring up `socialauthservice` instances._  

Directly log in to the first available production liveprezi instance, enter docker and activate the virtualenv:  
```bash
$ spoon -1odv livepre
```

