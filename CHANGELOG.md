# Change Log
All notable changes to rantly will be documented in this file. The curated log begins at changes to version 0.4.0.

This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0][1.1.0] - 2017-04-18
### Improved
- Include failed example and number of example run in failure message.
  - [Issue #21][21]
  - thanks [Ana María Martínez Gómez][Ana María Martínez Gómez]
- Improve run-time for generation of strings.
  - [Issue #19][19]

## [1.0.0][1.0.0] - 2016-07-06
### Added
- Trying harder to shrink collections instead of giving up on first success of property.
  - thanks [Eric Bischoff][Eric Bischoff]
- Added convenience classes Deflating and Tuple for more control on shrinking.
  - thanks [Eric Bischoff][Eric Bischoff]
- Added usage examples for Deflating and Tuple shrinking strategies.
  - thanks [Oleksii Fedorov][Oleksii Fedorov]
- `Property#check` will now use the `RANTLY_COUNT` environment variable to control the number of values generated.
  - thanks [Jamie English][Jamie English]

### Major changes
- Array shrink was removed in favor of Tuple and Deflating.

## [0.3.2][0.3.2] - 2015-09-16
### Added
- Ability to shrink an object (`Integer`, `String`, `Array`, `Hash`). This is useful in finding the minimum value that fails a property check condition.

### Changed
- Improved RSpec and Minitest test extensions.
- Improved readability and execution of test suite.
  - [Issue #4][4]
- Updates to documentation.

[1.0.0]:                    https://github.com/abargnesi/rantly/compare/0.3.2...1.0.0
[0.3.2]:                    https://github.com/abargnesi/rantly/compare/0.3.1...0.3.2
[4]:                        https://github.com/abargnesi/rantly/issues/4
[19]:                       https://github.com/abargnesi/rantly/issues/19
[21]:                       https://github.com/abargnesi/rantly/issues/21
[Eric Bischoff]:            https://github.com/Bischoff
[Jamie English]:            https://github.com/english
[Oleksii Fedorov]:          https://github.com/waterlink
[Ana María Martínez Gómez]: https://github.com/Ana06
