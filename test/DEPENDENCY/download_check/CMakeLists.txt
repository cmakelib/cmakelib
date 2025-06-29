##
#
# Test DEPENDENCY download functionality for different URI schemes.
# Verify that FILE, HTTP, and GIT URIs all download files successfully.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_DOWNLOAD_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/file_uri_download")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/http_uri_download")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/git_uri_download")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/git_revision_validation")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/fail")
