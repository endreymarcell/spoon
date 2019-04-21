# Changelog

## v2.4.0
2019.04.21.
- Inform the user about estimated long-running AWS queries for better UX
- Identifier can be any of the arguments, support older bash versions
- Add suport for 'nonprod' instances
- Better handling of dry run: should stop right before calling SSH, not earlier
- Smart retry: if SSH fails after reading the cache, assume the cache is wrong and retry by querying AWS
- Minor logging improvements

## v2.3.2
2019.02.06.
- Fix lib file sourcing even better so that spoon actually works after brew install.

## v2.3.1
2019.02.05.
- Fix lib file sourcing so that spoon works after brew install.

## v2.3
2019.02.04.
- Recognize instance ids automatically.
- Better cache handling (create cache even if SSH fails, start creating earlier to save time).
- Support for VPC.
- Interactive mode with fzf.

## v2.1
2018.12.16.
- Add docker support again after the rewrite.
- Cache AWS response for 24 hours.
- Test in docker.

## v2.0
2018.12.02.
- Complete rewrite to improve code quality. Supports preprod/prod filtering, first/all instance selection, dry run and versbose logging.
- Tested with bats and linted with shellcheck.

## v1.2
2018.06.18.
- Add support for i2cssh on iTerm2.
- New switches for preprod/prod (-p/-P besides -e/-o).

## v1.1
2018.01.15.
- Select indices of listed nodes (eg. "1, 3, 5-8")

## v1.0
2018.01.02.
- Initial version. Supports preprod/prod filtering, plus docker and/or virtualenv activation.
