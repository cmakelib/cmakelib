## Test Case: Should PASS (matching error)
#
# This project fails with a specific error message.
# When TEST_INVALID_CMAKE_RUN is called with the matching pattern,
# it should PASS because it correctly catches the expected failure.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(FAILING_TEST_PROJECT)
ENDIF()

MESSAGE(FATAL_ERROR "Variable TEST_VAR is not defined")
