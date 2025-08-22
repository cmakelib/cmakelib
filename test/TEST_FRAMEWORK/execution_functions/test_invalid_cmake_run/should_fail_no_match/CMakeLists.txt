## Test Case: Should FAIL (non-matching error)
#
# This project fails with a different error message than expected.
# When TEST_INVALID_CMAKE_RUN is called expecting a different pattern,
# it should FAIL because the error message doesn't match.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(FAILING_DIFFERENT_ERROR_PROJECT)
ENDIF()

MESSAGE(FATAL_ERROR "Unexpected error message")
