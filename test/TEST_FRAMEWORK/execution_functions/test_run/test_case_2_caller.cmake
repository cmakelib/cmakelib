## Caller script for Test Case 2
#
# This script calls TEST_RUN on a failing project,
# expecting it to fail because the project has a fatal error.
#

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_run_should_fail")
