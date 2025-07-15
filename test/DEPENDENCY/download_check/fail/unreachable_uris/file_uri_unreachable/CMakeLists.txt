## File URI Unreachable Test
#
# Test DEPENDENCY failure when file:// URI points to non-existent file
# TEST must FAIL
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_FILE_FAIL_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../../")
FIND_PACKAGE(CMLIB)

SET(UNREACHABLE_FILE_URI "file:///tmp/nonexistent_directory_12345/nonexistent_file.txt")

CMLIB_DEPENDENCY(
    TYPE FILE
    URI "${UNREACHABLE_FILE_URI}"
    OUTPUT_PATH_VAR output_path
)
