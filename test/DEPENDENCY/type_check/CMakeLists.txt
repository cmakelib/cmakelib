##
#
# Test DEPENDENCY TYPE parameter validation using file:// URIs.
# This test group validates all TYPE parameter values (FILE, MODULE, ARCHIVE, DIRECTORY)
# using file:// URIs with centralized test resources from test_resources/.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_TYPE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

# Test all TYPE parameter values
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/type_file")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/type_module")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/type_archive")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/type_directory")
