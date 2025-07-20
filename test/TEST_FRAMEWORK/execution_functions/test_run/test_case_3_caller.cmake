## Caller script for Test Case 3
#
# This script calls TEST_RUN on a non-existent directory,
# expecting it to fail because the directory doesn't exist.
#

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/non_existent_directory")
