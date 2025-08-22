## Test Case: Should FAIL (warning not present)
#
# This project succeeds but produces no warning message.
# When TEST_RUN_AND_CHECK_OUTPUT is called expecting a warning,
# it should FAIL because the expected warning is not found.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(NO_WARNING_TEST)
ENDIF()

MESSAGE(STATUS "Test case: NO_WARNING_TEST - This test produces no warning (used to test warning detection failure)")
