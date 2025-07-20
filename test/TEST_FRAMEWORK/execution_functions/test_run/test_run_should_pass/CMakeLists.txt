## Test Case: Should PASS
#
# This is a simple passing project that should succeed.
# When TEST_RUN is called on this, it should PASS
# because the project configures successfully.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(SUCCESS_TEST)
ENDIF()

MESSAGE(STATUS "Test case: SUCCESS_TEST - This test should pass")
