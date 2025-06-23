
##
#
# Comprehensive test suite for CMLIB_PARSE_ARGUMENTS and CMLIB_PARSE_ARGUMENTS_CLEANUP
# covering basic functionality, argument types, complex scenarios, cleanup behavior,
# and error conditions.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_PARSE_ARGUMENTS_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/basic_functionality")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/argument_types")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/error_conditions")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/complex_scenarios")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_cases/cleanup")
