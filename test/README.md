
# CMAKELIB Test Suite

Comprehensive test suite for the CMAKELIB library.

CMlib is consistent and working if and only if all tests pass!

If one test fails the CMlib does not work as expected! Even if the failure is not directly related to the needed functionality! Whole consistency is needed to be sure the system works as expected!

## Known Problems

- git archive funcionality is not tested on Github because Github does not support it.
  - The gitlab [fork of cmakelib-test] repo is used instead as a resource for testing `git archive`.
  - The git uri to the gitlab repo is hardcoded in the `FILE_DOWNLOAD/CMakeLists.txt` test.
  - To disable the test set `_CMLIB_TEST_GIT_ARCHIVE` to `OFF` manually in the `FILE_DOWNLOAD/CMakeLists.txt` before running the test.
  - **The test is enabled by default**.

[fork of cmakelib-test]: https://gitlab.com/cmakelib/cmakelib-test
