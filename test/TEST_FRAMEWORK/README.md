
# TEST.cmake Tests

# Test - Execution Functions

Test located in `execution_functions/` directory.

### Overview

This test suite validates the three fundamental TEST execution functions that form the backbone of the CMLIB testing infrastructure:

- **TEST_RUN**
- **TEST_INVALID_CMAKE_RUN**
- **TEST_RUN_AND_CHECK_OUTPUT**

### Test Semantics

Tests are proceeded for three main cases

- **Should Pass**: The test should pass when the expected conditions are met.
- **Should Fail**: The test should fail when the expected conditions are not met.
- **Should Fail for Wrong Reason**: The test should fail, but for the wrong reason. This is to ensure that the test framework correctly identifies the failure reason.

### How to Run

TEST_RUN function is used to execute TEST_FRAMEWORK tests.

It is not optimnal - run test by a functionality which shall be tested by the test.

--> In the test/CMakeLists.txt the suite is executed by simple EXECUTE_PROCESS which is 
simple enought to be manualy validated.