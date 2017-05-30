# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [unreleased]
### Added
- CommentableBlock/SubStyle now accepts a 'regex' part of the matcher to
  handle different comments within a single file.
- ./run-most-recent-test script for faster testing in development.
### Changed
- CommentableParagraphIntro now auto-inserts leading whitespace.
### Fixed
- CommentableParagraphIntro now correctly matches sub-lists.

## [0.2.0] - 2017-03-25
### Added
- CommentableSetDefaultBindings adds some standard maps.
- Pretty colours for test output.
### Removed
- No submodule dependencies.
### Changed
- Better commenting througout.
- CommentableCreate has join functionality.

## [0.1.0]
### Added
- Initial project structure, tests and functionality.

[unreleased]: https://www.github.com/FalacerSelene/vim-commentable
[0.2.0]: https://www.github.com/FalacerSelene/vim-commentable/tree/0.2.0
[0.1.0]: https://www.github.com/FalacerSelene/vim-commentable/tree/0.1.0
