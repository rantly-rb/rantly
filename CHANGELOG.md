# Change Log
All notable changes to rantly will be documented in this file. The curated log begins at changes to version 0.4.0.

This project adheres to [Semantic Versioning](http://semver.org/).

## [0.4.0][0.4.0] - 2015-12-14
### Added
- Trying harder to shrink collections instead of giving up on first success of property.
- Added convenience classes Static and Tuple for more control on shrinking

## [0.3.2][0.3.2] - 2015-09-16
### Added
- Ability to shrink an object (`Integer`, `String`, `Array`, `Hash`). This is useful in finding the minimum value that fails a property check condition.

### Changed
- Improved RSpec and Minitest test extensions.
- Improved readability and execution of test suite ([Issue #4][4]).
- Updates to documentation.

[0.4.0]:    https://github.com/abargnesi/rantly/compare/0.3.2...0.4.0
[0.3.2]:    https://github.com/abargnesi/rantly/compare/0.3.1...0.3.2
[4]:        https://github.com/abargnesi/rantly/issues/13
