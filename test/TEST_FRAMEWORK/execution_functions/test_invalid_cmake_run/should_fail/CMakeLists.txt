## Test Case: Should FAIL
#
# This is a simple passing project that should succeed.
# When TEST_INVALID_CMAKE_RUN is called on this, it should FAIL
# because it expects the project to fail but this project passes.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(PASSING_TEST_PROJECT)
ENDIF()

MESSAGE(STATUS "Test case: PASSING_TEST_PROJECT - This test should pass (used to test TEST_INVALID_CMAKE_RUN failure detection)")
