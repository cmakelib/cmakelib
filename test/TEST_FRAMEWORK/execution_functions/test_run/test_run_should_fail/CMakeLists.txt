## Test Case: Should FAIL
#
# This project fails with a fatal error.
# When TEST_RUN is called on this, it should FAIL
# because the project configuration fails.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(FAILURE_TEST)
ENDIF()

MESSAGE(FATAL_ERROR "Intentional test failure")
