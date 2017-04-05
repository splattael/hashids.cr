# v0.2.1 - 2017-04-05

### Fixed

* Support Crystal `>= 0.21.0` since `String#to_slice` is read-only

# v0.2.0 - 2017-01-09

### Added

* Run benchmarks with `make benchmarks`

### Changed

* Perf: Use String::Builder + reverse
* Perf: Use more idiomatic (and faster) Crystal in `decode_hex`
* Perf: Create regexps for guards and seps only once
* Perf: Speed up shuffling by 9x
* Pass a block to `times`

# v0.1.0 - 2016-07-28

### Added

* Initial implementation based on Ruby's code and JavaScript's tests
