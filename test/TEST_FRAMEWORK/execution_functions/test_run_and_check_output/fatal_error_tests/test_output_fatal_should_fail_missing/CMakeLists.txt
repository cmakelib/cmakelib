## Test Case: Should FAIL (fatal error not present)
#
# This project succeeds and produces no fatal error.
# When TEST_RUN_AND_CHECK_OUTPUT is called expecting a fatal error,
# it should FAIL because the expected fatal error is not found.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(NO_FATAL_ERROR_TEST)
ENDIF()

MESSAGE(STATUS "Test case: NO_FATAL_ERROR_TEST - This test produces no fatal error (used to test fatal error detection failure)")
