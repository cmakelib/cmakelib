## Caller script for Test Case 1
#
# This script calls TEST_INVALID_CMAKE_RUN on a passing project,
# expecting it to fail because the project succeeds when we expect failure.
#

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/should_fail"
                       "some error")
