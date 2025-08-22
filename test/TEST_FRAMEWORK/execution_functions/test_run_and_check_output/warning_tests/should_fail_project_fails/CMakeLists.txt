## Test Case: Should FAIL (warning present but project fails)
#
# This project produces a warning message but then fails.
# When TEST_RUN_AND_CHECK_OUTPUT is called with WARNING_MESSAGE,
# it should FAIL because warnings require the project to succeed,
# but this project fails after producing the warning.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(WARNING_THEN_FAIL_TEST)
ENDIF()

MESSAGE(WARNING "Test warning message")
MESSAGE(FATAL_ERROR "Project fails")
