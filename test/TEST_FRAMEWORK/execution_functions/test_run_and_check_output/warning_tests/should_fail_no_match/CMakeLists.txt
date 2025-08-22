## Test Case: Should FAIL (warning present but doesn't match)
#
# This project succeeds and produces a warning message,
# but the warning message is different from what's expected.
# When TEST_RUN_AND_CHECK_OUTPUT is called with non-matching pattern,
# it should FAIL because the warning doesn't match the expected pattern.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(DIFFERENT_WARNING_TEST)
ENDIF()

MESSAGE(WARNING "Different warning message")
