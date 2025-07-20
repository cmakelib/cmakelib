## Caller script for Test Case 3
#
# This script calls TEST_INVALID_CMAKE_RUN on a failing project,
# but with a non-matching error pattern, expecting it to fail.
#

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/test_invalid_cmake_run_should_fail_no_match" 
                       "Variable.*is not defined")
