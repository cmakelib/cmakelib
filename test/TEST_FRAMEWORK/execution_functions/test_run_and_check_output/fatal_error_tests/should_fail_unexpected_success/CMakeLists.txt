## Test Case: Should FAIL (project succeeds when we expect fatal error)
#
# This project succeeds without any fatal error.
# When TEST_RUN_AND_CHECK_OUTPUT is called expecting a fatal error,
# it should FAIL because the project succeeded when we expected it to fail.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(UNEXPECTED_SUCCESS_TEST)
ENDIF()

MESSAGE(STATUS "Test case: UNEXPECTED_SUCCESS_TEST - This test succeeds when fatal error is expected (used to test unexpected success detection)")
