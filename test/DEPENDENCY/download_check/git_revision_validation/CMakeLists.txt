##
# Test GIT_REVISION functionality validation
# Verify that DEPENDENCY correctly downloads content from different Git revisions
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_GIT_REVISION_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/master_branch_download")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_branch_download")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/revision_specific_files")
