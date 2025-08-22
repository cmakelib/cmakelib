## Test Case: Should PASS (fatal error present and matches)
#
# This project fails with a specific fatal error message.
# When TEST_RUN_AND_CHECK_OUTPUT is called with matching FATAL_ERROR_MESSAGE,
# it should PASS because the fatal error is present and matches the pattern.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(FATAL_ERROR_PASS_TEST)
ENDIF()

IF(DEFINED CMAKE_SCRIPT_MODE_FILE)
	SET(_mode "SCRIPT")
ELSE()
	SET(_mode "PROJECT")
ENDIF()
MESSAGE(FATAL_ERROR "Test fatal error message. Mode=${_mode}")
