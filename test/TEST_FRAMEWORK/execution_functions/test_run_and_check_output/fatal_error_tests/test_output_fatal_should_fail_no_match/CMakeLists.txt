## Test Case: Should FAIL (fatal error present but doesn't match)
#
# This project fails with a fatal error message,
# but the error message is different from what's expected.
# When TEST_RUN_AND_CHECK_OUTPUT is called with non-matching pattern,
# it should FAIL because the fatal error doesn't match the expected pattern.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(DIFFERENT_FATAL_ERROR_TEST)
ENDIF()

MESSAGE(FATAL_ERROR "Different fatal error message")
