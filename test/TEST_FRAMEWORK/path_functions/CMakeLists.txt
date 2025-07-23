## Test Path Functions
#
# Tests all TEST_VAR_PATH_* macros defined in TEST.cmake
# This ensures path testing macros work correctly in all scenarios.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_PATH_FUNCTIONS)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

SET(test_existing_file "${CMAKE_CURRENT_LIST_FILE}")
TEST_VAR_PATH_EXISTS(test_existing_file)

SET(test_existing_dir "${CMAKE_CURRENT_LIST_DIR}")
TEST_VAR_PATH_EXISTS(test_existing_dir)

SET(test_directory "${CMAKE_CURRENT_LIST_DIR}")
TEST_VAR_PATH_IS_DIRECTORY(test_directory)

SET(test_nonexistent_path "/non/existent/path/file.txt")
TEST_VAR_PATH_NOT_EXISTS(test_nonexistent_path)

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_path_exists")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_path_is_directory_file")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_path_is_directory_nonexistent")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_path_not_exists_file")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_path_not_exists_dir")
