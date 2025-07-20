## Test TEST_RUN_AND_CHECK_OUTPUT Function
#
# This ensures the output checking functionality works correctly for both
# warning detection and fatal error detection scenarios.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_RUN_AND_CHECK_OUTPUT_TESTS)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/warning_tests")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/fatal_error_tests")
