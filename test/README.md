
# CMAKELIB Test Suite

Comprehensive test suite for the CMAKELIB library.

CMLIB is consistent and functional only when all tests pass.

Any test failure indicates CMLIB is not working as expected, even if the failure seems unrelated to required functionality. Complete system consistency is essential for reliable operation.

## Run

For test go to the `test/` directory and run

Linux/Mac Os:

```
    git clean -xfd .
	GIT_TERMINAL_PROMPT=0 cmake .
    git clean -xfd .
	GIT_TERMINAL_PROMPT=0 cmake -P ./CMakeLists.txt
```

Windows PowerShell:

```
	$env:GIT_TERMINAL_PROMPT=0
    git clean -xfd .
	cmake .
    git clean -xfd .
	cmake -P ./CMakeLists.txt
```

then just clean up all intermediate files in `test/` directory by

```
    git clean -xfd .
```

## Known Problems

- git archive funcionality is not tested by cmakelib-test Github repository.
  - The gitlab [fork of cmakelib-test] repo is used instead as a resource for testing `git archive`.
  - The git uri to the gitlab repo is hardcoded in the `FILE_DOWNLOAD/CMakeLists.txt` test.
  - To disable the test set `_CMLIB_TEST_GIT_ARCHIVE` to `OFF` manually in the `FILE_DOWNLOAD/CMakeLists.txt` before running the test.
  - **The test is enabled by default**.

[fork of cmakelib-test]: https://gitlab.com/cmakelib/cmakelib-test
