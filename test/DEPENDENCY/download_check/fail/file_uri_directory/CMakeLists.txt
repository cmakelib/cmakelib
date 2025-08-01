## File URI Directory Test
#
# Test DEPENDENCY failure when file:// URI points to a directory instead of a file
# TEST must FAIL
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_FILE_URI_DIRECTORY_FAIL_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../")
FIND_PACKAGE(CMLIB)

SET(TEST_DIR_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../test_resources")
GET_FILENAME_COMPONENT(TEST_DIR_PATH "${TEST_DIR_PATH}" ABSOLUTE)
SET(FILE_URI "file://${TEST_DIR_PATH}")

CMLIB_DEPENDENCY(
    TYPE FILE
    URI "${FILE_URI}"
    OUTPUT_PATH_VAR output_path
)
