## Test Case: Should PASS (warning present and matches)
#
# This project succeeds and produces a warning message.
# When TEST_RUN_AND_CHECK_OUTPUT is called with matching WARNING_MESSAGE,
# it should PASS because the warning is present and matches the pattern.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(WARNING_PASS_TEST)
ENDIF()

MESSAGE(WARNING "Test warning message")
